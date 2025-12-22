import 'package:prelovedly/models/product_model.dart';
import 'package:prelovedly/data/services/shop_service.dart';

class ShopProfileRepository {
  final ShopProfileService _service;
  ShopProfileRepository({ShopProfileService? service})
    : _service = service ?? ShopProfileService();

  Stream<List<ProductModel>> sellerProducts({
    required String userId,
    required bool isMe,
  }) {
    return _service
        .sellerProductsSnap(userId: userId, isMe: isMe)
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  Stream<Map<String, dynamic>?> userByUidStream(String uid) {
    return _service.userByUidStream(uid);
  }
}
