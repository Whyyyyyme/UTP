import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatService {
  ChatService(this._db);
  final FirebaseFirestore _db;

  // ====== PATHS ======
  DocumentReference<Map<String, dynamic>> threadRef({
    required String uid,
    required String threadId,
  }) => _db.collection('users').doc(uid).collection('inbox').doc(threadId);

  CollectionReference<Map<String, dynamic>> messagesRef({
    required String uid,
    required String threadId,
  }) => threadRef(uid: uid, threadId: threadId).collection('messages');

  // ====== STREAMS ======
  Stream<DocumentSnapshot<Map<String, dynamic>>> threadStream({
    required String uid,
    required String threadId,
  }) {
    return threadRef(uid: uid, threadId: threadId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream({
    required String uid,
    required String threadId,
  }) {
    // sorting stabil pakai createdAtClient
    return messagesRef(
      uid: uid,
      threadId: threadId,
    ).orderBy('createdAtClient', descending: false).snapshots();
  }

  // =====================================================
  // ✅ ENSURE THREAD META (wajib set participants di dua sisi)
  // =====================================================
  Future<void> ensureThreadMeta({
    required String myUid,
    required String peerId,
    required String threadId,
    required List<String> participants, // ✅ baru

    required String peerName,
    required String peerPhoto,
    required String myName,
    required String myPhoto,

    required String productId,
    required String productTitle,
    required String productImage,
  }) async {
    final now = FieldValue.serverTimestamp();

    final myDoc = threadRef(uid: myUid, threadId: threadId);
    final peerDoc = threadRef(uid: peerId, threadId: threadId);

    final myThread = {
      'participants': [myUid, peerId], // ✅ wajib untuk rules
      'peerId': peerId,
      'peerName': peerName.isEmpty ? 'user' : peerName,
      'peerPhoto': peerPhoto,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'lastMessage': '',
      'lastType': 'text',
      'updatedAt': now,
    };

    final peerThread = {
      'participants': [myUid, peerId], // ✅ wajib untuk rules
      'peerId': myUid,
      'peerName': myName.isEmpty ? 'user' : myName,
      'peerPhoto': myPhoto,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'lastMessage': '',
      'lastType': 'text',
      'updatedAt': now,
    };

    await myDoc.set(myThread, SetOptions(merge: true));
    await peerDoc.set(peerThread, SetOptions(merge: true));
  }

  // =====================================================
  // ✅ SEND TEXT (set thread meta dulu + participants, baru add message)
  // =====================================================

  Future<void> sendTextMessage({
    required String uid,
    required String peerId,
    required String threadId,
    required String text,
  }) async {
    final nowServer = FieldValue.serverTimestamp();
    final nowClient = Timestamp.now();

    await upsertThreadMeta(
      ownerUid: uid,
      threadId: threadId,
      data: {
        'threadId': threadId,
        'participants': [uid, peerId],
        'peerId': peerId,
        'updatedAt': nowServer,
      },
    );

    await upsertThreadMeta(
      ownerUid: peerId,
      threadId: threadId,
      data: {
        'threadId': threadId,
        'participants': [uid, peerId],
        'peerId': uid,
        'updatedAt': nowServer,
      },
    );

    // 2) SET MESSAGE + META PATCH VIA BATCH
    final msg = {
      'type': 'text',
      'text': text,
      'senderId': uid,
      'createdAt': nowServer,
      'createdAtClient': nowClient,
    };

    final myThread = threadRef(uid: uid, threadId: threadId);
    final peerThread = threadRef(uid: peerId, threadId: threadId);

    final myMsgRef = messagesRef(uid: uid, threadId: threadId).doc();
    final peerMsgRef = messagesRef(uid: peerId, threadId: threadId).doc();

    final metaPatch = {
      'lastMessage': text,
      'lastType': 'text',
      'updatedAt': nowServer,
    };

    final batch = _db.batch();

    batch.set(myMsgRef, msg);
    batch.set(peerMsgRef, msg);

    batch.set(myThread, metaPatch, SetOptions(merge: true));
    batch.set(peerThread, metaPatch, SetOptions(merge: true));

    try {
      await batch.commit();
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
      rethrow;
    }
  }

  Future<void> ensureThreadParticipants({
    required String myUid,
    required String peerId,
    required String threadId,
  }) async {
    final now = FieldValue.serverTimestamp();

    final myDoc = threadRef(uid: myUid, threadId: threadId);
    final peerDoc = threadRef(uid: peerId, threadId: threadId);

    final batch = _db.batch();

    batch.set(myDoc, {
      'participants': [myUid, peerId],
      'peerId': peerId,
      'updatedAt': now,
    }, SetOptions(merge: true));

    batch.set(peerDoc, {
      'participants': [myUid, peerId],
      'peerId': myUid,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await batch.commit();
  }

  // =====================================================
  // ✅ SYSTEM MESSAGE (juga update participants dulu)
  // =====================================================
  Future<void> sendSystemMessage({
    required String buyerId,
    required String sellerId,
    required String threadId,
    required List<String> participants, // ✅ baru
    required String text,
    required String senderId,
  }) async {
    final nowServer = FieldValue.serverTimestamp();
    final nowClient = Timestamp.now();

    // update thread meta dulu + participants
    final buyerMeta = {
      'participants': participants,
      'peerId': sellerId,
      'lastMessage': text,
      'lastType': 'system',
      'updatedAt': nowServer,
    };

    final sellerMeta = {
      'participants': participants,
      'peerId': buyerId,
      'lastMessage': text,
      'lastType': 'system',
      'updatedAt': nowServer,
    };

    await threadRef(
      uid: buyerId,
      threadId: threadId,
    ).set(buyerMeta, SetOptions(merge: true));
    await threadRef(
      uid: sellerId,
      threadId: threadId,
    ).set(sellerMeta, SetOptions(merge: true));

    // message
    final msg = {
      'type': 'system',
      'text': text,
      'senderId': senderId,
      'createdAt': nowServer,
      'createdAtClient': nowClient,
    };

    await messagesRef(uid: buyerId, threadId: threadId).add(msg);
    await messagesRef(uid: sellerId, threadId: threadId).add(msg);
  }

  // =====================================================
  // ✅ UPSERT OFFER (participants juga wajib)
  // =====================================================
  Future<void> upsertOffer({
    required String buyerId,
    required String sellerId,
    required String threadId,
    required List<String> participants,
    required int originalPrice,
    required int offerPrice,
    required String status,
  }) async {
    final now = FieldValue.serverTimestamp();

    final offerMap = {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'originalPrice': originalPrice,
      'offerPrice': offerPrice,
      'status': status,
    };

    final patch = {
      'participants': [buyerId, sellerId],
      'offer': offerMap,
      'lastType': 'offer',
      'lastMessage': status == 'pending'
          ? 'Offer baru'
          : status == 'accepted'
          ? 'Offer diterima'
          : 'Offer ditolak',
      'updatedAt': now,
    };

    await threadRef(
      uid: buyerId,
      threadId: threadId,
    ).set(patch, SetOptions(merge: true));
    await threadRef(
      uid: sellerId,
      threadId: threadId,
    ).set(patch, SetOptions(merge: true));
  }

  // =====================================================
  // ✅ UPDATE OFFER STATUS (participants juga wajib)
  // =====================================================
  Future<void> updateOfferStatus({
    required String buyerId,
    required String sellerId,
    required String threadId,
    required List<String> participants, // ✅ baru
    required String status,
  }) async {
    final now = FieldValue.serverTimestamp();

    final patch = {
      'participants': participants, // ✅
      'offer.status': status,
      'lastType': 'offer',
      'lastMessage': status == 'accepted' ? 'Offer diterima' : 'Offer ditolak',
      'updatedAt': now,
    };

    await threadRef(
      uid: buyerId,
      threadId: threadId,
    ).set(patch, SetOptions(merge: true));
    await threadRef(
      uid: sellerId,
      threadId: threadId,
    ).set(patch, SetOptions(merge: true));
  }

  Future<void> upsertThreadMeta({
    required String ownerUid, // uid dokumen inbox yang dituju (bisa peer)
    required String threadId,
    required Map<String, dynamic> data,
  }) async {
    final ref = threadRef(uid: ownerUid, threadId: threadId);

    try {
      // ✅ NO GET() → supaya tidak kena rule read owner-only
      await ref.set(data, SetOptions(merge: true));
      debugPrint('UPSERT THREAD SUCCESS ownerUid=$ownerUid');
    } catch (e, st) {
      debugPrint('UPSERT THREAD FAILED ownerUid=$ownerUid');
      debugPrint(e.toString());
      debugPrint(st.toString());
      rethrow;
    }
  }
}
