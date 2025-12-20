import 'package:cloud_firestore/cloud_firestore.dart';

class InboxThreadModel {
  final String threadId;
  final String peerId;
  final String peerUsername;
  final String peerPhoto;
  final String productId;

  final String lastMessage;
  final String lastType;
  final String offerStatus;

  final DateTime? lastTime;
  final int unreadCount;
  final String type;

  InboxThreadModel({
    required this.threadId,
    required this.peerId,
    required this.peerUsername,
    required this.peerPhoto,
    required this.productId,
    required this.lastMessage,
    required this.lastType,
    required this.offerStatus,
    required this.lastTime,
    required this.unreadCount,
    required this.type,
  });

  factory InboxThreadModel.fromMap(String id, Map<String, dynamic> map) {
    final offer = (map['offer'] is Map)
        ? Map<String, dynamic>.from(map['offer'] as Map)
        : <String, dynamic>{};

    DateTime? time;
    final ts = map['updatedAt'];
    if (ts is Timestamp) time = ts.toDate();

    return InboxThreadModel(
      threadId: id,
      peerId: (map['peerId'] ?? '').toString(),
      peerUsername: (map['peerName'] ?? map['peerUsername'] ?? '').toString(),
      peerPhoto: (map['peerPhoto'] ?? '').toString(),
      productId: (map['productId'] ?? '').toString(),
      lastMessage: (map['lastMessage'] ?? '').toString(),
      lastType: (map['lastType'] ?? 'text').toString(),
      offerStatus: (offer['status'] ?? '').toString(),
      lastTime: time,
      unreadCount: (map['unreadCount'] is int)
          ? map['unreadCount'] as int
          : int.tryParse('${map['unreadCount']}') ?? 0,
      type: (map['type'] ?? 'chat').toString(),
    );
  }
}
