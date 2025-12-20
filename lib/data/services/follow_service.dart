import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  FollowService(this._db);
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> followingDoc({
    required String viewerId,
    required String targetUserId,
  }) => _userDoc(viewerId).collection('following').doc(targetUserId);

  DocumentReference<Map<String, dynamic>> followerDoc({
    required String viewerId,
    required String targetUserId,
  }) => _userDoc(targetUserId).collection('followers').doc(viewerId);

  Stream<bool> isFollowingStream({
    required String viewerId,
    required String targetUserId,
  }) {
    return followingDoc(
      viewerId: viewerId,
      targetUserId: targetUserId,
    ).snapshots().map((d) => d.exists);
  }

  Future<void> commitFollowBatch({
    required String viewerId,
    required String targetUserId,
    required bool currentlyFollowing,
  }) async {
    final followingRef = followingDoc(
      viewerId: viewerId,
      targetUserId: targetUserId,
    );
    final followerRef = followerDoc(
      viewerId: viewerId,
      targetUserId: targetUserId,
    );

    final batch = _db.batch();

    if (currentlyFollowing) {
      batch.delete(followingRef);
      batch.delete(followerRef);
    } else {
      batch.set(followingRef, {
        'following_id': targetUserId,
        'created_at': FieldValue.serverTimestamp(),
      });
      batch.set(followerRef, {
        'follower_id': viewerId,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Stream<int> followersCountStream(String userId) {
    return _userDoc(
      userId,
    ).collection('followers').snapshots().map((s) => s.size);
  }

  Stream<int> followingCountStream(String userId) {
    return _userDoc(
      userId,
    ).collection('following').snapshots().map((s) => s.size);
  }

  // ✅ TAMBAH: ambil list UID followers
  Stream<List<String>> followersIdsStream(String userId) {
    return _userDoc(userId)
        .collection('followers')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }

  // ✅ TAMBAH: ambil list UID following
  Stream<List<String>> followingIdsStream(String userId) {
    return _userDoc(userId)
        .collection('following')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }
}
