import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repository/chat_repository.dart';
import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';
import '../view_model/session_controller.dart';

class ChatController extends GetxController {
  ChatController(this.repo);
  final ChatRepository repo;

  // ====== STATE ======
  final isLoading = true.obs;

  final thread = Rxn<ChatThreadModel>();
  final messages = <ChatMessageModel>[].obs;

  final textC = TextEditingController();

  // ====== ARGS ======
  late final String threadId;
  late final String peerId;
  late final String productId;

  String get me => SessionController.to.viewerId.value;

  // ====== STREAM SUBS ======
  StreamSubscription? _threadSub;
  StreamSubscription? _msgSub;

  @override
  void onInit() {
    super.onInit();

    // args dari navigator
    final raw = (Get.arguments as Map<String, dynamic>?) ?? {};
    threadId = (raw['threadId'] ?? '').toString();
    peerId = (raw['peerId'] ?? '').toString();
    productId = (raw['productId'] ?? '').toString();

    _bindStreams();
  }

  void _bindStreams() {
    final uid = me;

    if (uid.isEmpty) {
      isLoading.value = false;
      Get.snackbar('Info', 'Kamu belum login');
      return;
    }
    if (threadId.isEmpty) {
      isLoading.value = false;
      Get.snackbar('Error', 'threadId kosong');
      return;
    }

    _threadSub?.cancel();
    _msgSub?.cancel();

    _threadSub = repo
        .threadStream(uid: uid, threadId: threadId)
        .listen(
          (t) {
            thread.value = t;
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar('Error', 'Gagal load thread: $e');
          },
        );

    _msgSub = repo
        .messagesStream(uid: uid, threadId: threadId)
        .listen(
          (list) => messages.assignAll(list),
          onError: (e) => Get.snackbar('Error', 'Gagal load pesan: $e'),
        );
  }

  // =========================================================
  // OFFER: helpers untuk 3 versi tampilan
  // =========================================================
  bool get hasOffer => thread.value?.offer != null;
  String get offerStatus => thread.value?.offer?.status ?? '';
  bool get isOfferPending => offerStatus == 'pending';

  bool get isSeller {
    final off = thread.value?.offer;
    if (off == null) return false;
    return me == off.sellerId;
  }

  bool get isBuyer {
    final off = thread.value?.offer;
    if (off == null) return false;
    return me == off.buyerId;
  }

  /// Banner tampil kalau offer ada (pending/accepted/rejected)
  bool get showOfferBanner => hasOffer;

  /// Tombol Terima/Tolak hanya untuk seller saat pending
  bool get showOfferActions => hasOffer && isOfferPending && isSeller;

  String get offerBannerTitle {
    if (!hasOffer) return '';
    if (isOfferPending) return isSeller ? 'Offer baru' : 'Offer berjalan';
    return 'Status offer';
  }

  String get offerBannerSubtitle {
    final off = thread.value?.offer;
    if (off == null) return '';

    if (off.status == 'pending') {
      return isSeller
          ? 'Buyer mengirim offer, pilih Terima/Tolak.'
          : 'Kamu sudah kirim offer, tunggu respon.';
    }
    if (off.status == 'accepted') return 'Offer diterima.';
    if (off.status == 'rejected') return 'Offer ditolak.';
    return 'Offer diperbarui.';
  }

  int get offerPrice => thread.value?.offer?.offerPrice ?? 0;
  int get originalPrice => thread.value?.offer?.originalPrice ?? 0;

  // =========================================================
  // ACTION: send text
  // =========================================================
  Future<void> sendText() async {
    final uid = me;

    if (uid.isEmpty) {
      Get.snackbar('Info', 'Kamu belum login');
      return;
    }
    if (peerId.isEmpty) {
      Get.snackbar('Error', 'peerId kosong');
      return;
    }
    if (threadId.isEmpty) {
      Get.snackbar('Error', 'threadId kosong');
      return;
    }

    final text = textC.text.trim();
    if (text.isEmpty) return;

    try {
      await repo.sendText(
        uid: uid,
        peerId: peerId,
        threadId: threadId,
        text: text,
      );
      textC.clear();
    } catch (e) {
      Get.snackbar('Error', 'Gagal kirim pesan: $e');
    }
  }

  // =========================================================
  // ACTION: offer (buyer kirim offer) + seller accept/reject
  // =========================================================

  /// Buyer kirim offer (kamu panggil dari UI: tombol "Kirim Offer")
  Future<void> sendOffer({
    required int originalPrice,
    required int offerPrice,
  }) async {
    final uid = me;
    if (uid.isEmpty) {
      Get.snackbar('Info', 'Kamu belum login');
      return;
    }
    if (peerId.isEmpty) {
      Get.snackbar('Error', 'peerId kosong');
      return;
    }
    if (threadId.isEmpty) {
      Get.snackbar('Error', 'threadId kosong');
      return;
    }

    // rule sederhana validasi
    if (offerPrice <= 0) {
      Get.snackbar('Error', 'Harga offer tidak valid');
      return;
    }
    if (originalPrice <= 0) {
      Get.snackbar('Error', 'Harga asli tidak valid');
      return;
    }

    // Asumsi: user yang mengirim offer adalah buyer.
    // Seller adalah peerId.
    try {
      await repo.sendOffer(
        buyerId: uid,
        sellerId: peerId,
        threadId: threadId,
        originalPrice: originalPrice,
        offerPrice: offerPrice,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal kirim offer: $e');
    }
  }

  /// Seller menerima offer
  Future<void> acceptOffer() async {
    final off = thread.value?.offer;
    if (off == null) return;

    // aman: hanya seller boleh
    if (me != off.sellerId) {
      Get.snackbar('Info', 'Hanya seller yang bisa menerima offer');
      return;
    }
    if (off.status != 'pending') return;

    try {
      await repo.acceptOffer(
        buyerId: off.buyerId,
        sellerId: off.sellerId,
        threadId: threadId,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal terima offer: $e');
    }
  }

  /// Seller menolak offer
  Future<void> rejectOffer() async {
    final off = thread.value?.offer;
    if (off == null) return;

    if (me != off.sellerId) {
      Get.snackbar('Info', 'Hanya seller yang bisa menolak offer');
      return;
    }
    if (off.status != 'pending') return;

    try {
      await repo.rejectOffer(
        buyerId: off.buyerId,
        sellerId: off.sellerId,
        threadId: threadId,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal tolak offer: $e');
    }
  }

  // =========================================================
  // UI helper: format rupiah (simple)
  // =========================================================
  String rp(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return "Rp ${buf.toString()}";
  }

  @override
  void onClose() {
    textC.dispose();
    _threadSub?.cancel();
    _msgSub?.cancel();
    super.onClose();
  }
}
