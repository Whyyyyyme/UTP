import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prelovedly/data/repository/chat_repository.dart';
import 'package:prelovedly/data/services/chat_service.dart';
import '../services/cart_service.dart';

class CartRepository {
  CartRepository(this._service);
  final CartService _service;

  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream() =>
      _service.cartItemsStream();

  Stream<bool> isInCartStream({required String productId}) =>
      _service.isInCartStream(productId: productId);

  Future<void> addToCart({required String productId}) async {
    if (productId.isEmpty) throw Exception('productId kosong');

    final viewerUid = _service.authUid();
    if (viewerUid.isEmpty) throw Exception('Kamu belum login');

    // ====== product ======
    final prodSnap = await _service.productDoc(productId);
    if (!prodSnap.exists) throw Exception('Produk tidak ditemukan');

    final productData = prodSnap.data() ?? {};
    final status = (productData['status'] ?? '').toString().trim();
    if (status.isNotEmpty && status != 'published') {
      throw Exception('Produk belum tersedia');
    }

    final sellerUid = (productData['seller_uid'] ?? '').toString().trim();
    if (sellerUid.isEmpty) {
      // 🔥 ini biang masalah sellerId kamu: produk gak punya seller_uid
      throw Exception('Produk belum punya seller_uid (wajib)');
    }

    final sellerId = (productData['seller_id'] ?? '')
        .toString()
        .trim(); // cuma buat display/debug, jangan dipakai fetch user

    final priceOriginal = (productData['price'] is int)
        ? productData['price'] as int
        : int.tryParse('${productData['price']}') ?? 0;

    final title = (productData['title'] ?? '').toString();
    final brand = (productData['brand'] ?? '').toString();
    final size = (productData['size'] ?? '').toString();

    final thumb = (productData['thumbnail_url'] ?? '').toString();
    final imageUrls = (productData['image_urls'] is List)
        ? (productData['image_urls'] as List).map((e) => '$e').toList()
        : <String>[];

    final promoShippingActive =
        (productData['promo_shipping_active'] ?? false) == true;
    final promoShippingAmount = (productData['promo_shipping_amount'] is int)
        ? productData['promo_shipping_amount'] as int
        : int.tryParse('${productData['promo_shipping_amount']}') ?? 0;

    // ====== seller by UID ONLY ======
    String sellerName = '';
    try {
      final sellerSnap = await _service.userDocByUid(sellerUid);
      final sellerData = sellerSnap.data() ?? {};
      sellerName =
          (sellerData['name'] ??
                  sellerData['username'] ??
                  sellerData['displayName'] ??
                  '')
              .toString();
    } catch (_) {
      // kalau gagal baca user, tetap jalan
    }

    // ====== offer check (peerId harus UID) ======
    int finalPrice = priceOriginal;
    String offerStatus = '';
    int offerPrice = 0;

    try {
      if (!Get.isRegistered<ChatService>()) {
        Get.lazyPut(() => ChatService(FirebaseFirestore.instance), fenix: true);
      }
      if (!Get.isRegistered<ChatRepository>()) {
        Get.lazyPut(() => ChatRepository(Get.find<ChatService>()), fenix: true);
      }

      final chatRepo = Get.find<ChatRepository>();

      final tOffer = await chatRepo.findOfferThreadForProduct(
        uid: viewerUid,
        peerId: sellerUid, // ✅ FIX: pake UID, bukan sellerId
        productId: productId,
      );

      final st = (tOffer?.offer?.status ?? '').toLowerCase().trim();
      if (st == 'accepted') {
        offerPrice = tOffer?.offer?.offerPrice ?? 0;
        if (offerPrice > 0) {
          finalPrice = offerPrice;
          offerStatus = 'accepted';
        }
      } else if (st.isNotEmpty) {
        offerStatus = st;
        offerPrice = tOffer?.offer?.offerPrice ?? 0;
      }
    } catch (_) {}

    // ====== write cart ======
    await _service.setCartItem(
      productId: productId,
      data: {
        'product_id': productId,
        'buyer_uid': viewerUid,

        'seller_uid': sellerUid, // 🔥 ini yang dipakai rules/orders
        'seller_id': sellerId, // opsional aja
        'seller_name': sellerName.isEmpty ? sellerUid : sellerName,

        'price': finalPrice,
        'price_original': priceOriginal,
        'offer_status': offerStatus,
        'offer_price': offerPrice,

        'title': title,
        'brand': brand,
        'size': size,
        'thumbnail_url': thumb,
        'image_urls': imageUrls,

        'promo_shipping_active': promoShippingActive,
        'promo_shipping_amount': promoShippingAmount,
        'selected': true,

        'updated_at': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> setItemSelected({
    required String productId,
    required bool selected,
  }) async {
    if (productId.isEmpty) throw Exception('productId kosong');
    await _service.setSelected(productId: productId, selected: selected);
  }

  Future<void> removeFromCart({required String productId}) async {
    if (productId.isEmpty) throw Exception('productId kosong');
    await _service.deleteCartItem(productId: productId);
  }

  Future<void> toggleCart({
    required String productId,
    required bool currentlyInCart,
  }) async {
    if (currentlyInCart) {
      await removeFromCart(productId: productId);
    } else {
      await addToCart(productId: productId);
    }
  }

  Future<void> clearCart() => _service.clearCart();

  Future<void> deleteAllBySeller({required String sellerId}) async {
    // kalau kamu masih butuh delete by seller, pakai seller_uid yang ada di cart item
    if (sellerId.isEmpty) return;
    final docs = await _service.getItemsBySeller(sellerId: sellerId);
    if (docs.isEmpty) return;
    await _service.batchDeleteDocs(docs);
  }

  Future<void> selectOnlySeller({required String sellerUid}) async {
    if (sellerUid.trim().isEmpty) throw Exception('sellerUid kosong');
    await _service.selectOnlySeller(sellerUid: sellerUid);
  }
}
