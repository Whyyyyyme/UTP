import 'package:flutter/material.dart';
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
      top: false,
      child: Padding(
        // 🔽 jarak bawah diperkecil (biar tidak kegedean)
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: Container(
          // 🔽 TINGGI NAV DIPERKECIL
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF17203A).withOpacity(0.80),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(utpBottomNavItems.length, (index) {
              final navBar = utpBottomNavItems[index];
              final bool isCenter = index == 2;

              return Expanded(
                child: BtmNavItem(
                  navBar: navBar,
                  selectedNav: selectedNav,
                  isCenter: isCenter,
                  press: () {
                    // ✅ animasi Rive hanya untuk non-custom
                    if (!navBar.isCustom) {
                      final rive = navBar.rive;
                      if (rive != null && rive.status != null) {
                        RiveUtils.changeSMIBoolState(rive.status!);
                      }
                    }

                    // ✅ highlight hanya non "+"
                    if (!isCenter) {
                      setState(() => selectedNav = navBar);
                    }

                    widget.onIndexChanged(index);
                  },
                  riveOnInit: (artboard) {
                    if (navBar.isCustom) return;

                    final rive = navBar.rive!;
                    rive.status = RiveUtils.getRiveInput(
                      artboard,
                      stateMachineName: rive.stateMachineName,
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
