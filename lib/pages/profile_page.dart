import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_pages/shop_profile_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Kamu belum login')));
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: const Center(child: Text('Data profil belum tersedia')),
          );
        }

        final data = snapshot.data!.data()!;
        final nama = (data['nama'] ?? 'User').toString();
        final String initial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

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
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                title: Text(nama),
                subtitle: const Text('Lihat profil'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShopProfileScreen(),
                    ),
                  );
                },
              ),

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

              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Favorit'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ShopProfileScreen(initialTabIndex: 1),
                    ),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.wallet, color: Colors.grey[600]),
                title: const Text('Wallet'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rp 1.000.000', // sementara tetap statis biar sesuai desain awal
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: () {},
              ),

              // Menu Pesanan
              _buildMenuTile(icon: Icons.message_outlined, title: 'Pesanan'),

              // Menu Settings
              _buildMenuTile(icon: Icons.settings_outlined, title: 'Settings'),

              // Menu Personalisasi
              _buildMenuTile(icon: Icons.tune, title: 'Personalisasi'),

              // Menu Share Shop
              _buildMenuTile(icon: Icons.share_outlined, title: 'Share shop'),

              // Mode Liburan (Switch)
              SwitchListTile.adaptive(
                title: const Text('Mode liburan'),
                value: false,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (bool value) {
                  // Handle mode liburan toggle
                },
                secondary: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
