import 'package:cloud_firestore/cloud_firestore.dart';
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

    final prodSnap = await _service.productDoc(productId);
    if (!prodSnap.exists) throw Exception('Produk tidak ditemukan');

    final productData = prodSnap.data() ?? {};
    final status = (productData['status'] ?? '').toString();
    if (status.isNotEmpty && status != 'published') {
      throw Exception('Produk belum tersedia');
    }

    final sellerId = (productData['seller_id'] ?? '').toString();

    final price = (productData['price'] is int)
        ? productData['price'] as int
        : int.tryParse('${productData['price']}') ?? 0;

    final title = (productData['title'] ?? '').toString();
    final brand = (productData['brand'] ?? '').toString();
    final size = (productData['size'] ?? '').toString();

    final thumb = (productData['thumbnail_url'] ?? '').toString();
    final imageUrls = (productData['image_urls'] is List)
        ? (productData['image_urls'] as List).map((e) => '$e').toList()
        : <String>[];

    final sellerSnap = await _service.userDoc(sellerId);
    final sellerData = sellerSnap.data() ?? {};
    final sellerName =
        (sellerData['name'] ??
                sellerData['username'] ??
                sellerData['displayName'] ??
                '')
            .toString();

    await _service.setCartItem(
      viewerId: viewerId,
      productId: productId,
      data: {
        'product_id': productId,
        'seller_id': sellerId,
        'seller_name': sellerName.isEmpty ? sellerId : sellerName,
        'price': price,
        'title': title,
        'brand': brand,
        'size': size,
        'thumbnail_url': thumb,
        'image_urls': imageUrls,
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
