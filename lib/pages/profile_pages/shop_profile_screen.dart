import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/models/product_model.dart';

import '../../routes/app_routes.dart';
import '../../view_model/shop_profile_controller.dart';

import '../../widgets/profile/likes_tab.dart';
import '../profile_pages/followers_page.dart';

class ShopProfileScreen extends StatelessWidget {
  ShopProfileScreen({super.key});

  final c = Get.find<ShopProfileController>();

  Widget _bioSection(String bioRaw) {
    final bio = bioRaw.trim().isEmpty ? 'Tidak ada bio' : bioRaw.trim();
    const maxPreviewChars = 30;
    final isLong = bio.length > maxPreviewChars;

    return Obx(() {
      final expanded = c.showFullBio.value;
      final displayText = (isLong && !expanded)
          ? '${bio.substring(0, maxPreviewChars)}...'
          : bio;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayText,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          if (isLong)
            TextButton(
              onPressed: () => c.showFullBio.value = !c.showFullBio.value,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                expanded ? 'Sembunyikan' : 'Lihat semua',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = c.authC.user.value;
    if (me == null) {
      return const Scaffold(body: Center(child: Text('Kamu belum login')));
    }

    return DefaultTabController(
      length: 3,
      initialIndex: c.initialTabIndex.value,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Get.key.currentState?.canPop() ?? false) {
                Get.back();
              } else {
                Get.offNamed(Routes.profile);
              }
            },
          ),
          title: Obx(() {
            final isMe = c.isMe;
            return Text(
              isMe ? (me.username.isNotEmpty ? me.username : me.nama) : 'Shop',
            );
          }),
          actions: [
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
          centerTitle: true,
          bottom: const TabBar(
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Shop'),
              Tab(text: 'Likes'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ================= SHOP TAB =================
            StreamBuilder<Map<String, dynamic>?>(
              stream: c.targetUserStream(),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (userSnap.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat user: ${userSnap.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final u = userSnap.data ?? <String, dynamic>{};

                // kalau profil sendiri: pakai data auth (lebih akurat dan cepat)
                final nama = c.isMe
                    ? me.nama
                    : (u['nama'] ?? u['username'] ?? 'Seller').toString();
                final bio = c.isMe ? me.bio : (u['bio'] ?? '').toString();
                final foto = c.isMe
                    ? me.fotoProfilUrl
                    : (u['foto_profil_url'] ?? '').toString();

                return StreamBuilder<List<ProductModel>>(
                  stream: c.productsStream(),
                  builder: (context, snap) {
                    final loading =
                        snap.connectionState == ConnectionState.waiting;

                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Gagal memuat produk: ${snap.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final products = snap.data ?? const [];

                    final published = products
                        .where((p) => !p.isDraft)
                        .toList(growable: false);
                    final drafts = c.isMe
                        ? products
                              .where((p) => p.isDraft)
                              .toList(growable: false)
                        : <ProductModel>[];

                    final all = c.isMe ? [...published, ...drafts] : published;

                    final productCount = published.length;
                    final initial = nama.isNotEmpty
                        ? nama[0].toUpperCase()
                        : '?';

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== header + stats =====
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.orange,
                                backgroundImage: foto.isNotEmpty
                                    ? NetworkImage(foto)
                                    : null,
                                child: foto.isNotEmpty
                                    ? null
                                    : Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _StatItem(
                                          number: '$productCount',
                                          label: 'produk',
                                        ),

                                        InkWell(
                                          onTap: () {
                                            // kalau kamu masih pakai widget page langsung:
                                            Get.to(
                                              () => FollowersFollowingPage(
                                                userId: c.targetUserId.value,
                                                initialIndex: 0,
                                              ),
                                            );
                                          },
                                          child: StreamBuilder<int>(
                                            stream: c.followersCountStream(),
                                            builder: (_, s) => _StatItem(
                                              number: '${s.data ?? 0}',
                                              label: 'followers',
                                            ),
                                          ),
                                        ),

                                        InkWell(
                                          onTap: () {
                                            Get.to(
                                              () => FollowersFollowingPage(
                                                userId: c.targetUserId.value,
                                                initialIndex: 1,
                                              ),
                                            );
                                          },
                                          child: StreamBuilder<int>(
                                            stream: c.followingCountStream(),
                                            builder: (_, s) => _StatItem(
                                              number: '${s.data ?? 0}',
                                              label: 'following',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // rating dummy
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                Icons.star_border,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          _bioSection(bio),

                          const SizedBox(height: 24),

                          // ===== buttons =====
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  if (c.isMe) {
                                    return ElevatedButton(
                                      onPressed: () =>
                                          Get.toNamed(Routes.editProfile),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Edit profil'),
                                    );
                                  }

                                  return StreamBuilder<bool>(
                                    stream: c.isFollowingStream(),
                                    builder: (_, fs) {
                                      final following = fs.data == true;
                                      return ElevatedButton(
                                        onPressed: () => c.toggleFollow(
                                          currentlyFollowing: following,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: following
                                              ? Colors.grey[200]
                                              : Colors.blue,
                                          foregroundColor: following
                                              ? Colors.black
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          following ? 'Following' : 'Follow',
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Obx(() {
                                  return ElevatedButton(
                                    onPressed: () {
                                      if (c.isMe) {
                                        Get.toNamed(Routes.sellProduct);
                                      } else {
                                        Get.snackbar(
                                          'Message',
                                          'Fitur message belum dihubungkan',
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      c.isMe ? 'Upload produk' : 'Message',
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ===== grid =====
                          if (loading)
                            const Center(child: CircularProgressIndicator())
                          else if (all.isEmpty)
                            Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/eyes.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum ada item',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: all.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                              itemBuilder: (_, i) {
                                final p = all[i];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => c.onTapProduct(p),
                                  child: _ProductCard(p: p),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // ================= LIKES TAB =================
            LikesTab(viewerId: c.viewerId, likeC: c.likeC),

            // ================= REVIEWS TAB =================
            const _EmptyReviewsTab(),
          ],
        ),
      ),
    );
  }
}

class _EmptyReviewsTab extends StatelessWidget {
  const _EmptyReviewsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.star_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada ulasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel p;
  const _ProductCard({required this.p});

  @override
  Widget build(BuildContext context) {
    final img = p.imageUrls.isNotEmpty ? p.imageUrls.first : '';

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
            image: img.isNotEmpty
                ? DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)
                : null,
          ),
        ),
        if (p.isDraft)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black45,
              ),
              child: const Center(
                child: Text(
                  'DRAFT',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
