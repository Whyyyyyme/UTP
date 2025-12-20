import 'package:cloud_firestore/cloud_firestore.dart';

class NegoService {
  NegoService(this._db);
  final FirebaseFirestore _db;

  Future<void> createOffer({
    required String productId,
    required String buyerId,
    required String sellerId,
    required int originalPrice,
    required int offerPrice,
  }) async {
    await _db.collection('offers').add({
      'product_id': productId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'original_price': originalPrice,
      'offer_price': offerPrice,
      'status': 'pending', // pending/accepted/rejected
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  DocumentReference<Map<String, dynamic>> threadRef({
    required String uid,
    required String threadId,
  }) => _db.collection('users').doc(uid).collection('inbox').doc(threadId);

  CollectionReference<Map<String, dynamic>> messagesRef({
    required String uid,
    required String threadId,
  }) => threadRef(uid: uid, threadId: threadId).collection('messages');

  Future<bool> threadExists({
    required String uid,
    required String threadId,
  }) async {
    final snap = await threadRef(uid: uid, threadId: threadId).get();
    return snap.exists;
  }

  Future<void> createThreadIfMissing({
    required String uid,
    required String threadId,
    required Map<String, dynamic> data,
  }) async {
    final ref = threadRef(uid: uid, threadId: threadId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set(data, SetOptions(merge: true));
    }
  }

  Future<void> upsertThreadMeta({
    required String uid,
    required String threadId,
    required Map<String, dynamic> patch,
  }) {
    return threadRef(
      uid: uid,
      threadId: threadId,
    ).set(patch, SetOptions(merge: true));
  }

  Future<void> addSystemMessage({
    required String uid,
    required String threadId,
    required String senderId,
    required String text,
  }) {
    final now = FieldValue.serverTimestamp();
    return messagesRef(uid: uid, threadId: threadId).add({
      'type': 'system',
      'text': text,
      'senderId': senderId,
      'createdAt': now,
    });
  }
}
