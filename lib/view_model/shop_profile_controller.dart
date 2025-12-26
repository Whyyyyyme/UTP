import 'dart:async';

import 'package:get/get.dart';
import 'package:prelovedly/data/repository/chat_repository.dart';
import 'package:prelovedly/models/product_model.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import '../data/repository/shop_profile_repository.dart';

import '../routes/app_routes.dart';

import 'auth_controller.dart';
import 'follow_controller.dart';
import 'like_controller.dart';
import 'sell_controller.dart';

class ShopProfileController extends GetxController {
  final ShopProfileRepository repo;
  ShopProfileController({required this.repo});

  // global deps
  late final AuthController authC;
  late final FollowController followC;
  late final LikeController likeC;

  // ui state
  final showFullBio = false.obs;

  // args / state
  final initialTabIndex = 0.obs;
  final targetUserId = ''.obs;

  // computed
  String get viewerId => authC.user.value?.id ?? '';
  bool get isMe =>
      targetUserId.value.isNotEmpty && targetUserId.value == viewerId;

  // rating state
  final ratingSummary = const RatingSummary(
    avg: 0,
    total: 0,
    counts: [0, 0, 0, 0, 0, 0], // index 0..5
  ).obs;

  StreamSubscription? _reviewsSub;
  Worker? _targetUserWorker;

  @override
  void onInit() {
    super.onInit();
    authC = Get.find<AuthController>();
    followC = Get.find<FollowController>();
    likeC = Get.find<LikeController>();

    _resolveSellerIdFromRoute();
    _readArgs();

    // ✅ ini yang bikin dinamis: setiap targetUserId berubah, bind ulang stream rating
    _targetUserWorker = ever<String>(targetUserId, (v) {
      final uid = v.trim();
      if (uid.isEmpty) return;
      bindRating(uid);
    });

    // ✅ trigger pertama kali (karena ever() tidak otomatis jalan untuk nilai awal)
    final firstUid = targetUserId.value.trim();
    if (firstUid.isNotEmpty) {
      bindRating(firstUid);
    }
  }

  void _resolveSellerIdFromRoute() {
    String sid = '';
    final raw = Get.arguments;

    if (raw is Map) {
      sid =
          (raw['sellerId'] ??
                  raw['seller_id'] ??
                  raw['userId'] ??
                  raw['uid'] ??
                  raw['id'] ??
                  raw['myId'] ??
                  '')
              .toString()
              .trim();
    }

    if (sid.isEmpty) {
      sid =
          (Get.parameters['sellerId'] ??
                  Get.parameters['seller_id'] ??
                  Get.parameters['userId'] ??
                  Get.parameters['uid'] ??
                  Get.parameters['id'] ??
                  Get.parameters['myId'] ??
                  '')
              .toString()
              .trim();
    }

    if (sid.isEmpty) return;
    targetUserId.value = sid;
  }

  void _readArgs() {
    final args = (Get.arguments is Map) ? (Get.arguments as Map) : {};

    final idx = (args['initialTabIndex'] is int)
        ? args['initialTabIndex'] as int
        : 0;
    initialTabIndex.value = (idx < 0 || idx > 2) ? 0 : idx;

    final fallback = viewerId; // kalau args kosong, buka profil sendiri
    final t = (args['seller_id'] ?? args['userId'] ?? fallback).toString();
    targetUserId.value = t.isEmpty ? fallback : t;
  }

  // ===== streams =====
  Stream<Map<String, dynamic>?> targetUserStream() {
    return repo.userByUidStream(targetUserId.value);
  }

  Stream<List<ProductModel>> productsStream() {
    return repo.sellerProducts(userId: targetUserId.value, isMe: isMe);
  }

  Stream<bool> isFollowingStream() {
    if (viewerId.isEmpty || targetUserId.value.isEmpty) {
      return Stream.value(false);
    }
    return followC.isFollowingStream(
      viewerId: viewerId,
      targetUserId: targetUserId.value,
    );
  }

  Stream<int> followersCountStream() =>
      followC.followersCountStream(targetUserId.value);
  Stream<int> followingCountStream() =>
      followC.followingCountStream(targetUserId.value);

  Stream<List<Map<String, dynamic>>> reviewsStream(String sellerUid) {
    return repo.sellerReviewsSnap(sellerUid).map((snap) {
      return snap.docs.map((d) => d.data()).toList(growable: false);
    });
  }

  // ===== actions =====
  Future<void> toggleFollow({required bool currentlyFollowing}) async {
    if (viewerId.isEmpty) {
      Get.snackbar('Login dulu', 'Silakan login ulang');
      return;
    }
    await followC.toggleFollow(
      viewerId: viewerId,
      targetUserId: targetUserId.value,
      currentlyFollowing: currentlyFollowing,
    );
  }

  Future<void> onTapProduct(ProductModel p) async {
    if (p.isDraft) {
      if (!isMe) return;

      final sellC = Get.find<SellController>();
      await sellC.loadDraft(p.id);

      Get.toNamed(Routes.editDraft, arguments: {'id': p.id});
      return;
    }

    if (isMe) {
      Get.toNamed(
        '${Routes.manageProduct}?id=${p.id}&seller_id=${targetUserId.value}',
      );
    } else {
      Get.toNamed(
        Routes.productDetail,
        arguments: {'id': p.id, 'seller_id': targetUserId.value},
      );
    }
  }

  void goFollowers(int initialIndex) {
    Get.toNamed(
      Routes.followersFollowing,
      arguments: {'userId': targetUserId.value, 'initialIndex': initialIndex},
    );
  }

  Future<void> openChatWithSeller({
    required String sellerId,
    required String sellerName,
    required String sellerPhoto,
  }) async {
    final myUid = SessionController.to.viewerId.value;

    if (myUid.isEmpty) {
      Get.snackbar('Info', 'Kamu belum login');
      return;
    }

    final sid = sellerId.trim();
    if (sid.isEmpty) {
      Get.snackbar('Error', 'sellerId kosong');
      return;
    }

    if (sid == myUid) {
      Get.snackbar('Info', 'Tidak bisa chat dengan diri sendiri');
      return;
    }

    try {
      final me = authC.user.value;
      final myName = (me?.username.isNotEmpty == true)
          ? me!.username
          : (me?.nama ?? 'Me');
      final myPhoto = me?.fotoProfilUrl ?? '';

      const productId = 'general';

      final chatRepo = Get.find<ChatRepository>();

      final threadId = await chatRepo.ensureThread(
        myUid: myUid,
        peerId: sid,
        productId: productId,
        productTitle: '',
        productImage: '',
        myName: myName,
        myPhoto: myPhoto,
        peerName: sellerName,
        peerPhoto: sellerPhoto,
      );

      Get.toNamed(
        Routes.chat,
        arguments: {
          'threadId': threadId,
          'peerId': sid,
          'productId': productId,
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka chat: $e');
    }
  }

  void bindRating(String sellerUid) {
    _reviewsSub?.cancel();

    _reviewsSub = repo
        .sellerReviewsSnap(sellerUid)
        .listen(
          (snap) {
            int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

            final docs = snap.docs;
            final total = docs.length;
            final counts = List<int>.filled(6, 0); // 1..5
            var sum = 0;

            for (final d in docs) {
              final r = toInt(d.data()['rating']).clamp(1, 5);
              counts[r]++;
              sum += r;
            }

            final avg = total == 0 ? 0.0 : sum / total;
            ratingSummary.value = RatingSummary(
              avg: avg,
              total: total,
              counts: counts,
            );
          },
          onError: (_) {
            ratingSummary.value = const RatingSummary(
              avg: 0,
              total: 0,
              counts: [0, 0, 0, 0, 0, 0],
            );
          },
        );
  }

  @override
  void onClose() {
    _targetUserWorker?.dispose();
    _reviewsSub?.cancel();
    super.onClose();
  }
}

class RatingSummary {
  final double avg;
  final int total;
  final List<int> counts; // index 1..5
  const RatingSummary({
    required this.avg,
    required this.total,
    required this.counts,
  });
}
