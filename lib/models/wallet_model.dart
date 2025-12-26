import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final int availableBalance;
  final Timestamp? updatedAt;

  WalletModel({required this.availableBalance, this.updatedAt});

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  factory WalletModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return WalletModel(
      availableBalance: _toInt(d['available_balance']),
      updatedAt: d['updated_at'] as Timestamp?,
    );
  }

  factory WalletModel.empty() => WalletModel(availableBalance: 0);
}
