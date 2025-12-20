import 'package:cloud_firestore/cloud_firestore.dart';

class InboxService {
  InboxService(this._db);
  final FirebaseFirestore _db;

  /// public ref (repository boleh pakai)
  CollectionReference<Map<String, dynamic>> inboxRef(String uid) {
    return _db.collection('users').doc(uid).collection('inbox');
  }

  /// stream inbox, urut terbaru
  Stream<QuerySnapshot<Map<String, dynamic>>> inboxStream(
    String uid, {
    int? limit,
  }) {
    if (uid.trim().isEmpty) {
      // biar gak nge-query uid kosong (lebih aman)
      return const Stream.empty();
    }

    var q = inboxRef(uid).orderBy('updatedAt', descending: true);

    if (limit != null && limit > 0) {
      q = q.limit(limit);
    }

    return q.snapshots();
  }
}
