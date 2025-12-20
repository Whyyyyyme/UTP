import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  final FirebaseFirestore _db;
  HomeService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // carts/{viewerId}/items
  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream(String viewerId) {
    return _db
        .collection('carts')
        .doc(viewerId)
        .collection('items')
        .snapshots();
  }

  // products: published + updated_at
  Stream<QuerySnapshot<Map<String, dynamic>>> hotItemsStream() {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .orderBy('updated_at', descending: true)
        .limit(20)
        .snapshots();
  }

  // products: untuk rekomendasi sellerId (ambil banyak lalu dipilih di repo)
  Stream<QuerySnapshot<Map<String, dynamic>>> latestPublishedProductsStream() {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .orderBy('updated_at', descending: true)
        .limit(50)
        .snapshots();
  }

  // products: thumbnail per seller (3 produk terakhir)
  Stream<QuerySnapshot<Map<String, dynamic>>> sellerThumbsStream(
    String sellerId,
  ) {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .where('seller_id', isEqualTo: sellerId)
        .orderBy('created_at', descending: true)
        .limit(3)
        .snapshots();
  }

  // users: fetch by field uid
  Future<QuerySnapshot<Map<String, dynamic>>> userByUid(String uid) {
    return _db.collection('users').where('uid', isEqualTo: uid).limit(1).get();
  }
}
