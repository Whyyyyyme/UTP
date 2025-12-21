import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NegoService {
  NegoService(this._db);
  final FirebaseFirestore _db;

  // ===================== USERS =====================
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  // ===================== INBOX THREAD =====================
  DocumentReference<Map<String, dynamic>> threadRef({
    required String uid,
    required String threadId,
  }) {
    return _db.collection('users').doc(uid).collection('inbox').doc(threadId);
  }

  CollectionReference<Map<String, dynamic>> messagesRef({
    required String uid,
    required String threadId,
  }) {
    return threadRef(uid: uid, threadId: threadId).collection('messages');
  }

  Future<bool> threadExists({
    required String uid,
    required String threadId,
  }) async {
    try {
      final snap = await threadRef(uid: uid, threadId: threadId).get();
      return snap.exists;
    } catch (_) {
      // kalau peer inbox -> read forbidden -> dianggap "tidak bisa dicek"
      return false;
    }
  }

  /// ✅ CREATE THREAD kalau belum ada.
  /// Penting: untuk rules kamu, doc thread HARUS punya field `participants: [buyerId, sellerId]`
  Future<void> createThreadIfMissing({
    required String uid,
    required String threadId,
    required Map<String, dynamic> data,
  }) async {
    final ref = threadRef(uid: uid, threadId: threadId);

    try {
      await ref.set(data, SetOptions(merge: true));
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
      rethrow;
    }
  }

  /// ✅ UPDATE META THREAD (merge)
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

  /// ✅ SYSTEM MESSAGE (buat offer status atau notifikasi)
  /// Pakai createdAtClient supaya sorting stabil seperti ChatService kamu.
  Future<void> addSystemMessage({
    required String uid,
    required String threadId,
    required String senderId,
    required String text,
  }) {
    final nowServer = FieldValue.serverTimestamp();
    final nowClient = Timestamp.now();

    return messagesRef(uid: uid, threadId: threadId).add({
      'type': 'system',
      'text': text,
      'senderId': senderId,
      'createdAt': nowServer,
      'createdAtClient': nowClient,
    });
  }

  /// ✅ OFFER MESSAGE (opsional: kalau kamu mau “offer” jadi message type khusus)
  Future<void> addOfferMessage({
    required String uid,
    required String threadId,
    required String senderId,
    required Map<String, dynamic> offer,
  }) {
    final nowServer = FieldValue.serverTimestamp();
    final nowClient = Timestamp.now();

    return messagesRef(uid: uid, threadId: threadId).add({
      'type': 'offer',
      'senderId': senderId,
      'offer': offer,
      'createdAt': nowServer,
      'createdAtClient': nowClient,
    });
  }

  // ===================== OPTIONAL: OFFERS COLLECTION =====================
  Future<void> createOfferDoc({
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
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
