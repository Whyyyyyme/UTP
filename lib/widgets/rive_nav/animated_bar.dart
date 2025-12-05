// lib/widgets/rive_nav/animated_bar.dart
import 'package:flutter/material.dart';

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 4,
      width: isActive ? 20 : 0,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF81B4FF) : Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
