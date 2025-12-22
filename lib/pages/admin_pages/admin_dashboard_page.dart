import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/auth_controller.dart';


class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.redAccent, // Warna beda agar mudah dikenali
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthController.to.signOut();
            },

          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang, Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildAdminMenu(Icons.people, 'Kelola User', Colors.blue),
                  _buildAdminMenu(Icons.shopping_bag, 'Semua Produk', Colors.green),
                  _buildAdminMenu(Icons.assessment, 'Laporan', Colors.orange),
                  _buildAdminMenu(Icons.settings, 'Pengaturan App', Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenu(IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          switch (title) {
            case 'Kelola User':
              Get.toNamed(Routes.adminUsers);
              break;
            case 'Semua Produk':
              Get.toNamed(Routes.adminProducts);
              break;
            case 'Laporan':
              Get.toNamed(Routes.adminReports);
              break;
            case 'Pengaturan App':
              Get.toNamed(Routes.adminSettings);
              break;
            default:
              Get.snackbar('Info', 'Menu $title akan segera hadir');
          }

        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}