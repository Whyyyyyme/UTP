import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  CartService(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _itemsRef(String viewerId) =>
      _db.collection('carts').doc(viewerId).collection('items');

  // ===== STREAMS =====
  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream(String viewerId) {
    return _itemsRef(
      viewerId,
    ).orderBy('created_at', descending: true).snapshots();
  }

  Stream<bool> isInCartStream({
    required String viewerId,
    required String productId,
  }) {
    return _itemsRef(viewerId).doc(productId).snapshots().map((d) => d.exists);
  }

  // ===== PRODUCT READ =====
  Future<DocumentSnapshot<Map<String, dynamic>>> productDoc(String productId) {
    return _db.collection('products').doc(productId).get();
  }

  // ===== CART WRITE =====
  Future<void> setCartItem({
    required String viewerId,
    required String productId,
    required Map<String, dynamic> data,
  }) {
    return _itemsRef(
      viewerId,
    ).doc(productId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteCartItem({
    required String viewerId,
    required String productId,
  }) {
    return _itemsRef(viewerId).doc(productId).delete();
  }

  // ===== BULK OPS (murni firestore) =====

  /// Ambil semua doc item berdasarkan sellerId (untuk delete per seller)
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getItemsBySeller({
    required String viewerId,
    required String sellerId,
  }) async {
    final snap = await _itemsRef(
      viewerId,
    ).where('seller_id', isEqualTo: sellerId).get();
    return snap.docs;
  }

  /// Delete banyak doc pakai batch (dipakai clearCart / deleteBySeller)
  Future<void> batchDeleteDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final batch = _db.batch();
    for (final d in docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  Future<void> clearCart(String viewerId) async {
    final docs = await _itemsRef(viewerId).get().then((s) => s.docs);
    if (docs.isEmpty) return;
    await batchDeleteDocs(docs);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> userDoc(String uid) {
    return _db.collection('users').doc(uid).get();
  }
}
