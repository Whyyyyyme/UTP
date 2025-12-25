import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../data/repository/orders_repository.dart';
import '../models/order_model.dart';

class OrdersController extends GetxController {
  OrdersController(this._repo);

  final OrdersRepository _repo;

  final isLoading = false.obs;

  // pisah error biar sold denied ga bunuh bought
  final soldError = RxnString();
  final boughtError = RxnString();

  final sold = <OrderModel>[].obs;
  final bought = <OrderModel>[].obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<OrderModel>>? _soldSub;
  StreamSubscription<List<OrderModel>>? _boughtSub;

  String _boundUid = '';
  bool _soldDone = false;
  bool _boughtDone = false;

  @override
  void onInit() {
    super.onInit();

    // SATU-SATUNYA sumber bind: authStateChanges
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid ?? '';

      if (uid.isEmpty) {
        _boundUid = '';
        _cancelDataStreams();
        sold.clear();
        bought.clear();
        isLoading.value = false;
        soldError.value = 'Kamu belum login';
        boughtError.value = 'Kamu belum login';
        return;
      }

      if (_boundUid == uid) return;
      _boundUid = uid;

      Future.microtask(() => _bind(uid));
    });
  }

  void _bind(String authUid) {
    soldError.value = null;
    boughtError.value = null;

    isLoading.value = true;
    _soldDone = false;
    _boughtDone = false;

    _cancelDataStreams();

    // ===== SOLD (seller_uids: auth uid) =====
    _soldSub = _repo
        .streamSold(authUid)
        .listen(
          (list) {
            sold.assignAll(list);
            _soldDone = true;
            _finishLoading();
          },
          onError: (e) {
            sold.clear();
            soldError.value = e.toString();
            _soldDone = true;
            _finishLoading();
          },
        );

    // ===== BOUGHT (buyer_id: auth uid) =====
    _boughtSub = _repo
        .streamBought(authUid)
        .listen(
          (list) {
            bought.assignAll(list);
            _boughtDone = true;
            _finishLoading();
          },
          onError: (e) {
            bought.clear();
            boughtError.value = e.toString();
            _boughtDone = true;
            _finishLoading();
          },
        );
  }

  void _finishLoading() {
    if (_soldDone && _boughtDone) {
      isLoading.value = false;
    }
  }

  void _cancelDataStreams() {
    _soldSub?.cancel();
    _boughtSub?.cancel();
    _soldSub = null;
    _boughtSub = null;
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _cancelDataStreams();
    super.onClose();
  }
}
