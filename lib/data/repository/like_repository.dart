import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/like_service.dart';

class LikeRepository {
  LikeRepository(this._service);
  final LikeService _service;

  Stream<bool> isLikedStream({
    required String viewerId,
    required String productId,
  }) {
    if (viewerId.isEmpty || productId.isEmpty) return Stream.value(false);

    return _service
        .isLikedStream(viewerId: viewerId, productId: productId)
        .handleError((_) => false);
  }

  Future<void> toggleLike({
    required String viewerId,
    required String productId,
    required String sellerId,
    required bool currentlyLiked,
  }) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong (belum login)');
    if (productId.isEmpty) throw Exception('productId kosong');

    if (currentlyLiked) {
      await _service.deleteLike(viewerId: viewerId, productId: productId);
    } else {
      await _service.setLike(
        viewerId: viewerId,
        productId: productId,
        data: {
          'product_id': productId,
          'seller_id': sellerId,
          'created_at': FieldValue.serverTimestamp(),
        },
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> likesStream(String viewerId) {
    if (viewerId.isEmpty) return const Stream.empty();
    return _service.likesStream(viewerId);
  }
}
