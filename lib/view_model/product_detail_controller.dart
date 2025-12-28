import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:prelovedly/data/repository/chat_repository.dart';
import 'package:prelovedly/data/services/chat_service.dart';
import 'package:prelovedly/models/chat_thread_model.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/auth_controller.dart';

import 'package:prelovedly/view_model/cart_controller.dart';
import 'package:prelovedly/view_model/like_controller.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import '../../data/repository/product_repository.dart';

class ProductDetailController extends GetxController {
  final AuthController authC = Get.find<AuthController>();
  final ProductRepository _repo;

  late final ChatRepository chatRepo;

  final offerThread = Rxn<ChatThreadModel>();
  final sellerChatThread = Rxn<ChatThreadModel>();
  final isCheckingThread = false.obs;
  final hasAcceptedOfferWithSeller = false.obs;
  String _lastLoadKey = '';

  ProductDetailController({ProductRepository? repo})
    : _repo = repo ?? ProductRepository();

  // args
  final productId = ''.obs;
  final sellerIdArg = ''.obs;
  final isMe = false.obs;

  // ui state
  final pageIndex = 0.obs;

  late final LikeController likeC;

  String get viewerId => FirebaseAuth.instance.currentUser?.uid ?? '';

  bool get canBuy => !isMe.value;
  bool get canManage => isMe.value;

  @override
  void onInit() {
    super.onInit();
    likeC = Get.find<LikeController>();
    _readArgs();

    // ✅ ensure ChatService + ChatRepository ada
    if (!Get.isRegistered<ChatService>()) {
      Get.lazyPut(() => ChatService(FirebaseFirestore.instance), fenix: true);
    }
    if (!Get.isRegistered<ChatRepository>()) {
      Get.lazyPut(() => ChatRepository(Get.find<ChatService>()), fenix: true);
    }
    chatRepo = Get.find<ChatRepository>();

    if (sellerIdArg.value.isNotEmpty && productId.value.isNotEmpty) {
      loadChatButtonsState(
        sellerId: sellerIdArg.value,
        productId: productId.value,
      );
    }
  }

  void _readArgs() {
    final args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    productId.value = (args['id'] ?? '').toString();
    sellerIdArg.value = (args['seller_id'] ?? '').toString();
    isMe.value = (args['is_me'] == true);
  }

  // ===== STREAMS =====
  Stream<Map<String, dynamic>?> productStream() {
    return _repo.productStream(productId.value);
  }

  Stream<Map<String, dynamic>?> productStreamById(String pid) {
    return _repo.productStream(pid);
  }

  Future<Map<String, dynamic>> getSellerUser(String sellerId) {
    return _repo.getUserByUid(sellerId);
  }

  // ===== HELPERS =====
  String rp(dynamic value) {
    final v = value is int ? value : int.tryParse('$value') ?? 0;
    final f = NumberFormat.decimalPattern('id_ID').format(v);
    return 'Rp $f';
  }

  String timeAgo(dynamic ts) {
    final dt = _toDateTime(ts);
    if (dt == null) return '-';

    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }

  DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;

    try {
      final maybe = (v as dynamic);
      if (maybe.toDate != null) {
        final DateTime dt = maybe.toDate();
        return dt;
      }
    } catch (_) {}

    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);

    return null;
  }

  // ===== ACTIONS =====
  Future<void> buy({
    required String sellerId,
    required String productId,
  }) async {
    final uid = viewerId;

    if (uid.isEmpty) {
      Get.snackbar('Login dulu', 'Sesi kamu habis, silakan login ulang');
      return;
    }

    if (sellerId == uid) {
      Get.snackbar('Info', 'Tidak bisa membeli produk sendiri');
      return;
    }

    final cartC = Get.find<CartController>();

    try {
      await cartC.addToCart(viewerId: uid, productId: productId);
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      rethrow;
    }
  }

  // =========================================================
  // ✅ UI STATE: cek apakah produk ini sudah pernah nego
  // =========================================================
  Future<void> loadChatButtonsState({
    required String sellerId,
    required String productId,
  }) async {
    final uid = SessionController.to.viewerId.value;
    if (uid.isEmpty) return;

    // ✅ guard biar tidak query berkali-kali saat rebuild
    final key = '$uid|$sellerId|$productId';
    if (_lastLoadKey == key) return;
    _lastLoadKey = key;

    // ✅ pastikan ChatService & ChatRepository tersedia
    if (!Get.isRegistered<ChatService>()) {
      Get.lazyPut(() => ChatService(FirebaseFirestore.instance), fenix: true);
    }
    if (!Get.isRegistered<ChatRepository>()) {
      Get.lazyPut(() => ChatRepository(Get.find<ChatService>()), fenix: true);
    }

    final chatRepo = Get.find<ChatRepository>();

    try {
      isCheckingThread.value = true;

      debugPrint(
        '🧭 loadChatButtonsState uid=$uid sellerId=$sellerId productId=$productId',
      );

      // 1) cek thread offer untuk produk ini (buat tombol "Cek Offer")
      final tOffer = await chatRepo.findOfferThreadForProduct(
        uid: uid,
        peerId: sellerId,
        productId: productId,
      );
      offerThread.value = tOffer;

      debugPrint(
        '🧾 offerThread=${tOffer?.threadId} '
        'status=${tOffer?.offer?.status} '
        'offerPrice=${tOffer?.offer?.offerPrice}',
      );

      // 2) cek thread terbaru dengan seller (buat tombol "Message")
      final tSeller = await chatRepo.findLatestThreadWithSeller(
        uid: uid,
        peerId: sellerId,
      );
      sellerChatThread.value = tSeller;

      debugPrint('💬 sellerChatThread=${tSeller?.threadId}');

      // 3) ✅ cek apakah buyer sudah punya offer "accepted" dengan seller ini
      //    - kalau iya: produk lain di toko itu tidak boleh nego → jadi "Message"
      final accepted = await chatRepo.hasAcceptedOfferWithSeller(
        uid: uid,
        sellerId: sellerId,
      );
      hasAcceptedOfferWithSeller.value = accepted;

      debugPrint('✅ hasAcceptedOfferWithSeller=$accepted');
    } catch (e, st) {
      debugPrint('❌ loadChatButtonsState error: $e');
      debugPrint(st.toString());
    } finally {
      isCheckingThread.value = false;
    }
  }

  // =========================================================
  // ✅ Aksi tombol di Product Detail:
  // - kalau sudah ada offerThread => "Cek Offer" => open chat thread itu
  // - kalau belum => buka halaman nego (atau open chat)
  // =========================================================
  void goToOfferChatOrNego({
    required String productId,
    required String sellerId,
    required String productTitle,
    required String productImage,
    required int price,
  }) {
    final t = offerThread.value;

    if (t != null) {
      Get.toNamed(
        Routes.chat,
        arguments: {
          'threadId': t.threadId,
          'peerId': sellerId,
          'productId': productId,
        },
      );
      return;
    }

    Get.toNamed(
      Routes.nego,
      arguments: {
        'productId': productId,
        'sellerId': sellerId,
        'title': productTitle,
        'imageUrl': productImage,
        'price': price,
        'fromChat': false,
      },
    );
  }

  Future<void> openMessageSellerFromOtherProduct({
    required String sellerId,
    required String productId,
    required String productTitle,
    required String productImage,
  }) async {
    final myUid = SessionController.to.viewerId.value;

    if (myUid.isEmpty) {
      Get.snackbar('Info', 'Kamu belum login');
      return;
    }

    if (sellerId == myUid) {
      Get.snackbar('Info', 'Tidak bisa chat dengan diri sendiri');
      return;
    }

    final tSeller = sellerChatThread.value;
    if (tSeller != null) {
      Get.toNamed(
        Routes.chat,
        arguments: {
          'threadId': tSeller.threadId,
          'peerId': sellerId,
          'productId': tSeller.productId, // konteks
        },
      );
      return;
    }

    final me = authC.user.value;
    final myName = (me?.username.isNotEmpty == true)
        ? me!.username
        : (me?.nama ?? 'Me');
    final myPhoto = me?.fotoProfilUrl ?? '';

    final seller = await getSellerUser(sellerId);
    final sellerName = (seller['username'] ?? seller['nama'] ?? 'Seller')
        .toString();
    final sellerPhoto = (seller['foto_profil_url'] ?? '').toString();

    final threadId = await chatRepo.ensureThread(
      myUid: myUid,
      peerId: sellerId,
      productId: productId,
      productTitle: productTitle,
      productImage: productImage,
      myName: myName,
      myPhoto: myPhoto,
      peerName: sellerName,
      peerPhoto: sellerPhoto,
    );

    await loadChatButtonsState(sellerId: sellerId, productId: productId);

    Get.toNamed(
      Routes.chat,
      arguments: {
        'threadId': threadId,
        'peerId': sellerId,
        'productId': productId,
      },
    );
  }

  Future<void> openChatFromProduct({
    required String sellerId,
    required String productId,
    required String productTitle,
    required String productImage,
  }) async {
    await openMessageSellerFromOtherProduct(
      sellerId: sellerId,
      productId: productId,
      productTitle: productTitle,
      productImage: productImage,
    );
  }

  final sellerRatingAvg = 0.0.obs;
  final sellerRatingTotal = 0.obs;
  StreamSubscription? _sellerReviewSub;

  void bindSellerRating(String sellerUid) {
    _sellerReviewSub?.cancel();
    _sellerReviewSub = FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerUid)
        .collection('reviews')
        .snapshots()
        .listen((snap) {
          final total = snap.docs.length;
          var sum = 0;
          for (final d in snap.docs) {
            final r = (d.data()['rating'] ?? 0);
            final rating = (r is int ? r : int.tryParse('$r') ?? 0).clamp(1, 5);
            sum += rating;
          }
          sellerRatingTotal.value = total;
          sellerRatingAvg.value = total == 0 ? 0.0 : sum / total;
        });
  }
}
