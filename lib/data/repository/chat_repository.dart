import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_message_model.dart';
import '../../models/chat_thread_model.dart';
import '../../utils/chat_thread_util.dart';
import '../services/chat_service.dart';

class ChatRepository {
  ChatRepository(this._service);
  final ChatService _service;

  // ========== STREAMS ==========
  Stream<ChatThreadModel?> threadStream({
    required String uid,
    required String threadId,
  }) {
    return _service.threadStream(uid: uid, threadId: threadId).map((doc) {
      if (!doc.exists) return null;
      return ChatThreadModel.fromMap(doc.id, doc.data() ?? {});
    });
  }

  Stream<List<ChatMessageModel>> messagesStream({
    required String uid,
    required String threadId,
  }) {
    return _service.messagesStream(uid: uid, threadId: threadId).map((snap) {
      return snap.docs
          .map((d) => ChatMessageModel.fromDoc(d.id, d.data()))
          .toList();
    });
  }

  Future<ChatThreadModel?> findOfferThreadForProduct({
    required String uid,
    required String peerId,
    required String productId,
  }) async {
    final snap = await _service.findThreadsByPeerAndProduct(
      uid: uid,
      peerId: peerId,
      productId: productId,
    );

    if (snap.docs.isEmpty) return null;

    final d = snap.docs.first;
    final model = ChatThreadModel.fromMap(d.id, d.data());

    if (model.offer == null) return null;

    return model;
  }

  Future<ChatThreadModel?> findLatestThreadWithSeller({
    required String uid,
    required String peerId,
  }) async {
    final snap = await _service.findLatestThreadByPeer(
      uid: uid,
      peerId: peerId,
    );

    if (snap.docs.isEmpty) return null;

    final d = snap.docs.first;
    return ChatThreadModel.fromMap(d.id, d.data());
  }

  Future<bool> hasAcceptedOfferWithSeller({
    required String uid,
    required String sellerId,
  }) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inbox')
        .where('sellerId', isEqualTo: sellerId)
        .where('offer.status', isEqualTo: 'accepted')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return false;

    final data = snap.docs.first.data();
    final offer = (data['offer'] as Map?) ?? {};
    final buyerId = (offer['buyerId'] ?? '').toString();
    final sId = (offer['sellerId'] ?? '').toString();

    return buyerId == uid && sId == sellerId;
  }

  // ========== ENSURE THREAD ==========
  /// ✅ 1 room untuk 1 pasangan user (tidak tergantung produk).
  /// productId/title/image hanya jadi "konteks terakhir".
  Future<String> ensureThread({
    required String myUid,
    required String peerId,

    required String productId,
    required String productTitle,
    required String productImage,

    required String myName,
    required String myPhoto,
    required String peerName,
    required String peerPhoto,
  }) async {
    // ✅ selalu DM id (buildThreadId kamu sudah diubah jadi dm_)
    final threadId = buildThreadId(
      uidA: myUid,
      uidB: peerId,
      productId: productId,
    );

    final participants = <String>[myUid, peerId];

    await _service.ensureThreadMeta(
      myUid: myUid,
      peerId: peerId,
      threadId: threadId,
      participants: participants,

      peerName: peerName,
      peerPhoto: peerPhoto,
      myName: myName,
      myPhoto: myPhoto,

      productId: productId,
      productTitle: productTitle,
      productImage: productImage,
    );

    return threadId;
  }

  // ========== SEND ==========
  Future<void> sendText({
    required String uid,
    required String peerId,
    required String threadId,
    required String text,
  }) async {
    // ✅ pastikan thread doc dua sisi punya participants (biar rules lolos)
    await _service.ensureThreadParticipants(
      myUid: uid,
      peerId: peerId,
      threadId: threadId,
    );

    // ✅ baru kirim message (service sudah batch write message + meta)
    return _service.sendTextMessage(
      uid: uid,
      peerId: peerId,
      threadId: threadId,
      text: text,
      // participants: participants,
    );
  }

  // ========== OFFER ==========
  Future<void> sendOffer({
    required String buyerId,
    required String sellerId,
    required String threadId,
    required int originalPrice,
    required int offerPrice,
  }) async {
    final participants = <String>[buyerId, sellerId];

    await _service.upsertOffer(
      buyerId: buyerId,
      sellerId: sellerId,
      threadId: threadId,
      participants: participants,
      originalPrice: originalPrice,
      offerPrice: offerPrice,
      status: 'pending',
    );

    await _service.sendSystemMessage(
      buyerId: buyerId,
      sellerId: sellerId,
      threadId: threadId,
      participants: participants,
      text: 'Offer baru dikirim.',
      senderId: buyerId,
    );
  }

  Future<void> acceptOffer({
    required String buyerId,
    required String sellerId,
    required String threadId,
  }) async {
    final participants = <String>[buyerId, sellerId];

    await _service.updateOfferStatus(
      buyerId: buyerId,
      sellerId: sellerId,
      threadId: threadId,
      participants: participants,
      status: 'accepted',
    );

    await _service.sendSystemMessage(
      buyerId: buyerId,
      sellerId: sellerId,
      threadId: threadId,
      participants: participants,
      text: 'Seller menerima offer.',
      senderId: sellerId,
    );
  }

  Future<void> rejectOffer({
    required String buyerId,
    required String sellerId,
    required String threadId,
  }) async {
    final participants = <String>[buyerId, sellerId];

    await _service.updateOfferStatus(
      buyerId: buyerId,
      sellerId: sellerId,
      threadId: threadId,
      participants: participants,
      status: 'rejected',
    );

    await _service.sendSystemMessage(
      buyerId: buyerId,
      sellerId: sellerId,
      threadId: threadId,
      participants: participants,
      text: 'Seller menolak offer.',
      senderId: sellerId,
    );
  }

  // ========== HELPER ==========
  Future<DocumentSnapshot<Map<String, dynamic>>> getThreadDoc({
    required String uid,
    required String threadId,
  }) {
    return _service.threadRef(uid: uid, threadId: threadId).get();
  }
}
