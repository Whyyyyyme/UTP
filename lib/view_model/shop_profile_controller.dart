import 'package:get/get.dart';

import 'package:prelovedly/models/product_model.dart';
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

    _readArgs();
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
}
