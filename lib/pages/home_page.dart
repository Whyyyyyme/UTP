import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/home_controller.dart';
import 'package:prelovedly/view_model/main_nav_controller.dart';
import 'package:prelovedly/pages/home_content_page.dart';
import 'package:prelovedly/routes/app_routes.dart';
import '../widgets/rive_nav/animated_bottom_nav_bar.dart';

import 'search_page.dart';
import 'inbox_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<MainNavController>();

    final pages = <Widget>[
      const HomeContentPage(),
      SearchPage(),
      const SizedBox.shrink(),
      InboxPage(),
      ProfilePage(),
    ];

    return Obx(() {
      final current = nav.currentIndex.value.clamp(0, pages.length - 1);

      return Scaffold(
        appBar: current == 0 ? _HomeAppBar(nav: nav) : null,
        body: IndexedStack(index: current, children: pages),
        bottomNavigationBar: AnimatedBottomNavBarUTP(
          currentIndex: current,
          onIndexChanged: (index) {
            if (index == 2) {
              Get.toNamed(Routes.sellProduct);
              return;
            }
            nav.changeTab(index);
          },
        ),
      );
    });
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MainNavController nav;
  const _HomeAppBar({required this.nav});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final homeC = Get.find<HomeController>();

    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => nav.changeTab(1),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_outlined, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cari items dan users',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Obx(() {
            final count = homeC.cartCount.value;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () => Get.toNamed(Routes.cart),
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
