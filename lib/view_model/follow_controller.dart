import 'package:get/get.dart';
import '../data/repository/follow_repository.dart';
import '../data/repository/user_repository.dart';
import '../../models/user_model.dart';

class FollowController extends GetxController {
  FollowController({required this.repo, required this.userRepo});

  final FollowRepository repo;
  final UserRepository userRepo;

  // ===== STREAM FOLLOW =====
  Stream<bool> isFollowingStream({
    required String viewerId,
    required String targetUserId,
  }) => repo.isFollowingStream(viewerId: viewerId, targetUserId: targetUserId);

  Stream<int> followersCountStream(String userId) =>
      repo.followersCountStream(userId);

  Stream<int> followingCountStream(String userId) =>
      repo.followingCountStream(userId);

  Stream<List<String>> followersIdsStream(String userId) =>
      repo.followersIdsStream(userId);

  Stream<List<String>> followingIdsStream(String userId) =>
      repo.followingIdsStream(userId);

  // ===== USER =====
  Future<UserModel?> fetchUser(String uid) => userRepo.getUserByUid(uid);

  // ===== ACTION =====
  Future<(bool, String)> toggleFollow({
    required String viewerId,
    required String targetUserId,
    required bool currentlyFollowing,
  }) async {
    try {
      await repo.toggleFollow(
        viewerId: viewerId,
        targetUserId: targetUserId,
        currentlyFollowing: currentlyFollowing,
      );
      return (true, currentlyFollowing ? 'Unfollow' : 'Follow');
    } catch (e) {
      return (false, e.toString());
    }
  }
}
