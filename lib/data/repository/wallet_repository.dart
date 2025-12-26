import '../services/wallet_service.dart';
import '../../models/wallet_model.dart';
import '../../models/wallet_transaction_model.dart';

class WalletRepository {
  WalletRepository({WalletService? service})
    : _service = service ?? WalletService();

  final WalletService _service;

  Stream<WalletModel> streamWallet(String uid) {
    return _service.walletSnap(uid).map((doc) {
      if (!doc.exists) return WalletModel.empty();
      return WalletModel.fromDoc(doc);
    });
  }

  Stream<List<WalletTransactionModel>> streamTransactions(
    String uid, {
    int limit = 50,
  }) {
    return _service
        .txSnap(uid, limit: limit)
        .map(
          (snap) =>
              snap.docs.map((d) => WalletTransactionModel.fromDoc(d)).toList(),
        );
  }
}
