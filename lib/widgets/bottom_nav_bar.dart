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
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          // ✅ tombol tengah (+) → buka halaman jual
          if (index == 2) {
            Get.toNamed(Routes.sellAddressIntro);
            return;
          }

          // ✅ tab biasa
          nav.changeTab(index);
        },

        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),

          BottomNavigationBarItem(
            label: '',
            icon: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black, // bisa kamu ganti sesuai tema
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),

          const BottomNavigationBarItem(icon: Icon(Icons.inbox), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],

      );
    });
  }
}
