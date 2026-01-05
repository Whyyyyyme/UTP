// lib/view_model/admin_dashboard_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // state
  final isLoading = false.obs;
  final error = RxnString();

  // counts
  final userCount = 0.obs;
  final productCount = 0.obs;

  // ✅ sesuai request kamu
  final orderPaidCount = 0.obs;
  final orderReceivedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  /// ✅ Aman untuk semua versi cloud_firestore:
  /// - kalau `count()` tersedia => pakai aggregate count
  /// - kalau tidak => fallback query biasa (snap.size)
  Future<int> _safeCount(Query<Map<String, dynamic>> q) async {
    try {
      final dynamic dq = q; // bypass compile error bila count() belum ada
      final dynamic agg = await dq.count().get();
      final int c = (agg.count is int) ? agg.count as int : 0;
      return c;
    } catch (_) {
      final snap = await q.get();
      return snap.size;
    }
  }

  Future<void> refreshAll() async {
    try {
      isLoading.value = true;
      error.value = null;

      // users
      userCount.value = await _safeCount(_db.collection('users'));

      // products
      productCount.value = await _safeCount(_db.collection('products'));

      // orders paid
      orderPaidCount.value = await _safeCount(
        _db.collection('orders').where('status', isEqualTo: 'paid'),
      );

      // orders received
      orderReceivedCount.value = await _safeCount(
        _db.collection('orders').where('status', isEqualTo: 'received'),
      );
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
