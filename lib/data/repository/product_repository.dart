import '../services/product_service.dart';

class ProductRepository {
  final ProductService _service;
  ProductRepository({ProductService? service})
    : _service = service ?? ProductService();

  /// stream data produk (map) + include id
  Stream<Map<String, dynamic>?> productStream(String productId) {
    return _service.productStream(productId);
  }

  Future<Map<String, dynamic>> getUserByUid(String uid) {
    return _service.getUserByUid(uid);
  }
}
