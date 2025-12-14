import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/main_nav_controller.dart';
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
            Get.toNamed(Routes.sellProduct);
            return;
          }

          // ✅ tab biasa
          nav.changeTab(index);
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      );
    });
  }
}
