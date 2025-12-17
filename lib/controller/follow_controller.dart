import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FollowController extends GetxController {
  final _db = FirebaseFirestore.instance;

  // ✅ cek apakah viewer follow target
  Stream<bool> isFollowingStream({
    required String viewerId,
    required String targetUserId,
  }) {
    return _db
        .collection('users')
        .doc(viewerId)
        .collection('following')
        .doc(targetUserId)
        .snapshots()
        .map((d) => d.exists);
  }

  // ✅ follow/unfollow (pakai batch biar atomic)
  Future<void> toggleFollow({
    required String viewerId,
    required String targetUserId,
    required bool currentlyFollowing,
  }) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');
    if (targetUserId.isEmpty) throw Exception('targetUserId kosong');
    if (viewerId == targetUserId)
      throw Exception('Tidak bisa follow diri sendiri');

    final followingRef = _db
        .collection('users')
        .doc(viewerId)
        .collection('following')
        .doc(targetUserId);

    final followerRef = _db
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(viewerId);

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

  // ✅ count realtime
  Stream<int> followersCountStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('followers')
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> followingCountStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .map((s) => s.size);
  }
}
