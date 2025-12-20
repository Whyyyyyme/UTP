import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/home_service.dart';

class HomeRepository {
  final HomeService _service;
  HomeRepository(this._service);

  // ✅ cart count = snap.size (lebih aman)
  Stream<int> cartCountStream(String viewerId) {
    if (viewerId.isEmpty) return Stream.value(0);
    return _service.cartItemsStream(viewerId).map((snap) => snap.size);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> hotItemsStream() {
    return _service.hotItemsStream();
  }

  // ✅ rekomendasi sellerId: ambil dari produk terbaru, unique, max 8
  Stream<List<String>> recommendedSellerIdsStream() {
    return _service.latestPublishedProductsStream().map((snap) {
      final ids = <String>{};
      for (final d in snap.docs) {
        final sid = (d.data()['seller_id'] ?? '').toString();
        if (sid.isNotEmpty) ids.add(sid);
        if (ids.length >= 8) break;
      }
      return ids.toList();
    });
  }

  // ✅ thumbs seller: output List<Map> biar UI gampang
  Stream<List<Map<String, dynamic>>> sellerThumbs(String sellerId) {
    return _service
        .sellerThumbsStream(sellerId)
        .map((snap) => snap.docs.map((e) => e.data()).toList());
  }

  Future<Map<String, dynamic>?> fetchUser(String uid) async {
    final q = await _service.userByUid(uid);
    if (q.docs.isEmpty) return null;
    return q.docs.first.data();
  }
}
