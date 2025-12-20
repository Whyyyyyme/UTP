import '../services/follow_service.dart';

class FollowRepository {
  FollowRepository(this._service);
  final FollowService _service;

  Stream<bool> isFollowingStream({
    required String viewerId,
    required String targetUserId,
  }) => _service.isFollowingStream(
    viewerId: viewerId,
    targetUserId: targetUserId,
  );

  Stream<int> followersCountStream(String userId) =>
      _service.followersCountStream(userId);

  Stream<int> followingCountStream(String userId) =>
      _service.followingCountStream(userId);

  // ✅ TAMBAH
  Stream<List<String>> followersIdsStream(String userId) =>
      _service.followersIdsStream(userId);

  // ✅ TAMBAH
  Stream<List<String>> followingIdsStream(String userId) =>
      _service.followingIdsStream(userId);

  Future<void> toggleFollow({
    required String viewerId,
    required String targetUserId,
    required bool currentlyFollowing,
  }) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');
    if (targetUserId.isEmpty) throw Exception('targetUserId kosong');
    if (viewerId == targetUserId) {
      throw Exception('Tidak bisa follow diri sendiri');
    }

    await _service.commitFollowBatch(
      viewerId: viewerId,
      targetUserId: targetUserId,
      currentlyFollowing: currentlyFollowing,
    );
  }
}
