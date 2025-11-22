import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold,),),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Profil Pengguna
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
            title: const Text('Makarimu Sa'),
            subtitle: const Text('Lihat profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigasi ke halaman profil lengkap
            },
          ),

          // Banner placeholder
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Banner',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          // Menu Favorit
          _buildMenuTile(
            icon: Icons.favorite_border,
            title: 'Favorit',
          ),

          // Menu Wallet dengan saldo
          ListTile(
            leading: Icon(Icons.wallet, color: Colors.grey[600]),
            title: const Text('Wallet'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rp 1.000.000', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () {},
          ),

          // Menu Pesanan
          _buildMenuTile(
            icon: Icons.message_outlined,
            title: 'Pesanan',
          ),

          // Menu Settings
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),

          // Menu Personalisasi
          _buildMenuTile(
            icon: Icons.tune,
            title: 'Personalisasi',
          ),

          // Menu Share Shop
          _buildMenuTile(
            icon: Icons.share_outlined,
            title: 'Share shop',
          ),

          // Mode Liburan (Switch)
          SwitchListTile.adaptive(
            title: const Text('Mode liburan'),
            value: false,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (bool value) {
              // Handle mode liburan toggle
            },
            secondary: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
          ),
        ],
      ),
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
}// End of ProfilePage class