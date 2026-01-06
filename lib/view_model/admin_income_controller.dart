// lib/view_model/admin_income_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminIncomeController extends GetxController {
  final _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final error = RxnString();

  // ✅ JANGAN ubah nama ini kalau page kamu sudah pakai totalFeeReceived
  final totalFeeReceived = 0.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    bind();
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse('$v') ?? 0;
  }

  void bind() {
    error.value = null;
    isLoading.value = true;

    _sub?.cancel();
    _sub = _db
        .collection('orders')
        .where('status', isEqualTo: 'received')
        .snapshots()
        .listen(
          (snap) {
            int sum = 0;

            for (final d in snap.docs) {
              final data = d.data();

              // ✅ FIX UTAMA:
              // order kamu nyimpan fee di 'admin_fee_total'
              // fallback kalau masih ada data lama: 'platform_fee_total'
              final feeValue =
                  data['admin_fee_total'] ?? data['platform_fee_total'];

              sum += _toInt(feeValue);
            }

            totalFeeReceived.value = sum;
            isLoading.value = false;
          },
          onError: (e) {
            error.value = e.toString();
            isLoading.value = false;
          },
        );
  }

  // opsional: kalau kamu butuh tombol refresh manual dari UI
  void refreshNow() => bind();

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
