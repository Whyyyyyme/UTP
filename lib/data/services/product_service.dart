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
