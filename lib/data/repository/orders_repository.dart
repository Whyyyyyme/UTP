// lib/data/repository/orders_repository.dart
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
        .snapshots()
        .map((snap) => snap.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  // ===== SOLD =====
  Stream<List<OrderModel>> streamSold(String sellerAuthUid) {
    return _service
        .soldOrdersSnap(sellerAuthUid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  // ===== WALLET: RECEIVED =====
  // ✅ filter withdraw di client, null dianggap false
  Stream<List<OrderModel>> streamWalletReceived(String sellerAuthUid) {
    return _service.soldReceivedOrdersSnap(sellerAuthUid).snapshots().map((
      snap,
    ) {
      final list = snap.docs.map((d) => OrderModel.fromDoc(d)).toList();
      return list.where((o) => o.isWithdrawn != true).toList();
    });
  }

  Stream<List<MapEntry<String, OrderModel>>> streamWalletReceivedWithDocId(
    String sellerAuthUid,
  ) {
    return _service.soldReceivedOrdersSnap(sellerAuthUid).snapshots().map((
      snap,
    ) {
      return snap.docs
          .map((d) => MapEntry(d.id, OrderModel.fromDoc(d)))
          .where((e) => e.value.isWithdrawn != true)
          .toList();
    });
  }

  // ===== WALLET: PENDING/PAID =====
  Stream<List<OrderModel>> streamWalletPending(String sellerAuthUid) {
    return _service
        .soldPendingOrdersSnap(sellerAuthUid)
        .snapshots()
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

      final now = FieldValue.serverTimestamp();

      tx.update(orderRef, {
        'status': 'received',
        'received_at': now,
        'updated_at': now,

        // ✅ optional: set default biar data konsisten
        'is_withdrawn': (data['is_withdrawn'] ?? false),
      });
    });
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
