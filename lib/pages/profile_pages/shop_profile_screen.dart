import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/controller/sell_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

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
          ? bio.substring(0, maxPreviewChars) + '...'
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
              onPressed: () {
                showFullBio.value = !showFullBio.value;
              },
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

  /// TAB SHOP – sekarang seluruh tab dibungkus StreamBuilder,
  /// jadi stat di header + grid produk semuanya mengikuti data Firestore.
  Widget _buildShopTab({
    required String userId,
    required String nama,
    required String bio,
    required String fotoProfilUrl,
  }) {
    final String initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('seller_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
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
        final drafts = products.where((p) => p.isDraft).toList(growable: false);
        final allProducts = [...published, ...drafts];

        final int productCount = published.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============== HEADER PROFIL + STAT DINAMIS ==============
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
                            ),
                            const StatItemWidget(
                              number: '0',
                              label: 'following',
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
                  (index) => Icon(Icons.star_border, color: Colors.grey[400]),
                ),
              ),

              const SizedBox(height: 8),

              _buildBioSection(bio),

              const SizedBox(height: 24),

              // ============== TOMBOL EDIT & UPLOAD ==============
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(Routes.editProfile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit profil'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // langsung ke flow jual
                        Get.toNamed(Routes.sellProduct);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Upload produk'),
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
                        if (product.isDraft) {
                          final sell = Get.isRegistered<SellController>()
                              ? Get.find<SellController>()
                              : Get.put(SellController());

                          await sell.loadDraft(
                            product.id,
                          ); // ✅ preload form + images(url/local)
                          Get.toNamed(
                            Routes.editDraft,
                            arguments: {"id": product.id},
                          );

                          return;
                        }

                        Get.toNamed(
                          '${Routes.manageProduct}?id=${product.id}&seller_id=$userId',
                        );
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

  void _showMenuBottomSheet(BuildContext context) {
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
      final profile = authC.user.value;

      if (profile == null) {
        return const Scaffold(body: Center(child: Text('Kamu belum login')));
      }

      final String userId = profile.id;
      final String nama = profile.nama;
      final String username = profile.username;
      final String bio = profile.bio;
      final String fotoProfilUrl = profile.fotoProfilUrl;

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
            title: Text(username.isNotEmpty ? username : nama),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showMenuBottomSheet(context);
                },
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
          body: TabBarView(
            children: [
              _buildShopTab(
                userId: userId,
                nama: nama,
                bio: bio,
                fotoProfilUrl: fotoProfilUrl,
              ),
              const EmptyLikesTab(),
              const EmptyReviewsTab(),
            ],
          ),
        ),
      );
    });
  }
}

class EmptyLikesTab extends StatelessWidget {
  const EmptyLikesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/heart_message.png', width: 100, height: 100),
          const SizedBox(height: 16),
          const Text(
            'Belum ada likes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
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
          Icon(Icons.star_border, size: 80, color: Colors.grey[400]),
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

/// Model sederhana untuk produk di tab Shop
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

    // 🔥 Ambil dari field "image_urls" (List<String>)
    final List imageUrlsRaw = (data['image_urls'] as List?) ?? [];
    final List<String> imageUrls = imageUrlsRaw
        .map((e) => e.toString())
        .toList();

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
      title: data['title'] ?? '',
      imageUrl: firstImage,
      price: price,
      status: data['status'] ?? 'draft',
    );
  }
}

/// Kartu produk di grid (dengan label DRAFT jika status draft)
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
