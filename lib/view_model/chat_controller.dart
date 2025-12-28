import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    final raw = (Get.arguments as Map<String, dynamic>?) ?? {};
    threadId = (raw['threadId'] ?? '').toString();
    peerId = (raw['peerId'] ?? '').toString();
    productId = (raw['productId'] ?? '').toString();
    debugPrint(
      '🧵 ChatController open threadId=$threadId me=$me peerId=$peerId productId=$productId',
    );

    _bindStreams();
  }

  void _bindStreams() {
    final uid = me;

    if (productId.isNotEmpty) {
      productSub?.cancel();
      productSub = repo.productStream(productId: productId).listen((doc) {
        final data = doc.data() ?? {};
        productStatus.value = (data['status'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
      });
    }

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

  // status default = 'pending' biar aman
  String get offerStatus => (thread.value?.offer?.status ?? 'pending')
      .toString()
      .toLowerCase()
      .trim();

  bool get isOfferPending => offerStatus == 'pending';
  bool get isOfferAccepted => offerStatus == 'accepted';
  bool get isOfferRejected => offerStatus == 'rejected';

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

  final productStatus = ''.obs;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? productSub;

  bool get isProductSold => productStatus.value == 'sold';
  bool get showOfferBanner => hasOffer && !isProductSold;

  /// Tombol Terima/Tolak hanya untuk seller saat pending
  bool get showOfferActions => hasOffer && isOfferPending && isSeller;

  bool get showBuyNow => hasOffer && isOfferAccepted && isBuyer;

  String get offerBannerTitle {
    if (!hasOffer) return '';

    // pending
    if (isOfferPending) return isSeller ? 'Offer baru' : 'Offer berjalan';

    // accepted
    if (isOfferAccepted) return isSeller ? 'Offer diterima' : 'Offer diterima';

    // rejected
    if (isOfferRejected) return isSeller ? 'Offer ditolak' : 'Offer ditolak';

    return 'Status offer';
  }

  String get offerBannerSubtitle {
    final off = thread.value?.offer;
    if (off == null) return '';

    if (isOfferPending) {
      return isSeller
          ? 'Buyer mengirim offer, pilih Terima/Tolak.'
          : 'Kamu sudah kirim offer, tunggu respon.';
    }

    if (isOfferAccepted) {
      // ✅ sesuai screenshot: buyer diarahkan beli
      return isBuyer
          ? 'Langsung beli barangnya!'
          : 'Kamu sudah menerima offer.';
    }

    if (isOfferRejected) {
      return isBuyer ? 'Offer kamu ditolak.' : 'Kamu menolak offer.';
    }

    return 'Offer diperbarui.';
  }

  int get offerPrice => thread.value?.offer?.offerPrice ?? 0;
  int get originalPrice => thread.value?.offer?.originalPrice ?? 0;

  // =========================================================
  // ACTION: buy now (buyer setelah offer accepted)
  // =========================================================
  void buyNow() {
    final t = thread.value;
    if (t == null) return;

    if (!showBuyNow) {
      Get.snackbar('Info', 'Belum bisa beli sekarang');
      return;
    }

    // TODO: GANTI route sesuai app kamu
    // Contoh: buka detail produk
    Get.toNamed('/product-detail', arguments: {'productId': t.productId});
  }

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
    productSub?.cancel();
    textC.dispose();
    _threadSub?.cancel();
    _msgSub?.cancel();
    super.onClose();
  }
}
