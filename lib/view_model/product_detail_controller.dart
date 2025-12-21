import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:prelovedly/data/repository/chat_repository.dart';
import 'package:prelovedly/data/services/chat_service.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/auth_controller.dart';

import 'package:prelovedly/view_model/cart_controller.dart';
import 'package:prelovedly/view_model/like_controller.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import '../../data/repository/product_repository.dart';

class ProductDetailController extends GetxController {
  final AuthController authC = Get.find<AuthController>();
  final ProductRepository _repo;

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

  Stream<List<Map<String, dynamic>>> otherFromSellerStream(String sellerId) {
    return _repo.otherFromSellerStream(
      sellerId: sellerId,
      excludeProductId: productId.value,
    );
  }

  Stream<List<Map<String, dynamic>>> youMayLikeStream() {
    return _repo.youMayLikeStream(excludeProductId: productId.value);
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

  /// ✅ FIX: chat tidak bikin room per produk lagi (1 room per 2 user).
  /// productId/title/image hanya jadi konteks terakhir yang diupdate.
  Future<void> openChatFromProduct({
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

    if (sellerId.trim().isEmpty) {
      Get.snackbar('Error', 'sellerId kosong');
      return;
    }

    if (sellerId == myUid) {
      Get.snackbar('Info', 'Tidak bisa chat dengan diri sendiri');
      return;
    }

    // pastikan dependency ada (kalau belum di-bind oleh route)
    if (!Get.isRegistered<ChatService>()) {
      Get.lazyPut(() => ChatService(FirebaseFirestore.instance), fenix: true);
    }
    if (!Get.isRegistered<ChatRepository>()) {
      Get.lazyPut(() => ChatRepository(Get.find<ChatService>()), fenix: true);
    }

    final chatRepo = Get.find<ChatRepository>();

    // data saya
    final me = authC.user.value;
    final myName = (me?.username.isNotEmpty == true)
        ? me!.username
        : (me?.nama ?? 'Me');
    final myPhoto = me?.fotoProfilUrl ?? '';

    // data seller
    final seller = await getSellerUser(sellerId);
    final sellerName = (seller['username'] ?? seller['nama'] ?? 'Seller')
        .toString();
    final sellerPhoto = (seller['foto_profil_url'] ?? '').toString();

    // ✅ penting: threadId didapat dari repo (1 room per buyer-seller)
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

    // buka chat
    Get.toNamed(
      Routes.chat,
      arguments: {
        'threadId': threadId,
        'peerId': sellerId,
        'productId': productId, // ini boleh tetap dikirim sebagai konteks UI
      },
    );
  }
}
