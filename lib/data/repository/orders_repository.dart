import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prelovedly/models/order_model.dart';
import '../services/orders_service.dart';

class OrdersRepository {
  OrdersRepository({OrdersService? service, FirebaseFirestore? db})
    : _service = service ?? OrdersService(),
      _db = db ?? FirebaseFirestore.instance;

  final OrdersService _service;
  final FirebaseFirestore _db;

  // ===== BOUGHT =====
  Stream<List<OrderModel>> streamBought(String buyerAuthUid) {
    return _service
        .boughtOrdersSnap(buyerAuthUid)
        .map((snap) => snap.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  // ===== SOLD =====
  Stream<List<OrderModel>> streamSold(String sellerAuthUid) {
    return _service
        .soldOrdersSnap(sellerAuthUid)
        .map((snap) => snap.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  Stream<List<OrderModel>> streamWalletReceived(String sellerAuthUid) {
    return _service
        .soldReceivedOrdersSnap(sellerAuthUid)
        .map((snap) => snap.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  Future<void> markAsReceived(String orderId) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (authUid.isEmpty) throw Exception('Kamu belum login');

    final orderRef = _service.orderRef(orderId);

    await _db.runTransaction((tx) async {
      final orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) throw Exception('Order tidak ditemukan');

      final data = orderSnap.data() ?? {};
      final buyerId = (data['buyer_id'] ?? '').toString();
      final status = (data['status'] ?? '').toString();

      if (buyerId != authUid) {
        throw Exception('Akses ditolak: bukan buyer order ini');
      }

      if (status == 'received') return;

      int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
      final amount = toInt(data['subtotal']);
      if (amount <= 0) throw Exception('Subtotal invalid');

      final now = FieldValue.serverTimestamp();

      tx.update(orderRef, {
        'status': 'received',
        'received_at': now,
        'updated_at': now,
      });
    });
  }

  Stream<List<OrderModel>> streamWalletPending(String sellerAuthUid) {
    return _service
        .soldPendingOrdersSnap(sellerAuthUid)
        .map((snap) => snap.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  Future<void> markOrdersWithdrawn({
    required List<String> orderDocIds,
    required String sellerAuthUid,
    required String bank,
    required String accountNumber,
    required int amount,
  }) async {
    if (orderDocIds.isEmpty) return;

    final now = FieldValue.serverTimestamp();

    final batch = _db.batch();
    for (final docId in orderDocIds) {
      final ref = _service.orderRef(docId);
      batch.update(ref, {
        'is_withdrawn': true,
        'withdrawn_at': now,
        'withdraw_bank': bank,
        'withdraw_account_number': accountNumber,
        'withdraw_amount': amount,
        'updated_at': now,
      });
    }

    await batch.commit();
  }

  Stream<List<MapEntry<String, OrderModel>>> streamWalletReceivedWithDocId(
    String sellerAuthUid,
  ) {
    return _service
        .soldReceivedOrdersSnap(sellerAuthUid)
        .map(
          (snap) => snap.docs
              .map((d) => MapEntry(d.id, OrderModel.fromDoc(d)))
              .toList(),
        );
  }

  Future<void> withdrawOrders({
    required List<String> orderDocIds,
    required String bank,
    required String accountNumber,
    required int amount,
  }) async {
    if (orderDocIds.isEmpty) return;

    final now = FieldValue.serverTimestamp();
    final batch = _db.batch();

    for (final docId in orderDocIds) {
      batch.update(_service.orderRef(docId), {
        'is_withdrawn': true,
        'withdrawn_at': now,
        'withdraw_bank': bank,
        'withdraw_account_number': accountNumber,
        'withdraw_amount': amount,
        'updated_at': now,
      });
    }

    await batch.commit();
  }
}
