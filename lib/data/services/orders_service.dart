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

  DocumentReference<Map<String, dynamic>> orderRef(String orderId) =>
      ordersRef().doc(orderId);

  Stream<QuerySnapshot<Map<String, dynamic>>> soldReceivedOrdersSnap(
    String sellerAuthUid,
  ) {
    return ordersRef()
        .where('seller_uids', arrayContains: sellerAuthUid)
        .where('status', isEqualTo: 'received')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> fetchFirstItem(String orderId) async {
    final snap = await orderRef(orderId)
        .collection('items')
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }

  Future<Map<String, dynamic>?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> soldPendingOrdersSnap(
    String sellerAuthUid,
  ) {
    return ordersRef()
        .where('seller_uids', arrayContains: sellerAuthUid)
        .where('status', isEqualTo: 'paid') // pending = belum diterima
        .orderBy('created_at', descending: true)
        .snapshots();
  }
}
