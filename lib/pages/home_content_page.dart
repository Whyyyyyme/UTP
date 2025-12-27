import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/home_controller.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import 'package:prelovedly/view_model/like_controller.dart';

import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/homepage_widget.dart';

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
            'Pelajari cara pakai Preloved!',
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
                  subtitle: 'Pelajari cara membeli di\nPreloved',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                WelcomeCard(
                  title: 'Mulai berjualan',
                  subtitle: 'Mulai kosongkan\npakaianmu',
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
