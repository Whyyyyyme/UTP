import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/auth_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsCard(
            children: [
              _SettingsItem(
                icon: Icons.person_outline,
                label: 'Edit profil',
                onTap: () {
                  Get.toNamed(Routes.editProfile);
                },
              ),
              const Divider(height: 1),
              _SettingsItem(
                icon: Icons.location_on_outlined,
                label: 'Alamat penjual',
                onTap: () {
                  Get.toNamed(Routes.addressList);
                },
              ),
              const Divider(height: 1),
              _SettingsItem(
                icon: Icons.local_shipping_outlined,
                label: 'Kurir pengiriman',
                onTap: () {
                  Get.toNamed(Routes.sellerShipping);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _SettingsCard(
            children: [
              _SettingsItem(
                icon: Icons.logout,
                label: 'Logout',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  Get.defaultDialog(
                    title: 'Logout',
                    middleText: 'Apakah kamu yakin ingin logout?',
                    textCancel: 'Batal',
                    textConfirm: 'Logout',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    radius: 12,
                    onConfirm: () async {
                      Get.back();
                      await authC.signOut();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[800]),
      title: Text(
        label,
        style: TextStyle(fontSize: 16, color: textColor ?? Colors.black),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
