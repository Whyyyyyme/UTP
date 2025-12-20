import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String type; // text/system
  final String text;
  final String senderId;

  final Timestamp? createdAt; // server
  final Timestamp? createdAtClient; // client (untuk sorting stabil)

  const ChatMessageModel({
    required this.id,
    required this.type,
    required this.text,
    required this.senderId,
    required this.createdAt,
    required this.createdAtClient,
  });

  factory ChatMessageModel.fromDoc(String id, Map<String, dynamic> map) {
    return ChatMessageModel(
      id: id,
      type: (map['type'] ?? 'text').toString(),
      text: (map['text'] ?? '').toString(),
      senderId: (map['senderId'] ?? '').toString(),
      createdAt: map['createdAt'] as Timestamp?,
      createdAtClient: map['createdAtClient'] as Timestamp?,
    );
  }
}
