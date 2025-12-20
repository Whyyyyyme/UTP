import 'package:cloud_firestore/cloud_firestore.dart';

class ManageProductService {
  ManageProductService(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> productRef(String productId) =>
      _db.collection('products').doc(productId);

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct(String productId) {
    return productRef(productId).get();
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) {
    return productRef(productId).update(data);
  }

  Future<void> deleteProduct(String productId) {
    return productRef(productId).delete();
  }

  Stream<int> likesCountStream(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('likes')
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> cartsCountStream(String productId) {
    return _db
        .collectionGroup('items')
        .where('product_id', isEqualTo: productId)
        .snapshots()
        .map((s) => s.size);
  }
}
