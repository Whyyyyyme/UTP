import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:prelovedly/view_model/cart_controller.dart';
import 'package:prelovedly/view_model/like_controller.dart';
import '../../data/repository/product_repository.dart';

class ProductDetailController extends GetxController {
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

  /// ✅ streams sudah sesuai repository versi baru
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

  // formatting helper
  String rp(dynamic value) {
    final v = value is int ? value : int.tryParse('$value') ?? 0;
    final f = NumberFormat.decimalPattern('id_ID').format(v);
    return 'Rp $f';
  }

  /// ✅ versi baru: terima dynamic (Timestamp / DateTime / String)
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

    // kalau Timestamp Firestore (tanpa import cloud_firestore),
    // biasanya tetap bisa dipanggil toDate() via dynamic
    try {
      final maybe = (v as dynamic);
      final hasToDate = maybe.toDate != null;
      if (hasToDate) {
        final DateTime dt = maybe.toDate();
        return dt;
      }
    } catch (_) {}

    if (v is DateTime) return v;

    if (v is String) {
      return DateTime.tryParse(v);
    }

    return null;
  }

  // actions
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

    final cartC = Get.find<CartController>(); // sudah global

    try {
      await cartC.addToCart(viewerId: uid, productId: productId);
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      rethrow;
    }
  }
}
