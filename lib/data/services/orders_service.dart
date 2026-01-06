// lib/data/services/orders_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersService {
  final FirebaseFirestore db;
  OrdersService({FirebaseFirestore? db})
    : db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> ordersRef() =>
      db.collection('orders');

  DocumentReference<Map<String, dynamic>> orderRef(String orderId) =>
      db.collection('orders').doc(orderId);

  // buyer_id == uid
  Query<Map<String, dynamic>> boughtOrdersSnap(String buyerAuthUid) {
    return db
        .collection('orders')
        .where('buyer_id', isEqualTo: buyerAuthUid)
        .orderBy('created_at', descending: true);
  }

  // seller_uids array contains uid
  Query<Map<String, dynamic>> soldOrdersSnap(String sellerAuthUid) {
    return db
        .collection('orders')
        .where('seller_uids', arrayContains: sellerAuthUid)
        .orderBy('created_at', descending: true);
  }

  // ✅ RECEIVED: jangan filter is_withdrawn di query
    Query<Map<String, dynamic>> soldReceivedOrdersSnap(String sellerUid) {
    return ordersRef()
        .where('seller_uids', arrayContains: sellerUid)
        .where('status', isEqualTo: 'received');
    // ✅ tidak pakai orderBy
    // ✅ tidak pakai is_withdrawn filter (biar data lama tetap kebaca)
  }

  Query<Map<String, dynamic>> soldPendingOrdersSnap(String sellerUid) {
    return ordersRef()
        .where('seller_uids', arrayContains: sellerUid)
        .where('status', isEqualTo: 'paid');
  }

}
