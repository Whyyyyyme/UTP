import 'package:cloud_firestore/cloud_firestore.dart';

class ShopProfileService {
  final FirebaseFirestore _db;
  ShopProfileService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> sellerProductsSnap({
    required String userId,
    required bool isMe,
  }) {
    final q = isMe
        ? _db
              .collection('products')
              .where('seller_id', isEqualTo: userId)
              .where('status', isEqualTo: 'published')
              .orderBy('created_at', descending: true)
        : _db
              .collection('products')
              .where('seller_id', isEqualTo: userId)
              .where('status', isEqualTo: 'published')
              .orderBy('updated_at', descending: true);

    return q.snapshots();
  }

  Stream<Map<String, dynamic>?> userByUidStream(String uid) {
    return _db
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data());
  }
}
