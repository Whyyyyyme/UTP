import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class ShopProfileScreen extends StatelessWidget {
  final int initialTabIndex;

  ShopProfileScreen({super.key, this.initialTabIndex = 0});

  /// state kecil buat expand/collapse bio
  final RxBool showFullBio = false.obs;

  // ==== BIO SECTION DENGAN "LIHAT SEMUA" ====
  Widget _buildBioSection(String bioRaw) {
    final String bio = bioRaw.trim().isEmpty ? 'Tidak ada bio' : bioRaw.trim();
    final bool isLong = bio.length > 60;

    return Obx(() {
      final bool expanded = showFullBio.value;

      final String displayText = (isLong && !expanded)
          ? bio.substring(0, 30) + '...'
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

  // ==== TAB SHOP ====
  Widget _buildShopTab(String nama, String bio) {
    final String initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + nama + stats
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                      children: const [
                        StatItemWidget(number: '0', label: 'produk'),
                        StatItemWidget(number: '0', label: 'followers'),
                        StatItemWidget(number: '0', label: 'following'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rating Stars
          Row(
            children: List.generate(5, (index) {
              return Icon(Icons.star_border, color: Colors.grey[400]);
            }),
          ),

          const SizedBox(height: 8),

          // === BIO DENGAN LIHAT SEMUA ===
          _buildBioSection(bio),

          const SizedBox(height: 24),

          // Buttons
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
                    // TODO: arahkan ke halaman Upload Produk
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

          const SizedBox(height: 40),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/eyes.png', width: 100, height: 100),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
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

    return Obx(() {
      final profile = authC.user.value;

      if (profile == null) {
        return const Scaffold(body: Center(child: Text('Kamu belum login')));
      }

      final String nama = profile.nama;
      final String username = profile.username;
      final String bio = profile.bio;

      final int initialIndex = (initialTabIndex < 0 || initialTabIndex > 2)
          ? 0
          : initialTabIndex;

      return DefaultTabController(
        length: 3,
        initialIndex: initialIndex,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
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
              _buildShopTab(nama, bio),
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
