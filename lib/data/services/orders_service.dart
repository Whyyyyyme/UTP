import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersService {
  OrdersService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> ordersRef() =>
      _db.collection('orders');

  // ========= BOUGHT =========
  Stream<QuerySnapshot<Map<String, dynamic>>> boughtOrdersSnap(
    String buyerAuthUid,
  ) {
    return ordersRef()
        .where('buyer_id', isEqualTo: buyerAuthUid)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // ========= SOLD (auth uid) =========
  Stream<QuerySnapshot<Map<String, dynamic>>> soldOrdersSnap(
    String sellerAuthUid,
  ) {
    return ordersRef()
        .where('seller_uids', arrayContains: sellerAuthUid)
        .orderBy('created_at', descending: true)
        .snapshots();
  }
}
