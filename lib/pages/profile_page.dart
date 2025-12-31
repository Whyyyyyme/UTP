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

      final namaRaw = user.nama;
      final nama = namaRaw.isNotEmpty ? namaRaw : 'User';

      final usernameRaw = user.username;
      final username = usernameRaw.isNotEmpty ? '@$usernameRaw' : '';

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
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

            // BANNER
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Banner', style: TextStyle(color: Colors.grey)),
              ),
            ),

            // MENU FAVORIT
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favorit'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // langsung buka detail profil tab Likes
                Get.toNamed(
                  Routes.shopProfile,
                  arguments: {'initialTabIndex': 1, 'sellerId': myId},
                );
              },
            ),

            // WALLET
            ListTile(
              leading: Icon(Icons.wallet, color: Colors.grey[600]),
              title: const Text('Wallet'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Text(
                      rupiah(
                        walletC.availableBalance.value,
                      ), // dari orders received
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),

              onTap: () => Get.toNamed(Routes.wallet),
            ),

            // Pesanan
            _buildMenuTile(
              icon: Icons.message_outlined,
              title: 'Pesanan',
              onTap: () {
                Get.toNamed(Routes.orders);
              },
            ),

            // Settings
            _buildMenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Get.toNamed(Routes.settings);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuTile({
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
