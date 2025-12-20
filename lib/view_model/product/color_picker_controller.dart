import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorPickerController extends GetxController {
  final int maxSelect = 2;

  final List<ColorItem> options = const [
    ColorItem('Hitam', Colors.black),
    ColorItem('Putih', Colors.white),
    ColorItem('Abu-abu', Colors.grey),
    ColorItem('Cokelat', Colors.brown),
    ColorItem('Cokelat muda', Color(0xFFD2AA6D)),
    ColorItem('Krem', Color(0xFFF7EECF)),
    ColorItem('Kuning', Colors.yellow),
    ColorItem('Merah', Colors.red),
    ColorItem('Marun', Colors.redAccent),
    ColorItem('Oranye', Colors.orange),
    ColorItem('Pink', Colors.pinkAccent),
    ColorItem('Ungu', Colors.purple),
  ];

  final RxList<String> selected = <String>[].obs;

  /// dipanggil sekali dari page (mis. onInit screen)
  void preloadFromString(String raw) {
    if (raw.trim().isEmpty) return;
    final parts = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return;

    // batasi maxSelect
    selected.assignAll(parts.take(maxSelect));
  }

  void toggle(String name) {
    if (selected.contains(name)) {
      selected.remove(name);
      return;
    }

    if (selected.length >= maxSelect) {
      Get.snackbar('Maksimal 2 warna', 'Kamu hanya bisa memilih 2 warna.');
      return;
    }

    selected.add(name);
  }

  bool get canSave => selected.isNotEmpty;

  String get asString => selected.join(', ');
}

class ColorItem {
  final String name;
  final Color color;
  const ColorItem(this.name, this.color);
}
