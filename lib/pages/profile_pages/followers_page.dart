import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/auth_controller.dart';
import 'package:prelovedly/view_model/follow_controller.dart';
import 'package:prelovedly/models/user_model.dart';

class FollowersFollowingPage extends StatelessWidget {
  final String userId; // target profile
  final int initialIndex; // 0 followers, 1 following

  const FollowersFollowingPage({
    super.key,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final viewerId = AuthController.to.user.value?.id ?? '';

    // ✅ Wajibnya controller sudah dari binding AppPages.
    // Kalau belum, boleh fallback Get.put tapi harus kasih repo di constructor (jadi mending binding).
    final followC = Get.find<FollowController>();

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex.clamp(0, 1),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: const Text(' ', style: TextStyle(color: Colors.black)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(
                        child: StreamBuilder<int>(
                          stream: followC.followersCountStream(userId),
                          builder: (_, s) => Text(
                            '${s.data ?? 0} Followers',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Tab(
                        child: StreamBuilder<int>(
                          stream: followC.followingCountStream(userId),
                          builder: (_, s) => Text(
                            '${s.data ?? 0} Following',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _FollowList(
              mode: _FollowListMode.followers,
              profileUserId: userId,
              viewerId: viewerId,
              followC: followC,
            ),
            _FollowList(
              mode: _FollowListMode.following,
              profileUserId: userId,
              viewerId: viewerId,
              followC: followC,
            ),
          ],
        ),
      ),
    );
  }
}

enum _FollowListMode { followers, following }

class _FollowList extends StatelessWidget {
  final _FollowListMode mode;
  final String profileUserId;
  final String viewerId;
  final FollowController followC;

  const _FollowList({
    required this.mode,
    required this.profileUserId,
    required this.viewerId,
    required this.followC,
  });

  @override
  Widget build(BuildContext context) {
    final Stream<List<String>> stream = (mode == _FollowListMode.followers)
        ? followC.followersIdsStream(profileUserId)
        : followC.followingIdsStream(profileUserId);

    return StreamBuilder<List<String>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text(
              'Error: ${snap.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final ids = snap.data ?? [];
        if (ids.isEmpty) {
          return Center(
            child: Text(
              mode == _FollowListMode.followers
                  ? 'Belum ada followers'
                  : 'Belum ada following',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          itemCount: ids.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (context, i) {
            final otherUid = ids[i];
            return _UserRow(
              otherUid: otherUid,
              viewerId: viewerId,
              followC: followC,
            );
          },
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  final String otherUid;
  final String viewerId;
  final FollowController followC;

  const _UserRow({
    required this.otherUid,
    required this.viewerId,
    required this.followC,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: followC.fetchUser(otherUid), // ✅ no firestore in view
      builder: (context, snap) {
        final user = snap.data;

        final username = user?.username.isNotEmpty == true
            ? user!.username
            : otherUid;

        final nama = user?.nama ?? '';
        final foto = user?.fotoProfilUrl ?? '';

        final isMe = viewerId.isNotEmpty && viewerId == otherUid;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: foto.isNotEmpty ? NetworkImage(foto) : null,
                child: foto.isEmpty
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (nama.isNotEmpty)
                      Text(nama, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),

              if (!isMe)
                StreamBuilder<bool>(
                  stream: viewerId.isEmpty
                      ? Stream.value(false)
                      : followC.isFollowingStream(
                          viewerId: viewerId,
                          targetUserId: otherUid,
                        ),
                  builder: (context, s) {
                    final following = s.data == true;

                    return SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (viewerId.isEmpty) {
                            Get.snackbar(
                              'Login dulu',
                              'Sesi kamu habis, silakan login ulang',
                            );
                            return;
                          }

                          final (ok, msg) = await followC.toggleFollow(
                            viewerId: viewerId,
                            targetUserId: otherUid,
                            currentlyFollowing: following,
                          );

                          if (!ok) Get.snackbar('Gagal', msg);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: Text(following ? 'Following' : 'Follow'),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
