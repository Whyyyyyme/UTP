import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prelovedly/models/user_meta_model.dart';
import 'package:prelovedly/utils/chat_thread_util.dart';
import '../services/nego_service.dart';

class NegoRepository {
  NegoRepository(this._service);
  final NegoService _service;

  Future<UserMeta> getUserMeta(String uid) async {
    final raw = await _service.getUser(uid);

    if (raw == null) {
      return const UserMeta(name: 'User', photoUrl: '');
    }

    return UserMeta(
      name: (raw['username'] ?? raw['nama'] ?? 'User').toString(),
      photoUrl: (raw['foto_profil_url'] ?? '').toString(),
    );
  }

  /// ✅ bikin thread kalau belum ada, return threadId
  Future<String> ensureThreadId({
    required String buyerId,
    required String sellerId,
    required String productId,
    required String productTitle,
    required String productImage,
    required int originalPrice,
    required String buyerName,
    required String buyerPhoto,
    required String sellerName,
    required String sellerPhoto,
  }) async {
    if (buyerId.isEmpty) throw Exception('buyerId kosong');
    if (sellerId.isEmpty) throw Exception('sellerId kosong');
    if (productId.isEmpty) throw Exception('productId kosong');

    final threadId = buildThreadId(
      uidA: buyerId,
      uidB: sellerId,
      productId: productId,
    );

    final now = FieldValue.serverTimestamp();

    final participants = <String>[buyerId, sellerId];

    // data untuk buyer inbox
    final buyerThreadData = {
      'threadId': threadId,
      'participants': participants,
      'peerId': sellerId,
      'peerName': sellerName,
      'peerPhoto': sellerPhoto,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'lastMessage': '',
      'lastType': 'text',
      'updatedAt': now,
      'unreadCount': 0,
    };

    // data untuk seller inbox
    final sellerThreadData = {
      'threadId': threadId,
      'participants': participants,
      'peerId': buyerId,
      'peerName': buyerName,
      'peerPhoto': buyerPhoto,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'lastMessage': '',
      'lastType': 'text',
      'updatedAt': now,
      'unreadCount': 0,
    };

    // create if missing (dua sisi)
    await _service.createThreadIfMissing(
      uid: buyerId,
      threadId: threadId,
      data: buyerThreadData,
    );
    await _service.createThreadIfMissing(
      uid: sellerId,
      threadId: threadId,
      data: sellerThreadData,
    );

    return threadId;
  }

  /// TIDAK DIGUNAKAN
  Future<void> sendOffer({
    required String threadId,
    required String productId,
    required String buyerId,
    required String sellerId,
    required int originalPrice,
    required int offerPrice,
  }) async {
    final now = FieldValue.serverTimestamp();

    // ✅ WAJIB untuk rules (aman walau doc belum ada / dianggap create)
    final participants = <String>[buyerId, sellerId];

    final offerMap = {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'productId': productId,
      'originalPrice': originalPrice,
      'offerPrice': offerPrice,
      'status': 'pending',
      'createdAt': now,
    };

    final patch = {
      'participants': participants, // ✅ tambah biar aman
      'offer': offerMap,
      'lastType': 'offer',
      'lastMessage': 'Offer baru',
      'updatedAt': now,
    };

    // update thread meta dua sisi
    await _service.upsertThreadMeta(
      uid: buyerId,
      threadId: threadId,
      patch: patch,
    );
    await _service.upsertThreadMeta(
      uid: sellerId,
      threadId: threadId,
      patch: patch,
    );

    // system message dua sisi
    await _service.addSystemMessage(
      uid: buyerId,
      threadId: threadId,
      senderId: buyerId,
      text: 'Kamu mengirim offer.',
    );
    await _service.addSystemMessage(
      uid: sellerId,
      threadId: threadId,
      senderId: buyerId,
      text: 'Pembeli mengirim offer.',
    );
  }
}
