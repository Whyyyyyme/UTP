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
      const SearchPage(),
      const SizedBox.shrink(),
      InboxPage(),
      ProfilePage(),
    ];

    return Obx(() {
      final current = nav.currentIndex.value.clamp(0, pages.length - 1);

      return Scaffold(
        // AppBar hanya muncul di Tab Home (index 0)
        appBar: current == 0 ? _HomeAppBar(nav: nav) : null,
        extendBody: true,
        // AnimatedSwitcher memberikan efek fade halus saat pindah tab
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey<int>(current),
            child: IndexedStack(index: current, children: pages),
          ),
        ),
        bottomNavigationBar: AnimatedBottomNavBarUTP(
          currentIndex: current,
          onIndexChanged: (index) {
            if (index == 2) {
              Get.toNamed(Routes.sellAddressIntro);
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

  // Jarak aman untuk burger menu Rive
  static const double _burgerLeft = 16;
  static const double _burgerSize = 44;
  static const double _burgerGap = 12;
  static const double _safeLeft = _burgerLeft + _burgerSize + _burgerGap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final homeC = Get.find<HomeController>();

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
// Bagian title di _HomeAppBar (home_page.dart)
title: Padding(
  // Kiri 72 (safe area burger), kanan 0 agar mepet ke actions
  padding: const EdgeInsets.only(left: _safeLeft), 
  child: Hero(
    tag: 'search_bar_anim',
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => nav.changeTab(1),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 1.2),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_outlined, size: 20, color: Colors.black),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cari items, brand, atau kategori',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),
      actions: [
        _buildCartAction(homeC),
      ],
    );
  }

  Widget _buildCartAction(HomeController homeC) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Obx(() {
        final count = homeC.cartCount.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
              onPressed: () => Get.toNamed(Routes.cart),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}