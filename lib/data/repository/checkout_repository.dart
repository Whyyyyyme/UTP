import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/checkout_item_model.dart';
import '../services/checkout_service.dart';

class CheckoutRepository {
  CheckoutRepository(this._service);
  final CheckoutService _service;

  Future<List<CheckoutItemModel>> getCartItems(String uid) async {
    final snap = await _service.cartItemsRef(uid).get();
    return snap.docs
        .map((d) => CheckoutItemModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<Map<String, dynamic>> getDefaultAddress(String uid) async {
    // kamu bisa sesuaikan dengan skema addresses kamu
    // di sini contoh: users/{uid}/addresses: ambil yang is_default==true, fallback first
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
    final now = FieldValue.serverTimestamp();

    final subtotal = items.fold<int>(0, (sum, it) => sum + it.priceFinal);
    final shippingFee = (shipping['fee'] is int)
        ? shipping['fee'] as int
        : int.tryParse('${shipping['fee']}') ?? 0;

    final total = subtotal + shippingFee;

    final orderRef = _service.ordersRef().doc(); // auto id
    final batch = _service.db.batch();

    batch.set(orderRef, {
      'order_id': orderRef.id,
      'buyer_id': buyerId,
      'status': 'pending_payment', // awal
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'total': total,
      'address': address,
      'shipping': shipping,
      'payment': payment,
      'created_at': now,
      'updated_at': now,
    });

    // simpan item item di subcollection: orders/{orderId}/items
    for (final it in items) {
      final itemRef = orderRef.collection('items').doc(it.productId);
      batch.set(itemRef, {
        'product_id': it.productId,
        'seller_id': it.sellerId,
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

      // OPTIONAL: tandai produk jadi reserved / sold_pending
      batch.set(_service.productRef(it.productId), {
        'status': 'reserved',
        'reserved_by': buyerId,
        'reserved_at': now,
        'updated_at': now,
      }, SetOptions(merge: true));
    }

    // clear cart
    final cartSnap = await _service.cartItemsRef(buyerId).get();
    for (final d in cartSnap.docs) {
      batch.delete(d.reference);
    }

    await batch.commit();
  }
}
