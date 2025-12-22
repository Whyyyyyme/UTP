import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUsers() {
    return _db
        .collection('users')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> setUserActive({
    required String uid,
    required bool isActive,
  }) async {
    await _db.collection('users').doc(uid).set({
      'is_active': isActive,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
