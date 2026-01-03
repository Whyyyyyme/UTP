// lib/rive/menu.dart
import 'package:flutter/material.dart';
import '../models/rive_model.dart';

class Menu {
  final String title;

  /// kalau item normal: rive != null
  final RiveModel? rive;

  /// kalau item custom "+" : isCustom = true dan pakai icon
  final bool isCustom;
  final IconData? icon;

  const Menu({
    required this.title,
    this.rive,
    this.isCustom = false,
    this.icon,
  });
}

/// Urutan index:
/// 0: Home, 1: Search, 2: Jual(+), 3: Inbox, 4: Profile
final List<Menu> utpBottomNavItems = [
  Menu(
    title: "Home",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "HOME",
      stateMachineName: "HOME_interactivity", // ✅ PENTING: huruf kecil
    ),
  ),
  Menu(
    title: "Search",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "SEARCH",
      stateMachineName: "SEARCH_Interactivity",
    ),
  ),

  // ✅ Tombol tengah: TANPA RIVE, icon putih
  Menu(title: "Jual", isCustom: true, icon: Icons.add),

  Menu(
    title: "Inbox",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "CHAT",
      stateMachineName: "CHAT_Interactivity",
    ),
  ),
  Menu(
    title: "Profile",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "USER",
      stateMachineName: "USER_Interactivity",
    ),
  ),
];
