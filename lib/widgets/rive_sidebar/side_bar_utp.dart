import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/main_nav_controller.dart';

import 'info_card_utp.dart';
import 'side_menu_tile.dart';

class SideBarUTP extends StatefulWidget {
  final VoidCallback onClose;

  const SideBarUTP({
    super.key,
    required this.onClose,
  });

  @override
  State<SideBarUTP> createState() => _SideBarUTPState();
}

class _SideBarUTPState extends State<SideBarUTP> {
  int _activeIndex = 0;

  void _goToTab(int tabIndex) {
    final nav = Get.find<MainNavController>();
    nav.changeTab(tabIndex);
    widget.onClose();
  }

  void _goToRoute(String route) {
    widget.onClose();
    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header / Profile (mirip rive_animation) =====
          InfoCardUTP(
            name: "PreLovedly",
            role: "Navigation",
            onClose: widget.onClose,
          ),

          const SizedBox(height: 18),
          const Text(
            "BROWSE",
            style: TextStyle(
              color: Color(0x88FFFFFF),
              fontSize: 12,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          SideMenuTile(
            title: "Home",
            icon: Icons.home_outlined,
            isActive: _activeIndex == 0,
            onTap: () {
              setState(() => _activeIndex = 0);
              _goToTab(0);
            },
          ),
          SideMenuTile(
            title: "Search",
            icon: Icons.search,
            isActive: _activeIndex == 1,
            onTap: () {
              setState(() => _activeIndex = 1);
              _goToTab(1);
            },
          ),
          SideMenuTile(
            title: "Inbox",
            icon: Icons.chat_bubble_outline,
            isActive: _activeIndex == 2,
            onTap: () {
              setState(() => _activeIndex = 2);
              _goToTab(3);
            },
          ),
          SideMenuTile(
            title: "Profile",
            icon: Icons.person_outline,
            isActive: _activeIndex == 3,
            onTap: () {
              setState(() => _activeIndex = 3);
              _goToTab(4);
            },
          ),
          SideMenuTile(
            title: "Help / Settings",
            icon: Icons.help_outline,
            isActive: _activeIndex == 4,
            onTap: () {
              setState(() => _activeIndex = 4);
              _goToRoute(Routes.settings);
            },
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0x22FFFFFF)),
          const SizedBox(height: 10),

          const Text(
            "HISTORY",
            style: TextStyle(
              color: Color(0x88FFFFFF),
              fontSize: 12,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          SideMenuTile(
            title: "Orders",
            icon: Icons.receipt_long_outlined,
            isActive: _activeIndex == 5,
            onTap: () {
              setState(() => _activeIndex = 5);
              _goToRoute(Routes.orders);
            },
          ),

          const Spacer(),
          const Text(
            "PreLovedly",
            style: TextStyle(
              color: Color(0x55FFFFFF),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
