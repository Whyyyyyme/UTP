import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../data/repository/like_repository.dart';

class LikeController extends GetxController {
  LikeController(this.repo);
  final LikeRepository repo;

  Stream<bool> isLikedStream({
    required String viewerId,
    required String productId,
  }) => repo.isLikedStream(viewerId: viewerId, productId: productId);

  Stream<QuerySnapshot<Map<String, dynamic>>> likesStream(String viewerId) =>
      repo.likesStream(viewerId);

  Future<(bool, String)> toggleLike({
    required String viewerId,
    required String productId,
    required String sellerId,
    required bool currentlyLiked,
  }) async {
    try {
      await repo.toggleLike(
        viewerId: viewerId,
        productId: productId,
        sellerId: sellerId,
        currentlyLiked: currentlyLiked,
      );
      return (true, currentlyLiked ? 'Unliked' : 'Liked');
    } catch (e) {
      return (false, e.toString());
    }
  }
}
