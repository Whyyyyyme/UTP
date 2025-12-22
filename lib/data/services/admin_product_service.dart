import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProducts() {
    return _db
        .collection('products')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> setProductStatus({
    required String productId,
    required String status, // "published" | "hidden"
  }) async {
    await _db.collection('products').doc(productId).set({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
