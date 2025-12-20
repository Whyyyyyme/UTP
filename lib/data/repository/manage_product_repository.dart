import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prelovedly/models/product_model.dart';
import '../services/manage_product_service.dart';

class ManageProductRepository {
  ManageProductRepository(this._service);
  final ManageProductService _service;

  Future<ProductModel?> fetchProduct(String productId) async {
    if (productId.isEmpty) return null;

    final doc = await _service.getProduct(productId);
    if (!doc.exists) return null;

    return ProductModel.fromDoc(doc);
  }

  Future<void> markAsSold(String productId) {
    return _service.updateProduct(productId, {
      'status': 'sold',
      'updated_at': Timestamp.now(),
    });
  }

  Future<void> toggleDiscount(String productId, bool enabled) {
    return _service.updateProduct(productId, {
      'discount_active': enabled,
      'updated_at': Timestamp.now(),
    });
  }

  Future<void> deleteProduct(String productId) {
    return _service.deleteProduct(productId);
  }
}
