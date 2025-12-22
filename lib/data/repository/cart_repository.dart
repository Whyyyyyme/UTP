import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:prelovedly/data/repository/chat_repository.dart';
import 'package:prelovedly/data/services/chat_service.dart';
import '../services/cart_service.dart';

class CartRepository {
  CartRepository(this._service);

  final CartService _service;

  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream(
    String viewerId,
  ) => _service.cartItemsStream(viewerId);

  Stream<bool> isInCartStream({
    required String viewerId,
    required String productId,
  }) => _service.isInCartStream(viewerId: viewerId, productId: productId);

  Future<void> addToCart({
    required String viewerId,
    required String productId,
  }) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');
    if (productId.isEmpty) throw Exception('productId kosong');

    // ===================== ambil data produk =====================
    final prodSnap = await _service.productDoc(productId);
    if (!prodSnap.exists) throw Exception('Produk tidak ditemukan');

    final productData = prodSnap.data() ?? {};
    final status = (productData['status'] ?? '').toString();
    if (status.isNotEmpty && status != 'published') {
      throw Exception('Produk belum tersedia');
    }

    final sellerId = (productData['seller_id'] ?? '').toString();

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

    // ===================== ambil data seller =====================
    final sellerSnap = await _service.userDoc(sellerId);
    final sellerData = sellerSnap.data() ?? {};
    final sellerName =
        (sellerData['name'] ??
                sellerData['username'] ??
                sellerData['displayName'] ??
                '')
            .toString();

    // ===================== cek offer accepted untuk produk ini =====================
    int finalPrice = priceOriginal;
    String offerStatus = '';
    int offerPrice = 0;

    try {
      // Pastikan ChatService & ChatRepository tersedia
      if (!Get.isRegistered<ChatService>()) {
        Get.lazyPut(() => ChatService(FirebaseFirestore.instance), fenix: true);
      }
      if (!Get.isRegistered<ChatRepository>()) {
        Get.lazyPut(() => ChatRepository(Get.find<ChatService>()), fenix: true);
      }

      final chatRepo = Get.find<ChatRepository>();

      final tOffer = await chatRepo.findOfferThreadForProduct(
        uid: viewerId,
        peerId: sellerId,
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
    } catch (_) {
      // kalau gagal cek offer, tetap pakai harga asli (biar cart tetap jalan)
    }

    // ===================== simpan cart item (1 schema) =====================
    await _service.setCartItem(
      viewerId: viewerId,
      productId: productId,
      data: {
        'product_id': productId,
        'seller_id': sellerId,
        'seller_name': sellerName.isEmpty ? sellerId : sellerName,

        // ✅ harga yang dipakai di keranjang
        'price': finalPrice,

        // ✅ simpan harga asli & info offer (opsional untuk UI)
        'price_original': priceOriginal,
        'offer_status': offerStatus,
        'offer_price': offerPrice,

        'title': title,
        'brand': brand,
        'size': size,
        'thumbnail_url': thumb,
        'image_urls': imageUrls,
        'updated_at': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> removeFromCart({
    required String viewerId,
    required String productId,
  }) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');
    if (productId.isEmpty) throw Exception('productId kosong');

    await _service.deleteCartItem(viewerId: viewerId, productId: productId);
  }

  Future<void> toggleCart({
    required String viewerId,
    required String productId,
    required bool currentlyInCart,
  }) async {
    if (currentlyInCart) {
      await removeFromCart(viewerId: viewerId, productId: productId);
    } else {
      await addToCart(viewerId: viewerId, productId: productId);
    }
  }

  Future<void> clearCart(String viewerId) {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');
    return _service.clearCart(viewerId);
  }

  /// ✅ Hapus semua item dalam cart untuk seller tertentu
  Future<void> deleteAllBySeller({
    required String viewerId,
    required String sellerId,
  }) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');
    if (sellerId.isEmpty) return;

    final docs = await _service.getItemsBySeller(
      viewerId: viewerId,
      sellerId: sellerId,
    );

    if (docs.isEmpty) return;

    await _service.batchDeleteDocs(docs);
  }
}
