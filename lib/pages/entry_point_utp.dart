import 'dart:math';
import 'package:flutter/material.dart';

import 'home_page.dart';
import '../widgets/rive_sidebar/menu_btn_rive.dart';
import '../widgets/rive_sidebar/side_bar_utp.dart';

class EntryPointUTP extends StatefulWidget {
  const EntryPointUTP({super.key});

  @override
  State<EntryPointUTP> createState() => _EntryPointUTPState();
}

class _EntryPointUTPState extends State<EntryPointUTP>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotateAnim;

  bool _isSideBarOpen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.80).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _rotateAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSideBar() {
    setState(() => _isSideBarOpen = !_isSideBarOpen);
    if (_isSideBarOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _closeSideBar() {
    if (!_isSideBarOpen) return;
    setState(() => _isSideBarOpen = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    // ukuran sidebar kamu
    const double sideWidth = 288;
    const double btnSize = 44;
    const double outerPad = 16;

    // Fine tune: geser kiri & turun agar pas di kanan card "PreLovedly"
    final double openLeft = (sideWidth - outerPad - btnSize) - 14; // ✅ geser kiri 14px

    // posisi tombol saat sidebar CLOSED:
    final double closedLeft = outerPad;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          // ===== Sidebar =====
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            width: sideWidth,
            left: _isSideBarOpen ? 0 : -sideWidth,
            top: 0,
            bottom: 0,
            child: SafeArea(child: SideBarUTP(onClose: _closeSideBar)),
          ),

          // ===== Main Content (3D Transform) =====
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final angle = -30 * _rotateAnim.value * (pi / 180);

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: Transform.translate(
                  offset: Offset(265 * _rotateAnim.value, 0),
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        _isSideBarOpen ? 26 : 0,
                      ),
                      child: GestureDetector(
                        onTap: _closeSideBar,
                        child: const HomePage(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ===== SATU tombol yang sama, pindah posisi saat open =====
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            left: _isSideBarOpen ? openLeft : closedLeft,
            top: _isSideBarOpen ? (topPad + 30) : (topPad + 8),
            child: MenuBtnRive(isOpen: !_isSideBarOpen, onTap: _toggleSideBar),
          ),
        ],
      ),
    );
  }
}
