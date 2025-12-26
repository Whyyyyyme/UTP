import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/repository/wallet_repository.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

class WalletController extends GetxController {
  WalletController(this._repo);

  final WalletRepository _repo;

  final isLoading = false.obs;
  final error = RxnString();

  final wallet = Rxn<WalletModel>();
  final availableBalance = 0.obs;

  // opsi B: tidak ada pending, tampilkan 0
  final pendingBalance = 0.obs;

  final transactions = <WalletTransactionModel>[].obs;

  // group per "Oktober 2025"
  final grouped = <String, List<WalletTransactionModel>>{}.obs;

  StreamSubscription? _authSub;
  StreamSubscription? _walletSub;
  StreamSubscription? _txSub;

  String _boundUid = '';

  @override
  void onInit() {
    super.onInit();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid ?? '';
      if (uid.isEmpty) {
        _boundUid = '';
        _cancel();
        wallet.value = WalletModel.empty();
        availableBalance.value = 0;
        pendingBalance.value = 0;
        transactions.clear();
        grouped.clear();
        error.value = 'Kamu belum login';
        isLoading.value = false;
        return;
      }

      if (_boundUid == uid) return;
      _boundUid = uid;
      Future.microtask(() => bind(uid));
    });
  }

  void bind(String uid) {
    error.value = null;
    isLoading.value = true;

    _cancel();

    _walletSub = _repo
        .streamWallet(uid)
        .listen(
          (w) {
            wallet.value = w;
            availableBalance.value = w.availableBalance;
            pendingBalance.value = 0; // opsi B
            isLoading.value = false;
          },
          onError: (e) {
            error.value = e.toString();
            isLoading.value = false;
          },
        );

    _txSub = _repo
        .streamTransactions(uid, limit: 50)
        .listen(
          (list) {
            transactions.assignAll(list);
            _rebuildGroups();
          },
          onError: (e) {
            error.value = e.toString();
          },
        );
  }

  void _rebuildGroups() {
    final map = <String, List<WalletTransactionModel>>{};
    final fmt = DateFormat('MMMM yyyy', 'id_ID');

    for (final tx in transactions) {
      final dt = tx.createdAt?.toDate() ?? DateTime.now();
      final key = fmt.format(dt);
      map.putIfAbsent(key, () => []);
      map[key]!.add(tx);
    }

    grouped.assignAll(map);
    grouped.refresh();
  }

  bool get canWithdraw => availableBalance.value > 0;

  void withdraw() {
    // nanti kamu bisa sambungkan ke flow pencairan
    Get.snackbar('Info', 'Fitur cairkan saldo belum diaktifkan.');
  }

  void _cancel() {
    _walletSub?.cancel();
    _txSub?.cancel();
    _walletSub = null;
    _txSub = null;
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _cancel();
    super.onClose();
  }
}
