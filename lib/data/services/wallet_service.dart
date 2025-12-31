import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  WalletService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> walletRef(String uid) =>
      _db.collection('wallets').doc(uid);

  CollectionReference<Map<String, dynamic>> txRef(String uid) =>
      _db.collection('wallets').doc(uid).collection('transactions');

  Stream<DocumentSnapshot<Map<String, dynamic>>> walletSnap(String uid) =>
      walletRef(uid).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> txSnap(
    String uid, {
    int limit = 50,
  }) => txRef(
    uid,
  ).orderBy('created_at', descending: true).limit(limit).snapshots();

  Future<int> withdrawAll({
    required String uid,
    required String bank,
    required String accountNumber,
  }) async {
    return _db.runTransaction((trx) async {
      final snap = await trx.get(walletRef(uid));
      final data = snap.data() ?? {};
      final raw = data['available_balance'];
      final balance = raw is int ? raw : int.tryParse('$raw') ?? 0;

      if (balance <= 0) {
        throw Exception('Saldo tidak mencukupi.');
      }

      trx.update(walletRef(uid), {
        'available_balance': 0,
        'updated_at': FieldValue.serverTimestamp(),
      });

      trx.set(txRef(uid).doc(), {
        'type': 'withdraw',
        'amount': balance,
        'order_id': '', // optional, karena withdraw tidak terkait order
        'buyer_id': '', // optional
        'bank': bank,
        'account_number': accountNumber,
        'created_at': FieldValue.serverTimestamp(),
      });

      return balance; // return saldo yang dicairkan
    });
  }
}
