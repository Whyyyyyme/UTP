// lib/view_model/wallet_orders_controller.dart
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

  final availableBalance = 0.obs; // received & not withdrawn
  final pendingBalance = 0.obs; // paid (pending)

  final orders = <OrderModel>[].obs;
  final grouped = <String, List<OrderModel>>{}.obs;

  final receivedOrderDocIds = <String>[].obs;

  final isSubmitting = false.obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription? _receivedSub;
  StreamSubscription? _pendingSub;

  String _sellerUid = '';

  @override
  void onInit() {
    super.onInit();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid ?? '';
      if (uid.isEmpty) {
        _sellerUid = '';
        _receivedSub?.cancel();
        _pendingSub?.cancel();

        orders.clear();
        grouped.clear();
        receivedOrderDocIds.clear();

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
    _sellerUid = sellerUid;

    error.value = null;
    isLoading.value = true;

    _receivedSub?.cancel();
    _pendingSub?.cancel();

    _receivedSub = _repo
        .streamWalletReceivedWithDocId(sellerUid)
        .listen(
          (entries) {
            receivedOrderDocIds.assignAll(entries.map((e) => e.key).toList());

            final list = entries.map((e) => e.value).toList();
            orders.assignAll(list);

            // ✅ saldo masuk sudah dipotong 3% (net per seller)
            availableBalance.value = list.fold<int>(
              0,
              (s, o) => s + o.netForSeller(sellerUid),
            );

            _rebuildGroups();
            isLoading.value = false;
          },
          onError: (e) {
            error.value = e.toString();
            isLoading.value = false;
          },
        );

    _pendingSub = _repo.streamWalletPending(sellerUid).listen((list) {
      // pending juga pakai net (biar konsisten)
      pendingBalance.value = list.fold<int>(
        0,
        (s, o) => s + o.netForSeller(sellerUid),
      );
    }, onError: (e) {});
  }

  void _rebuildGroups() {
    final fmt = DateFormat('MMMM yyyy', 'id_ID');
    final map = <String, List<OrderModel>>{};

    for (final o in orders) {
      final dt = o.createdAt?.toDate() ?? DateTime.now();
      final key = fmt.format(dt);
      (map[key] ??= <OrderModel>[]).add(o);
    }

    grouped.assignAll(map);
  }

  bool get canWithdraw => availableBalance.value > 0;

  Future<void> withdrawAllSubmit({
    required String bank,
    required String accountNumber,
    required String secretPassword,
  }) async {
    if (!canWithdraw) {
      Get.snackbar('Info', 'Saldo tidak mencukupi.');
      return;
    }

    if (bank.trim().isEmpty ||
        accountNumber.trim().isEmpty ||
        secretPassword.isEmpty) {
      Get.snackbar('Info', 'Semua field wajib diisi.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null || email.isEmpty) {
      Get.snackbar('Error', 'Kamu belum login.');
      return;
    }

    final amount = availableBalance.value; // ✅ ini sudah net
    final docIds = receivedOrderDocIds.toList();

    try {
      isSubmitting.value = true;

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: secretPassword),
      );

      await _repo.withdrawOrders(
        orderDocIds: docIds,
        bank: bank,
        accountNumber: accountNumber,
        amount: amount,
      );

      Get.back();
      Get.snackbar('Berhasil', 'Pencairan berhasil.');
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.code == 'wrong-password' ? 'Password salah.' : (e.message ?? e.code),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _receivedSub?.cancel();
    _pendingSub?.cancel();
    super.onClose();
  }
}
