import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  LikeService(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> likeRef({
    required String viewerId,
    required String productId,
  }) {
    return _db
        .collection('users')
        .doc(viewerId)
        .collection('likes')
        .doc(productId);
  }

  Stream<bool> isLikedStream({
    required String viewerId,
    required String productId,
  }) {
    return likeRef(
      viewerId: viewerId,
      productId: productId,
    ).snapshots().map((d) => d.exists);
  }

  Future<void> setLike({
    required String viewerId,
    required String productId,
    required Map<String, dynamic> data,
  }) {
    return likeRef(
      viewerId: viewerId,
      productId: productId,
    ).set(data, SetOptions(merge: true));
  }

  Future<void> deleteLike({
    required String viewerId,
    required String productId,
  }) {
    return likeRef(viewerId: viewerId, productId: productId).delete();
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
