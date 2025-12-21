import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/data/repository/chat_repository.dart';
import 'package:prelovedly/data/services/chat_service.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import 'package:flutter/services.dart';

import '../data/repository/nego_repository.dart';
import '../routes/app_routes.dart';

class NegoController extends GetxController {
  NegoController(this.repo);

  final NegoRepository repo;

  final isLoading = false.obs;
  final errorText = ''.obs;
  final canSendRx = false.obs;

  final TextEditingController priceC = TextEditingController();

  // data produk
  late final String productId;
  late final String sellerId;
  late final String title;
  late final String imageUrl;
  late final int originalPrice;

  // apakah nego dibuka dari chat?
  // kalau dari chat, setelah kirim offer cukup Get.back()
  // kalau dari product detail (belum masuk chat), setelah kirim offer arahkan ke ChatPage
  late final bool fromChat;

  // config diskon
  final int minDiscountPercent = 40;

  int get minOfferPrice {
    final min = (originalPrice * (100 - minDiscountPercent)) / 100.0;
    return min.ceil();
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};

    productId = (args['productId'] ?? '').toString();
    sellerId = (args['sellerId'] ?? '').toString();
    title = (args['title'] ?? '').toString();
    imageUrl = (args['imageUrl'] ?? '').toString();

    final p = args['price'];
    originalPrice = p is int ? p : int.tryParse('$p') ?? 0;

    // flag asal halaman
    fromChat = (args['fromChat'] == true);

    priceC.text = '';
    validate();
  }

  @override
  void onClose() {
    priceC.dispose();
    super.onClose();
  }

  int parseOffer() {
    final raw = priceC.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  void validate() {
    final offer = parseOffer();

    if (offer <= 0) {
      errorText.value = '';
      canSendRx.value = false;
      return;
    }

    if (offer < minOfferPrice) {
      errorText.value =
          'Tawaran kamu minimal Rp ${_rp(minOfferPrice)} (diskon $minDiscountPercent%)';
      canSendRx.value = false;
    } else {
      errorText.value = '';
      canSendRx.value = !isLoading.value;
    }
  }

  bool get canSend => parseOffer() >= minOfferPrice && !isLoading.value;

  Future<void> send() async {
    final buyerId = SessionController.to.viewerId.value;
    if (buyerId.isEmpty) {
      Get.snackbar('Info', 'Kamu belum login');
      return;
    }

    final offer = parseOffer();
    if (offer < minOfferPrice) {
      validate();
      return;
    }

    try {
      isLoading.value = true;

      // 1️⃣ ambil meta user (boleh dummy dulu)
      final buyerMeta = await repo.getUserMeta(buyerId);
      final sellerMeta = await repo.getUserMeta(sellerId);

      // 2️⃣ pastikan THREAD ADA
      final threadId = await repo.ensureThreadId(
        buyerId: buyerId,
        sellerId: sellerId,
        productId: productId,
        productTitle: title,
        productImage: imageUrl,
        originalPrice: originalPrice,
        buyerName: buyerMeta.name,
        buyerPhoto: buyerMeta.photoUrl,
        sellerName: sellerMeta.name,
        sellerPhoto: sellerMeta.photoUrl,
      );

      // 3️⃣ KIRIM OFFER via ChatRepository (SINGLE SOURCE OF TRUTH)
      final chatRepo = ChatRepository(ChatService(FirebaseFirestore.instance));

      await chatRepo.sendOffer(
        buyerId: buyerId,
        sellerId: sellerId,
        threadId: threadId,
        originalPrice: originalPrice,
        offerPrice: offer,
      );

      // 4️⃣ LANGSUNG MASUK CHAT
      Get.offNamed(
        Routes.chat,
        arguments: {
          'threadId': threadId,
          'peerId': sellerId,
          'productId': productId,
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal kirim nego: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _rp(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return buf.toString();
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  RupiahInputFormatter({this.useDotSeparator = true});

  final bool useDotSeparator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = _format(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String digits) {
    String s = digits.replaceFirst(RegExp(r'^0+(?=.)'), '');

    final chars = s.split('');
    final sb = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      final idxFromEnd = chars.length - i;
      sb.write(chars[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        sb.write(useDotSeparator ? '.' : ',');
      }
    }
    return sb.toString();
  }
}
