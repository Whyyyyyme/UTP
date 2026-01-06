// lib/data/repository/checkout_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/checkout_item_model.dart';
import '../services/checkout_service.dart';

class CheckoutRepository {
  CheckoutRepository(this._service);
  final CheckoutService _service;

  static const double kPlatformFeeRate = 0.03; // ✅ 3%

  int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  // fee dibulatkan ke bawah biar konsisten (int)
  int _feeFrom(int amount) => (amount * 3) ~/ 100; // ✅ 3%

  Future<List<CheckoutItemModel>> getSelectedCartItems(String uid) async {
    final snap = await _service
        .cartItemsRef(uid)
        .where('selected', isEqualTo: true)
        .get();

    return snap.docs
        .map((d) => CheckoutItemModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<Map<String, dynamic>> getDefaultAddress(String uid) async {
    final q = await _service.db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('is_default', descending: true)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return {};
    return q.docs.first.data();
  }

    Future<void> createOrder({
    required String buyerId,
    required List<CheckoutItemModel> items,
    required Map<String, dynamic> address,
    required Map<String, dynamic> shipping,
    required Map<String, dynamic> payment,
  }) async {
    final buyerUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (buyerUid.isEmpty) throw Exception('Kamu belum login');

    final now = FieldValue.serverTimestamp();
    int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    // subtotal total order
    final subtotal = items.fold<int>(0, (sum, it) => sum + it.priceFinal);
    final shippingFeeFinal = _toInt(shipping['fee']);
    final total = subtotal + shippingFeeFinal;

    // fee admin
    const double feeRate = 0.03;

    // seller_uids
    final sellerUids = items
        .map((e) => e.sellerUid)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (sellerUids.isEmpty) {
      throw Exception(
        'seller_uid kosong di cart item (produk belum punya seller_uid)',
      );
    }

    final sellerIds = items
        .map((e) => e.sellerId)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    // ✅ hitung subtotal per seller
    final Map<String, int> sellerAmounts = {};
    for (final it in items) {
      sellerAmounts[it.sellerUid] =
          (sellerAmounts[it.sellerUid] ?? 0) + it.priceFinal;
    }

    // ✅ hitung fee per seller + net per seller
    final Map<String, int> adminFeeAmounts = {};
    final Map<String, int> sellerNetAmounts = {};

    int adminFeeTotal = 0;
    sellerAmounts.forEach((uid, amt) {
      final fee = (amt * feeRate).round(); // bisa juga floor kalau mau
      final net = amt - fee;

      adminFeeAmounts[uid] = fee;
      sellerNetAmounts[uid] = net;
      adminFeeTotal += fee;
    });

    final orderRef = _service.ordersRef().doc();
    final batch = _service.db.batch();

    batch.set(orderRef, {
      'order_id': orderRef.id,
      'buyer_id': buyerUid,
      'seller_uids': sellerUids,
      'seller_ids': sellerIds,

      'status': 'paid',
      'subtotal': subtotal,
      'shipping_fee': shippingFeeFinal,
      'total': total,

      // ✅ fee admin fields
      'admin_fee_rate': (feeRate * 100)
          .round(), // simpan 3 (persen) biar gampang
      'seller_amounts': sellerAmounts, // subtotal per seller
      'admin_fee_amounts': adminFeeAmounts, // fee per seller
      'seller_net_amounts': sellerNetAmounts, // net per seller
      'admin_fee_total': adminFeeTotal, // total fee untuk order

      'promo_discount': _toInt(shipping['promo_discount']),
      'shipping_fee_original': _toInt(shipping['fee_original']),
      'address': address,
      'shipping': shipping,
      'payment': payment,
      'created_at': now,
      'updated_at': now,
    });

    // items subcollection
    for (final it in items) {
      final itemRef = orderRef.collection('items').doc(it.productId);

      batch.set(itemRef, {
        'order_id': orderRef.id,
        'buyer_id': buyerUid,
        'product_id': it.productId,

        'seller_id': it.sellerId,
        'seller_uid': it.sellerUid, // ✅ penting!
        'title': it.title,
        'size': it.size,
        'image_url': it.imageUrl,
        'price_final': it.priceFinal,
        'price_original': it.priceOriginal,
        'offer_status': it.offerStatus,
        'offer_price': it.offerPrice,
        'qty': 1,
        'created_at': now,
      });

      batch.update(_service.productRef(it.productId), {
        'status': 'sold',
        'sold_to': buyerUid,
        'sold_at': now,
        'updated_at': now,
      });
    }

    // hapus cart selected
    for (final it in items) {
      final ref = _service.cartItemsRef(buyerUid).doc(it.productId);
      batch.delete(ref);
    }

    await batch.commit();
  }


  Future<void> backfillPromoToCart(String buyerId) async {
    final cartSnap = await _service.cartItemsRef(buyerId).get();
    if (cartSnap.docs.isEmpty) return;

    final batch = _service.db.batch();
    var changed = 0;

    for (final d in cartSnap.docs) {
      final data = d.data();

      final hasActive = data.containsKey('promo_shipping_active');
      final hasAmount = data.containsKey('promo_shipping_amount');

      if (hasActive && hasAmount) continue;

      final productId = (data['product_id'] ?? d.id).toString();
      if (productId.isEmpty) continue;

      final prod = await _service.productRef(productId).get();
      final pd = prod.data() ?? {};

      final promoActive = (pd['promo_shipping_active'] ?? false) == true;
      final promoAmount = (pd['promo_shipping_amount'] is int)
          ? (pd['promo_shipping_amount'] as int)
          : int.tryParse('${pd['promo_shipping_amount']}') ?? 0;

      batch.set(d.reference, {
        if (!hasActive) 'promo_shipping_active': promoActive,
        if (!hasAmount) 'promo_shipping_amount': promoAmount,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      changed++;
    }

    if (changed > 0) {
      await batch.commit();
    }
  }
}
