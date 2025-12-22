import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutService {
  CheckoutService(this.db);
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> cartItemsRef(String uid) =>
      db.collection('carts').doc(uid).collection('items');

  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> ordersRef() =>
      db.collection('orders');

  DocumentReference<Map<String, dynamic>> productRef(String productId) =>
      db.collection('products').doc(productId);
}
