import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/main_nav_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<MainNavController>();

    return Obx(() {
      return BottomNavigationBar(
        currentIndex: nav.currentIndex.value,
        type: BottomNavigationBarType.fixed, // Tetap fixed agar 5 item muat
        
        // ✅ 1. Atur Transparansi & Warna
        backgroundColor: Colors.white.withOpacity(1.0), // Berikan opacity agar transparan
        elevation: 0, // Hilangkan garis/bayangan atas agar lebih menyatu
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,

        // ✅ 2. Tampilkan Nama/Label
        showSelectedLabels: true,   // Munculkan nama saat dipilih
        showUnselectedLabels: true, // Munculkan nama saat tidak dipilih
        selectedFontSize: 12,
        unselectedFontSize: 12,

        onTap: (index) {
          if (index == 2) {
            Get.toNamed(Routes.sellAddressIntro);
            return;
          }
          nav.changeTab(index);
        },

        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            activeIcon: Icon(Icons.home),
            label: 'Home', // ✅ Tambahkan Nama
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search), 
            label: 'Search', // ✅ Tambahkan Nama
          ),

          // Tombol Tengah (+)
          BottomNavigationBarItem(
            label: 'Jual', // ✅ Tambahkan Nama jika ingin, atau kosongkan ''
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(1.0),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined), 
            activeIcon: Icon(Icons.inbox),
            label: 'Inbox', // ✅ Tambahkan Nama
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person),
            label: 'Profil', // ✅ Tambahkan Nama
          ),
        ],
      );
    });
  }
}