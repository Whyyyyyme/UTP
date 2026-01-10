// lib/pages/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/utils/rupiah.dart';
import 'package:prelovedly/view_model/auth_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import 'package:prelovedly/view_model/wallet_orders_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final walletC = Get.find<WalletOrdersController>();

    return Obx(() {
      final user = authC.user.value;

      if (user == null) {
        return const Scaffold(body: Center(child: Text('Kamu belum login')));
      }

      final nama = user.nama.isNotEmpty ? user.nama : 'User';
      final username = user.username.isNotEmpty ? '@${user.username}' : '';
      final initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';
      final fotoUrl = user.fotoProfilUrl;
      final hasPhoto = fotoUrl.isNotEmpty;
      final myId = SessionController.to.viewerId.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            const SizedBox(height: 16),

            // --- BAGIAN USER (TETAP) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Get.toNamed(
                    Routes.shopProfile,
                    arguments: {'initialTabIndex': 0, 'sellerId': myId},
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.orange,
                        backgroundImage: hasPhoto
                            ? NetworkImage(fotoUrl)
                            : null,
                        child: hasPhoto
                            ? null
                            : Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (username.isNotEmpty)
                              Text(
                                username,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'Lihat profil',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- BAGIAN BANNER (SUDAH RESPONSIVE, NO OVERFLOW) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SellBanner(
                onTapSell: () => Get.toNamed(Routes.sellProduct),
              ),
            ),

            // --- MENU LAINNYA ---
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favorit'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.toNamed(
                Routes.shopProfile,
                arguments: {'initialTabIndex': 1, 'sellerId': myId},
              ),
            ),
            ListTile(
              leading: Icon(Icons.wallet, color: Colors.grey[600]),
              title: const Text('Wallet'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Text(
                      rupiah(walletC.availableBalance.value),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              onTap: () => Get.toNamed(Routes.wallet),
            ),
            _buildMenuTile(
              icon: Icons.message_outlined,
              title: 'Pesanan',
              onTap: () => Get.toNamed(Routes.orders),
            ),
            _buildMenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Get.toNamed(Routes.settings),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  static Widget _buildMenuTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

/// Banner responsif: tidak pakai height fixed
/// - pakai AspectRatio biar stabil di semua layar
/// - teks & tombol ditempatkan di bawah, tidak overflow
class _SellBanner extends StatelessWidget {
  const _SellBanner({required this.onTapSell});

  final VoidCallback onTapSell;

  @override
  Widget build(BuildContext context) {
    // 16:7 cocok buat banner pendek, tapi tetap responsif
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // background image
            const Image(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=500',
              ),
              fit: BoxFit.cover,
            ),

            // overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withOpacity(0.72), Colors.transparent],
                ),
              ),
            ),

            // content
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, c) {
                  // biar tombol & teks auto menyesuaikan (tidak maksa)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Mulai jualan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ubah baju tidak terpakaimu jadi cuan',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // tombol kecil, aman di semua ukuran
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: onTapSell,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Jual',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
