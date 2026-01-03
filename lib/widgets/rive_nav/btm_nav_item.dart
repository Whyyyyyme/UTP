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
    required this.isCenter,
  });

  final Menu navBar;
  final VoidCallback press;
  final ValueChanged<Artboard> riveOnInit;
  final Menu selectedNav;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedNav == navBar;

    return GestureDetector(
      onTap: press,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // highlight bar hanya untuk item non-center
            if (!isCenter)
              AnimatedBar(isActive: isActive)
            else
              const SizedBox(height: 4),

            const SizedBox(height: 6),

            // =========================
            // CUSTOM "+" (tanpa Rive)
            // =========================
            if (navBar.isCustom)
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.10,
                  ), // biar nyatu, tapi tetap keliatan
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: isActive ? 1 : 0.85,
                    child: Icon(
                      navBar.icon ?? Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 32,
                width: 32,
                child: Opacity(
                  opacity: isActive ? 1 : 0.5,
                  child: RiveAnimation.asset(
                    navBar.rive!.src,
                    artboard: navBar.rive!.artboard,
                    onInit: riveOnInit,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
