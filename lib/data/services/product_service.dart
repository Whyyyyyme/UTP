import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _db;
  ProductService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Stream<Map<String, dynamic>?> productStream(String productId) {
    return _db.collection('products').doc(productId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return {'id': doc.id, ...data};
    });
  }

  Stream<List<Map<String, dynamic>>> otherFromSellerStream({
    required String sellerId,
    required String excludeProductId,
    int limit = 10,
  }) {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .where('seller_id', isEqualTo: sellerId)
        .orderBy('updated_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
          return snap.docs
              .where((d) => d.id != excludeProductId)
              .map((d) => {'id': d.id, ...d.data()})
              .toList();
        });
  }

  Stream<List<Map<String, dynamic>>> youMayLikeStream({
    required String excludeProductId,
    int limit = 20,
  }) {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .orderBy('updated_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
          return snap.docs
              .where((d) => d.id != excludeProductId)
              .map((d) => {'id': d.id, ...d.data()})
              .toList();
        });
  }

  Future<Map<String, dynamic>> getUserByUid(String uid) async {
    final snap = await _db
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return {};
    return snap.docs.first.data();
  }
}
