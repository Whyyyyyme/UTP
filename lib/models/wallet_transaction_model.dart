import 'package:cloud_firestore/cloud_firestore.dart';

class WalletTransactionModel {
  final String id;
  final String type;
  final int amount;
  final String orderId;
  final String buyerId;
  final Timestamp? createdAt;

  WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.orderId,
    required this.buyerId,
    this.createdAt,
  });

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  factory WalletTransactionModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return WalletTransactionModel(
      id: doc.id,
      type: (d['type'] ?? '').toString(),
      amount: _toInt(d['amount']),
      orderId: (d['order_id'] ?? '').toString(),
      buyerId: (d['buyer_id'] ?? '').toString(),
      createdAt: d['created_at'] as Timestamp?,
    );
  }
}
