import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void onInit() {
    super.onInit();
    authC = Get.find<AuthController>();
    followC = Get.find<FollowController>();
    likeC = Get.find<LikeController>();

    _resolveSellerIdFromRoute();
    _readArgs();
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

    if (sid.isEmpty) {
      // kalau masih kosong, jangan set apa-apa
      return;
    }

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

  // ===== streams untuk view =====
  Stream<Map<String, dynamic>?> targetUserStream() {
    // kalau profil sendiri tetap boleh stream, tapi view bisa pakai authC.user juga
    return repo.userByUidStream(targetUserId.value);
  }

  Stream<List<ProductModel>> productsStream() {
    return repo.sellerProducts(userId: targetUserId.value, isMe: isMe);
  }

  Stream<bool> isFollowingStream() {
    if (viewerId.isEmpty || targetUserId.value.isEmpty)
      return Stream.value(false);
    return followC.isFollowingStream(
      viewerId: viewerId,
      targetUserId: targetUserId.value,
    );
  }

  Stream<int> followersCountStream() =>
      followC.followersCountStream(targetUserId.value);

  Stream<int> followingCountStream() =>
      followC.followingCountStream(targetUserId.value);

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
    // draft hanya boleh untuk owner sendiri
    if (p.isDraft) {
      if (!isMe) return;

      // SellController harus sudah di-register (binding _ensureSell)
      final sellC = Get.find<SellController>();
      await sellC.loadDraft(p.id);

      Get.toNamed(Routes.editDraft, arguments: {'id': p.id});
      return;
    }

    // published
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

    if (sellerId.trim().isEmpty) {
      Get.snackbar('Error', 'sellerId kosong');
      return;
    }

    if (sellerId == myUid) {
      Get.snackbar('Info', 'Tidak bisa chat dengan diri sendiri');
      return;
    }

    try {
      final db = FirebaseFirestore.instance;

      // ambil data saya
      final myDoc = await db.collection('users').doc(myUid).get();
      final my = myDoc.data() ?? {};

      final myName = (my['username'] ?? my['nama'] ?? my['name'] ?? 'user')
          .toString();
      final myPhoto = (my['foto_profil_url'] ?? my['photoUrl'] ?? '')
          .toString();

      const productId = 'general';

      final chatRepo = Get.find<ChatRepository>();

      final threadId = await chatRepo.ensureThread(
        myUid: myUid,
        peerId: sellerId,
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
          'peerId': sellerId,
          'productId': productId,
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka chat: $e');
    }
  }
}
