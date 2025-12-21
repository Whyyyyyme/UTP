import 'package:cloud_firestore/cloud_firestore.dart';
import 'offer_model.dart';

class ChatThreadModel {
  final String threadId;

  // lawan chat di sisi user ini
  final String peerId;
  final String peerName;
  final String peerPhoto;
  final String sellerId;

  // konteks produk
  final String productId;
  final String productTitle;
  final String productImage;

  // ringkasan terakhir
  final String lastMessage;
  final String lastType; // text/offer/system
  final Timestamp? updatedAt;

  // offer (opsional)
  final OfferModel? offer;

  const ChatThreadModel({
    required this.threadId,
    required this.peerId,
    required this.peerName,
    required this.peerPhoto,
    required this.sellerId,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.lastMessage,
    required this.lastType,
    required this.updatedAt,
    required this.offer,
  });

  factory ChatThreadModel.fromMap(String threadId, Map<String, dynamic> map) {
    final offerMap = map['offer'];
    return ChatThreadModel(
      threadId: threadId,
      peerId: (map['peerId'] ?? '').toString(),
      peerName: (map['peerName'] ?? 'user').toString(),
      peerPhoto: (map['peerPhoto'] ?? '').toString(),
      sellerId: (map['sellerId'] ?? '').toString(),
      productId: (map['productId'] ?? '').toString(),
      productTitle: (map['productTitle'] ?? '').toString(),
      productImage: (map['productImage'] ?? '').toString(),
      lastMessage: (map['lastMessage'] ?? '').toString(),
      lastType: (map['lastType'] ?? 'text').toString(),
      updatedAt: map['updatedAt'] as Timestamp?,
      offer: (offerMap is Map<String, dynamic>)
          ? OfferModel.fromMap(offerMap)
          : null,
    );
  }
}
