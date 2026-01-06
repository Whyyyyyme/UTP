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

            // --- BAGIAN USER (TETAP ADA) ---
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
                        backgroundImage: hasPhoto ? NetworkImage(fotoUrl) : null,
                        child: hasPhoto ? null : Text(initial, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            if (username.isNotEmpty)
                              Text(username, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text('Lihat profil', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

            // --- BAGIAN BANNER (YANG DIUBAH) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 125,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=500'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Mulai jualan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Ubah baju tidak terpakaimu\njadi cuan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(Routes.sellProduct),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Jual', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- MENU LAINNYA ---
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favorit'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Get.toNamed(Routes.shopProfile, arguments: {'initialTabIndex': 1, 'sellerId': myId}),
            ),
            ListTile(
              leading: Icon(Icons.wallet, color: Colors.grey[600]),
              title: const Text('Wallet'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(rupiah(walletC.availableBalance.value), style: TextStyle(color: Colors.grey[600]))),
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
          ],
        ),
      );
    });
  }

  Widget _buildMenuTile({required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
} 
  


