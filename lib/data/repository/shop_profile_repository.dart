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
    return _service.sellerProductsSnap(userId: userId, isMe: isMe).map((snap) {
      final out = <ProductModel>[];

      for (final d in snap.docs) {
        try {
          out.add(ProductModel.fromDoc(d));
        } catch (e) {
          // ✅ jangan bikin Shop Profile crash
          // ignore: avoid_print
          print('PARSE PRODUCT FAIL id=${d.id} data=${d.data()} err=$e');
        }
      }

      return out;
    });
  }

  Stream<Map<String, dynamic>?> userByUidStream(String uid) {
    return _service.userByUidStream(uid);
  }
}
