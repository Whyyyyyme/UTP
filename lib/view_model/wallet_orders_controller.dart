import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/repository/orders_repository.dart';
import '../models/order_model.dart';

class WalletOrdersController extends GetxController {
  WalletOrdersController(this._repo);
  final OrdersRepository _repo;

  final isLoading = false.obs;
  final error = RxnString();

  final availableBalance = 0.obs; // received
  final pendingBalance = 0.obs; // paid (belum diterima buyer)

  final orders = <OrderModel>[].obs; // orders received (buat list transaksi)
  final grouped = <String, List<OrderModel>>{}.obs;

  StreamSubscription? _authSub;
  StreamSubscription? _receivedSub;
  StreamSubscription? _pendingSub;

  @override
  void onInit() {
    super.onInit();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid ?? '';
      if (uid.isEmpty) {
        _receivedSub?.cancel();
        _pendingSub?.cancel();
        orders.clear();
        grouped.clear();
        availableBalance.value = 0;
        pendingBalance.value = 0;
        error.value = 'Kamu belum login';
        isLoading.value = false;
        return;
      }
      bind(uid);
    });
  }

  void bind(String sellerUid) {
    error.value = null;
    isLoading.value = true;

    _receivedSub?.cancel();
    _pendingSub?.cancel();

    // ✅ SALDO TERSEDIA: received
    _receivedSub = _repo
        .streamWalletReceived(sellerUid)
        .listen(
          (list) {
            orders.assignAll(list);
            availableBalance.value = list.fold<int>(
              0,
              (s, o) => s + o.subtotal,
            );
            _rebuildGroups();
            isLoading.value = false;
          },
          onError: (e) {
            error.value = e.toString();
            isLoading.value = false;
          },
        );

    // ✅ SALDO TERTUNDA: paid (belum diterima)
    _pendingSub = _repo
        .streamWalletPending(sellerUid)
        .listen(
          (list) {
            pendingBalance.value = list.fold<int>(0, (s, o) => s + o.subtotal);
          },
          onError: (e) {
            // boleh set error, tapi biasanya cukup abaikan agar UI tidak “ganggu”
            // error.value = e.toString();
          },
        );
  }

  void _rebuildGroups() {
    final fmt = DateFormat('MMMM yyyy', 'id_ID');
    final map = <String, List<OrderModel>>{};
    for (final o in orders) {
      final dt = o.createdAt?.toDate() ?? DateTime.now();
      final key = fmt.format(dt);
      map.putIfAbsent(key, () => []);
      map[key]!.add(o);
    }
    grouped.assignAll(map);
  }

  bool get canWithdraw => availableBalance.value > 0;

  void withdraw() {
    Get.snackbar('Info', 'Fitur cairkan saldo belum diaktifkan.');
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _receivedSub?.cancel();
    _pendingSub?.cancel();
    super.onClose();
  }
}
