import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LikeController extends GetxController {
  final _db = FirebaseFirestore.instance;

  Stream<bool> isLikedStream({
    required String viewerId,
    required String productId,
  }) {
    return _db
        .collection('users')
        .doc(viewerId)
        .collection('likes')
        .doc(productId)
        .snapshots()
        .map((d) => d.exists);
  }

  Future<void> toggleLike({
    required String viewerId,
    required String productId,
    required String sellerId,
    required bool currentlyLiked,
  }) async {
    final ref = _db
        .collection('users')
        .doc(viewerId)
        .collection('likes')
        .doc(productId);

    if (currentlyLiked) {
      await ref.delete();
    } else {
      await ref.set({
        'product_id': productId,
        'seller_id': sellerId,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> likesStream(String viewerId) {
    return _db
        .collection('users')
        .doc(viewerId)
        .collection('likes')
        .orderBy('created_at', descending: true)
        .snapshots();
  }
}
