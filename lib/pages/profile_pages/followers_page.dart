import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/controller/follow_controller.dart';

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

    final followC = Get.isRegistered<FollowController>()
        ? Get.find<FollowController>()
        : Get.put(FollowController(), permanent: true);

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
  final String profileUserId; // user yg lagi dibuka listnya
  final String viewerId; // user login
  final FollowController followC;

  const _FollowList({
    required this.mode,
    required this.profileUserId,
    required this.viewerId,
    required this.followC,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    final col = (mode == _FollowListMode.followers) ? 'followers' : 'following';

    final stream = db
        .collection('users')
        .doc(profileUserId)
        .collection(col)
        .orderBy('created_at', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
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
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (context, i) {
            final otherUid = docs[i].id; // docId = uid user lain
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
    final db = FirebaseFirestore.instance;

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: db
          .collection('users')
          .where('uid', isEqualTo: otherUid)
          .limit(1)
          .get(),
      builder: (context, snap) {
        final data = (snap.data?.docs.isNotEmpty ?? false)
            ? snap.data!.docs.first.data()
            : <String, dynamic>{};

        final username = (data['username'] ?? otherUid).toString();
        final nama = (data['nama'] ?? '').toString();
        final foto = (data['foto_profil_url'] ?? '').toString();

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
                          try {
                            await followC.toggleFollow(
                              viewerId: viewerId,
                              targetUserId: otherUid,
                              currentlyFollowing: following,
                            );
                          } catch (e) {
                            Get.snackbar('Gagal', e.toString());
                          }
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
