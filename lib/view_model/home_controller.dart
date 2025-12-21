import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/repository/home_repository.dart';
import 'session_controller.dart';

class HomeController extends GetxController {
  HomeController(this.repo);

  final HomeRepository repo;

  // badge keranjang
  final RxInt cartCount = 0.obs;

  StreamSubscription<int>? _cartCountSub;
  Worker? _viewerWorker;

  String _lastViewerId = '';

  @override
  void onInit() {
    super.onInit();

    cartCount.value = 0;

    final initial = SessionController.to.viewerId.value;
    _lastViewerId = initial;
    _bindViewer(initial);

    // ✅ listen perubahan viewerId
    _viewerWorker = ever<String>(SessionController.to.viewerId, (uid) {
      debugPrint('viewerId changed => $uid');
      if (uid == _lastViewerId) return;
      _lastViewerId = uid;

      _bindViewer(uid);
    });
  }

  void _bindViewer(String viewerId) {
    // stop listener lama
    _cartCountSub?.cancel();
    _cartCountSub = null;

    if (viewerId.isEmpty) {
      cartCount.value = 0;
      return;
    }

    _cartCountSub = repo
        .cartCountStream(viewerId)
        .listen(
          (count) => cartCount.value = count,
          onError: (_) => cartCount.value = 0,
        );
  }

  // UI tinggal pakai ini
  Stream<List<String>> recommendedSellerIdsStream() =>
      repo.recommendedSellerIdsStream();

  Stream<QuerySnapshot<Map<String, dynamic>>> hotItemsStream() =>
      repo.hotItemsStream();

  Stream<List<Map<String, dynamic>>> sellerThumbsStream(String sellerId) =>
      repo.sellerThumbs(sellerId);

  Future<Map<String, dynamic>?> fetchUser(String userId) =>
      repo.fetchUser(userId);

  @override
  void onClose() {
    _viewerWorker?.dispose();
    _cartCountSub?.cancel();
    super.onClose();
  }
}
