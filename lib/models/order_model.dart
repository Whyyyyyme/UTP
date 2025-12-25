import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final List<String> sellerUids;
  final String status;

  final int subtotal;
  final int shippingFee;
  final int total;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerUids,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    this.createdAt,
    this.updatedAt,
  });

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};

    final sellers = (d['seller_uids'] is List)
        ? (d['seller_uids'] as List).map((e) => e.toString()).toList()
        : <String>[];

    return OrderModel(
      id: (d['order_id'] ?? doc.id).toString(),
      buyerId: (d['buyer_id'] ?? '').toString(),
      sellerUids: sellers,
      status: (d['status'] ?? '').toString(),
      subtotal: _toInt(d['subtotal']),
      shippingFee: _toInt(d['shipping_fee']),
      total: _toInt(d['total']),
      createdAt: d['created_at'] as Timestamp?,
      updatedAt: d['updated_at'] as Timestamp?,
    );
  }
}
