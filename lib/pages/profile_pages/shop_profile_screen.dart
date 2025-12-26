import 'package:cloud_firestore/cloud_firestore.dart';
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
      final sellerId = c.targetUserId.value;

      if (sellerId.isEmpty) {
        return const Scaffold(
          body: Center(child: Text('Seller tidak ditemukan')),
        );
      }
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

                          Obx(() {
                            final s = c.ratingSummary.value;

                            if (s.total == 0) {
                              return Row(
                                children: List.generate(
                                  5,
                                  (_) => Icon(
                                    Icons.star_border,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              );
                            }

                            return Row(
                              children: [
                                _StarRow(avg: s.avg),
                                const SizedBox(width: 8),
                                Text(
                                  '${s.avg.toStringAsFixed(1)} (${s.total})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          }),

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
                                    onPressed: () async {
                                      if (c.isMe) {
                                        Get.toNamed(Routes.sellProduct);
                                      } else {
                                        await c.openChatWithSeller(
                                          sellerId: c.targetUserId.value.trim(),
                                          sellerName: nama,
                                          sellerPhoto: foto,
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
            ReviewsTab(sellerUid: c.targetUserId.value),
          ],
        ),
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

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key, required this.sellerUid});
  final String sellerUid;

  int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerUid)
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text(
              'Gagal memuat ulasan: ${snap.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const _EmptyReviewsTab();

        final reviews = docs.map((d) => d.data()).toList(growable: false);

        // ===== hitung statistik =====
        final total = reviews.length;
        final counts = List<int>.filled(6, 0);
        var sum = 0;
        for (final r in reviews) {
          final rating = _toInt(r['rating']).clamp(1, 5);
          counts[rating]++;
          sum += rating;
        }
        final avg = total == 0 ? 0.0 : sum / total;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _RatingSummary(avg: avg, total: total, counts: counts),
            const SizedBox(height: 12),

            for (final r in reviews) _ReviewTile(data: r),
          ],
        );
      },
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.avg,
    required this.total,
    required this.counts,
  });

  final double avg;
  final int total;
  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    double frac(int c) => maxCount == 0 ? 0 : c / maxCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(Icons.star, color: Colors.blue, size: 26),
                  ),
                ],
              ),
              Text(
                '$total ratings',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((star) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 14, child: Text('$star')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: frac(counts[star]),
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.data});
  final Map<String, dynamic> data;

  int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  @override
  Widget build(BuildContext context) {
    final rating = _toInt(data['rating']).clamp(1, 5);
    final text = (data['text'] ?? '').toString();

    final buyerName = (data['buyer_name'] ?? 'Pembeli').toString();
    final buyerPhoto = (data['buyer_photo_url'] ?? '').toString();

    final productImage = (data['product_image_url'] ?? '').toString();

    final ts = data['created_at'];
    final dt = ts is Timestamp ? ts.toDate() : null;
    final timeText = dt == null ? '' : _timeAgoId(dt);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  size: 18,
                  color: (i + 1) <= rating ? Colors.blue : Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 8),
              Text(timeText, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          if (text.isNotEmpty)
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: buyerPhoto.isNotEmpty
                    ? NetworkImage(buyerPhoto)
                    : null,
                child: buyerPhoto.isEmpty
                    ? const Icon(Icons.person, color: Colors.black45)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  buyerName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 44,
                  color: Colors.grey.shade200,
                  child: productImage.isNotEmpty
                      ? Image.network(productImage, fit: BoxFit.cover)
                      : const Icon(Icons.image_outlined, color: Colors.black26),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}

String _timeAgoId(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()} bulan yang lalu';
  if (diff.inDays >= 1) return '${diff.inDays} hari yang lalu';
  if (diff.inHours >= 1) return '${diff.inHours} jam yang lalu';
  return 'baru saja';
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.avg});
  final double avg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final pos = i + 1;
        final icon = (avg >= pos)
            ? Icons.star
            : (avg >= pos - 0.5)
            ? Icons.star_half
            : Icons.star_border;

        return Icon(icon, color: Colors.amber, size: 20);
      }),
    );
  }
}
