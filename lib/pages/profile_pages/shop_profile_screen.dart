import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/controller/like_controller.dart';
import 'package:prelovedly/controller/sell_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/profile/likes_tab.dart';

class ShopProfileScreen extends StatelessWidget {
  final int initialTabIndex;

  ShopProfileScreen({super.key, this.initialTabIndex = 0});

  final RxBool showFullBio = false.obs;

  Widget _buildBioSection(String bioRaw) {
    final String bio = bioRaw.trim().isEmpty ? 'Tidak ada bio' : bioRaw.trim();

    const int maxPreviewChars = 30;
    final bool isLong = bio.length > maxPreviewChars;

    return Obx(() {
      final bool expanded = showFullBio.value;

      final String displayText = (isLong && !expanded)
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
              onPressed: () => showFullBio.value = !showFullBio.value,
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

  /// ✅ Tab Shop (mode sendiri vs orang lain)
  Widget _buildShopTab({
    required String viewerId, // user login
    required String userId, // target profile
    required bool isMe,
    required String nama,
    required String bio,
    required String fotoProfilUrl,
  }) {
    final String initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    // ✅ Query produk:
    // - kalau diri sendiri: tampilkan semua (published + draft), urut created_at
    // - kalau orang lain: hanya published, urut updated_at (biar pakai index kamu)
    final Stream<QuerySnapshot<Map<String, dynamic>>> productStream = isMe
        ? FirebaseFirestore.instance
              .collection('products')
              .where('seller_id', isEqualTo: userId)
              .orderBy('created_at', descending: true)
              .snapshots()
        : FirebaseFirestore.instance
              .collection('products')
              .where('seller_id', isEqualTo: userId)
              .where('status', isEqualTo: 'published')
              .orderBy('updated_at', descending: true)
              .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: productStream,
      builder: (context, snapshot) {
        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Gagal memuat produk: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final products = docs
            .map((d) => ShopProduct.fromDoc(d))
            .toList(growable: false);

        final published = products
            .where((p) => !p.isDraft)
            .toList(growable: false);
        final drafts = isMe
            ? products.where((p) => p.isDraft).toList(growable: false)
            : <ShopProduct>[];

        final allProducts = isMe ? [...published, ...drafts] : published;

        final int productCount = published.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============== HEADER PROFIL + STAT ==============
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange,
                    backgroundImage: fotoProfilUrl.isNotEmpty
                        ? NetworkImage(fotoProfilUrl)
                        : null,
                    child: fotoProfilUrl.isNotEmpty
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatItemWidget(
                              number: productCount.toString(),
                              label: 'produk',
                            ),
                            const StatItemWidget(
                              number: '0',
                              label: 'followers',
                            ), // TODO
                            const StatItemWidget(
                              number: '0',
                              label: 'following',
                            ), // TODO
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
                  (index) => Icon(Icons.star_border, color: Colors.grey[400]),
                ),
              ),

              const SizedBox(height: 8),

              _buildBioSection(bio),

              const SizedBox(height: 24),

              // ============== BUTTONS (beda mode) ==============
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isMe) {
                          Get.toNamed(Routes.editProfile);
                        } else {
                          // TODO: follow/unfollow
                          Get.snackbar(
                            'Follow',
                            'Fitur follow belum dihubungkan',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMe ? Colors.grey[200] : Colors.blue,
                        foregroundColor: isMe ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(isMe ? 'Edit profil' : 'Follow'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isMe) {
                          Get.toNamed(Routes.sellProduct);
                        } else {
                          // TODO: message/chat
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
                      child: Text(isMe ? 'Upload produk' : 'Message'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ============== GRID PRODUK / EMPTY STATE ==============
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (allProducts.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/eyes.png', width: 100, height: 100),
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
                  itemCount: allProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final product = allProducts[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        // ✅ draft hanya boleh dibuka kalau diri sendiri
                        if (product.isDraft) {
                          if (!isMe) return;

                          final sell = Get.isRegistered<SellController>()
                              ? Get.find<SellController>()
                              : Get.put(SellController());

                          await sell.loadDraft(product.id);
                          Get.toNamed(
                            Routes.editDraft,
                            arguments: {"id": product.id},
                          );
                          return;
                        }

                        // ✅ published:
                        if (isMe) {
                          // profil sendiri -> manage product
                          Get.toNamed(
                            '${Routes.manageProduct}?id=${product.id}&seller_id=$userId',
                          );
                        } else {
                          // profil orang lain -> detail product
                          Get.toNamed(
                            Routes.productDetail,
                            arguments: {"id": product.id, "seller_id": userId},
                          );
                        }
                      },

                      child: _ProductCard(product: product),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showMenuBottomSheet(BuildContext context, {required bool isMe}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share'),
                onTap: () => Navigator.pop(context),
              ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit profil'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(Routes.editProfile);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final args = Get.arguments;

    final int initialIndexFromArgs =
        (args is Map && args['initialTabIndex'] is int)
        ? args['initialTabIndex'] as int
        : initialTabIndex;

    final int initialIndex =
        (initialIndexFromArgs < 0 || initialIndexFromArgs > 2)
        ? 0
        : initialIndexFromArgs;

    return Obx(() {
      final me = authC.user.value;
      if (me == null) {
        return const Scaffold(body: Center(child: Text('Kamu belum login')));
      }

      // ✅ viewerId = user login
      final String viewerId = me.id;

      // ✅ target profile id (kalau ada arg seller_id / userId -> buka seller itu)
      final String targetUserId =
          (args is Map && (args['seller_id'] != null || args['userId'] != null))
          ? ((args['seller_id'] ?? args['userId']).toString())
          : me.id;

      final bool isMe = targetUserId == me.id;

      return DefaultTabController(
        length: 3,
        initialIndex: initialIndex,
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
            title: Text(
              isMe ? (me.username.isNotEmpty ? me.username : me.nama) : 'Shop',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMenuBottomSheet(context, isMe: isMe),
              ),
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

          body: isMe
              ? TabBarView(
                  children: [
                    _buildShopTab(
                      viewerId: viewerId,
                      userId: viewerId,
                      isMe: true,
                      nama: me.nama,
                      bio: me.bio,
                      fotoProfilUrl: me.fotoProfilUrl,
                    ),

                    // ✅ FIX: pakai viewerId yang sudah didefinisikan
                    LikesTab(
                      viewerId: viewerId,
                      likeC: Get.find<LikeController>(),
                    ),

                    const EmptyReviewsTab(),
                  ],
                )
              : FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('uid', isEqualTo: targetUserId)
                      .limit(1)
                      .get(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          'Gagal memuat user: ${snap.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final data = (snap.data?.docs.isNotEmpty == true)
                        ? snap.data!.docs.first.data()
                        : <String, dynamic>{};

                    final nama = (data['nama'] ?? data['username'] ?? 'Seller')
                        .toString();
                    final bio = (data['bio'] ?? '').toString();
                    final foto = (data['foto_profil_url'] ?? '').toString();

                    return TabBarView(
                      children: [
                        _buildShopTab(
                          viewerId: viewerId,
                          userId: targetUserId,
                          isMe: false,
                          nama: nama,
                          bio: bio,
                          fotoProfilUrl: foto,
                        ),

                        LikesTab(
                          viewerId: viewerId,
                          likeC: Get.find<LikeController>(),
                        ),

                        const EmptyReviewsTab(),
                      ],
                    );
                  },
                ),
        ),
      );
    });
  }
}

class EmptyReviewsTab extends StatelessWidget {
  const EmptyReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Belum ada ulasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class StatItemWidget extends StatelessWidget {
  final String number;
  final String label;

  const StatItemWidget({super.key, required this.number, required this.label});

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

class ShopProduct {
  final String id;
  final String title;
  final String imageUrl;
  final int price;
  final String status;

  ShopProduct({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.status,
  });

  bool get isDraft => status == 'draft';

  factory ShopProduct.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final List raw = (data['image_urls'] as List?) ?? [];
    final List<String> imageUrls = raw.map((e) => e.toString()).toList();

    final String firstImage =
        (data['thumbnail_url'] as String?) ??
        (data['image_url'] as String?) ??
        (imageUrls.isNotEmpty ? imageUrls.first : '');

    final dynamic priceRaw = data['price'];
    final int price = priceRaw is int
        ? priceRaw
        : int.tryParse(priceRaw?.toString() ?? '0') ?? 0;

    return ShopProduct(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      imageUrl: firstImage,
      price: price,
      status: (data['status'] ?? 'draft').toString(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ShopProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
            image: product.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        if (product.isDraft)
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
