import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/home_controller.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import 'package:prelovedly/view_model/like_controller.dart';

import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/homepage_widget.dart';
import 'package:prelovedly/pages/help_desk_page.dart';
class WelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl; // Tambahkan ini
  final VoidCallback onTap;

  const WelcomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl, // Tambahkan ini
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl), // Menampilkan gambar
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Overlay gradasi hitam agar teks putih mudah dibaca
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    final likeC = Get.find<LikeController>(); // ✅ dari binding
    final session = SessionController.to; // ✅ viewerId source of truth

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome kak 👌',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Pelajari cara pakai Prelovedly!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 128,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                WelcomeCard(
                  title: 'Cara berbelanja',
                  subtitle: 'Pelajari cara membeli di\nPrelovedly',
                  // Tambahkan link gambar tutorial belanja
                  imageUrl: 'https://images.unsplash.com/photo-1472851294608-062f824d29cc?q=80&w=500', 
                  onTap: () => Get.to(() => const HelpDeskPage()),
                ),
                const SizedBox(width: 12),
                WelcomeCard(
                  title: 'Mulai berjualan',
                  subtitle: 'Mulai kosongkan\npakaianmu',
                  // Tambahkan link gambar orang merapikan baju/jualan
                  imageUrl: 'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=500',
                  onTap: () => Get.toNamed(Routes.sellProduct),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Rekomendasi seller',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          StreamBuilder<List<String>>(
            stream: c.recommendedSellerIdsStream(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Seller error: ${snap.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final sellerIds = snap.data ?? [];
              if (sellerIds.isEmpty) {
                return Text(
                  'Belum ada rekomendasi seller',
                  style: TextStyle(color: Colors.grey.shade600),
                );
              }

              return SizedBox(
                height: SellerCard.cardHeight + 8,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sellerIds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final sid = sellerIds[i];
                    return SellerCard(
                      sellerId: sid,
                      onTap: () {
                        Get.toNamed(
                          Routes.shopProfile,
                          arguments: {"seller_id": sid},
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Text(
                'Hot items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Text('Semua'),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: c.hotItemsStream(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Hot items error: ${snap.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'Belum ada produk',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              return Obx(() {
                final viewerId = session.viewerId.value;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.76,
                  ),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final productId = doc.id;
                    final sellerId = (data['seller_id'] ?? '').toString();

                    return StreamBuilder<bool>(
                      stream: viewerId.isEmpty
                          ? Stream.value(false)
                          : likeC.isLikedStream(
                              viewerId: viewerId,
                              productId: productId,
                            ),
                      builder: (context, likeSnap) {
                        final liked = likeSnap.data == true;

                        return HotItemCard(
                          id: productId,
                          data: data,
                          isLiked: liked,
                          onTap: () {
                            Get.toNamed(
                              Routes.productDetail,
                              arguments: {
                                "id": productId,
                                "seller_id": sellerId,
                                "viewer_id": viewerId,
                                "is_me":
                                    viewerId.isNotEmpty && viewerId == sellerId,
                              },
                            );
                          },
                          onLike: () async {
                            if (viewerId.isEmpty) {
                              Get.snackbar('Login dulu', 'Silakan login ulang');
                              return;
                            }

                            try {
                              await likeC.toggleLike(
                                viewerId: viewerId,
                                productId: productId,
                                sellerId: sellerId,
                                currentlyLiked: liked,
                              );
                            } catch (e) {
                              Get.snackbar('Gagal', e.toString());
                            }
                          },
                        );
                      },
                    );
                  },
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
