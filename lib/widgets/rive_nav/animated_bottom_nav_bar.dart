
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../rive/menu.dart';
import '../../rive/rive_utils.dart';
import 'btm_nav_item.dart';

class AnimatedBottomNavBarUTP extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const AnimatedBottomNavBarUTP({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<AnimatedBottomNavBarUTP> createState() =>
      _AnimatedBottomNavBarUTPState();
}

class _AnimatedBottomNavBarUTPState extends State<AnimatedBottomNavBarUTP> {
  late Menu selectedNav;

  @override
  void initState() {
    super.initState();
    selectedNav = utpBottomNavItems[widget.currentIndex];
  }

  @override
  void didUpdateWidget(covariant AnimatedBottomNavBarUTP oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      selectedNav = utpBottomNavItems[widget.currentIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF17203A).withOpacity(0.95),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(utpBottomNavItems.length, (index) {
            final navBar = utpBottomNavItems[index];

            return BtmNavItem(
              navBar: navBar,
              selectedNav: selectedNav,
              press: () {
                if (navBar.rive.status != null) {
                  RiveUtils.changeSMIBoolState(navBar.rive.status!);
                }
                setState(() {
                  selectedNav = navBar;
                });
                widget.onIndexChanged(index);
              },
              riveOnInit: (artboard) {
                navBar.rive.status = RiveUtils.getRiveInput(
                  artboard,
                  stateMachineName: navBar.rive.stateMachineName,
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
