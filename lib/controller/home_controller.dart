import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/auth_controller.dart';

class HomeController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // badge keranjang
  final cartCount = 0.obs;

  StreamSubscription? _cartSub;

  @override
  void onInit() {
    super.onInit();
    _listenCartCount();
  }

  void _listenCartCount() {
    // stop listener lama kalau ada
    _cartSub?.cancel();

    final user = AuthController.to.user.value;
    if (user == null) {
      cartCount.value = 0;
      return;
    }

    _cartSub = _db
        .collection('carts')
        .doc(user.id)
        .collection('items')
        .snapshots()
        .listen(
          (snap) {
            cartCount.value = snap.docs.length;
          },
          onError: (_) {
            // kalau permission/index error, jangan bikin crash
            cartCount.value = 0;
          },
        );
  }

  Stream<List<String>> recommendedSellerIdsStream() {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .orderBy('updated_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
          final ids = <String>{};
          for (final d in snap.docs) {
            final sid = (d.data()['seller_id'] ?? '').toString();
            if (sid.isNotEmpty) ids.add(sid);
            if (ids.length >= 8) break;
          }
          return ids.toList();
        });
  }

  // Hot items (published)
  Stream<QuerySnapshot<Map<String, dynamic>>> hotItemsStream() {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .orderBy('updated_at', descending: true)
        .limit(20)
        .snapshots();
  }

  // Ambil 3 produk terakhir seller buat thumbnail
  Stream<List<Map<String, dynamic>>> sellerThumbsStream(String sellerId) {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .where('seller_id', isEqualTo: sellerId)
        .orderBy('created_at', descending: true)
        .limit(3)
        .snapshots()
        .map((snap) => snap.docs.map((e) => e.data()).toList());
  }

  // Ambil user berdasarkan field uid (karena docId belum tentu uid)
  Future<Map<String, dynamic>?> fetchUser(String userId) async {
    final q = await _db
        .collection('users')
        .where('uid', isEqualTo: userId)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return null;
    return q.docs.first.data();
  }

  @override
  void onClose() {
    _cartSub?.cancel();
    super.onClose();
  }
}
