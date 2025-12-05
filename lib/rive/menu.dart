// lib/rive/menu.dart
import 'rive_model.dart';

class Menu {
  final String title;
  final RiveModel rive;

  Menu({required this.title, required this.rive});
}

/// List item bottom navbar untuk proyek UTP
///
/// Urutan index disesuaikan dengan halaman:
/// 0: Home, 1: Search, 2: Jual, 3: Inbox, 4: Profile
List<Menu> utpBottomNavItems = [
  Menu(
    title: "Home",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "HOME",
      stateMachineName: "HOME_interactivity",
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
  Menu(
    title: "Jual",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "TIMER", // bebas: pakai icon TIMER buat Jual
      stateMachineName: "TIMER_Interactivity",
    ),
  ),
  Menu(
    title: "Inbox",
    rive: RiveModel(
      src: "assets/RiveAssets/icons.riv",
      artboard: "BELL",
      stateMachineName: "BELL_Interactivity",
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
