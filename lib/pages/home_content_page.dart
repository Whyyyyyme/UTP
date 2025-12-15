import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/home_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/homepage_widget.dart';

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

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

          // ===== 2 cards =====
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

          // ===== Rekomendasi seller =====
          const Text(
            'Rekomendasi seller',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          StreamBuilder<List<String>>(
            stream: c.recommendedSellerIdsStream(),
            builder: (context, snap) {
              // ✅ tampilkan error kalau query seller error/index
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
                    return SellerCard(sellerId: sellerIds[i]);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          // ===== Hot items header =====
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
                child: Row(
                  children: const [
                    Text('Semua'),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== Hot items grid =====
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: c.hotItemsStream(),
            builder: (context, snap) {
              // ✅ tampilkan error kalau query hot items error/index
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
                  final data = docs[index].data();
                  final id = docs[index].id;

                  return HotItemCard(
                    id: id,
                    data: data,
                    onTap: () {
                      // Get.toNamed(Routes.productDetail, arguments: {"id": id});
                    },
                    onLike: () {},
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
