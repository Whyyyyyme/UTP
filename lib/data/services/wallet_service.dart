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
}
