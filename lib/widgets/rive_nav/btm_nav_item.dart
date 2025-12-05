// lib/widgets/rive_nav/btm_nav_item.dart
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../rive/menu.dart';
import 'animated_bar.dart';

class BtmNavItem extends StatelessWidget {
  const BtmNavItem({
    super.key,
    required this.navBar,
    required this.press,
    required this.riveOnInit,
    required this.selectedNav,
  });

  final Menu navBar;
  final VoidCallback press;
  final ValueChanged<Artboard> riveOnInit;
  final Menu selectedNav;

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedNav == navBar;

    return GestureDetector(
      onTap: press,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBar(isActive: isActive),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            width: 32,
            child: Opacity(
              opacity: isActive ? 1 : 0.5,
              child: RiveAnimation.asset(
                navBar.rive.src,
                artboard: navBar.rive.artboard,
                onInit: riveOnInit,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            navBar.title,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
