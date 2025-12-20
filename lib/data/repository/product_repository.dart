import '../services/product_service.dart';

class ProductRepository {
  final ProductService _service;
  ProductRepository({ProductService? service})
    : _service = service ?? ProductService();

  /// stream data produk (map) + include id
  Stream<Map<String, dynamic>?> productStream(String productId) {
    return _service.productStream(productId);
  }

  /// stream list produk seller lain (tiap item sudah include id)
  Stream<List<Map<String, dynamic>>> otherFromSellerStream({
    required String sellerId,
    required String excludeProductId,
    int limit = 10,
  }) {
    return _service.otherFromSellerStream(
      sellerId: sellerId,
      excludeProductId: excludeProductId,
      limit: limit,
    );
  }

  /// stream rekomendasi (tiap item sudah include id)
  Stream<List<Map<String, dynamic>>> youMayLikeStream({
    required String excludeProductId,
    int limit = 20,
  }) {
    return _service.youMayLikeStream(
      excludeProductId: excludeProductId,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> getUserByUid(String uid) {
    return _service.getUserByUid(uid);
  }
}
