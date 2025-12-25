import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  CartService(this._db);

  final FirebaseFirestore _db;

  // ✅ selalu pakai AUTH UID sebagai docId carts
  String authUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('Belum login (auth uid kosong)');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _itemsRef() =>
      _db.collection('carts').doc(authUid()).collection('items');

  // ===== STREAMS =====
  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream() {
    return _itemsRef().orderBy('created_at', descending: true).snapshots();
  }

  Stream<bool> isInCartStream({required String productId}) {
    return _itemsRef().doc(productId).snapshots().map((d) => d.exists);
  }

  // ===== PRODUCT READ =====
  Future<DocumentSnapshot<Map<String, dynamic>>> productDoc(String productId) {
    return _db.collection('products').doc(productId).get();
  }

  // ===== CART WRITE =====
  Future<void> setCartItem({
    required String productId,
    required Map<String, dynamic> data,
  }) {
    return _itemsRef().doc(productId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteCartItem({required String productId}) {
    return _itemsRef().doc(productId).delete();
  }

  // ===== BULK OPS =====

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getItemsBySeller({
    required String sellerId,
  }) async {
    final snap = await _itemsRef()
        .where('seller_id', isEqualTo: sellerId)
        .get();
    return snap.docs;
  }

  Future<void> batchDeleteDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final batch = _db.batch();
    for (final d in docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  Future<void> clearCart() async {
    final docs = await _itemsRef().get().then((s) => s.docs);
    if (docs.isEmpty) return;
    await batchDeleteDocs(docs);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> userDoc() {
    return _db.collection('users').doc(authUid()).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> userDocByUid(
    String authUid,
  ) async {
    final q = await _db
        .collection('users')
        .where('uid', isEqualTo: authUid)
        .limit(1)
        .get();

    if (q.docs.isEmpty) {
      throw Exception('User dengan uid=$authUid tidak ditemukan');
    }
    return q.docs.first.reference.get();
  }
}
