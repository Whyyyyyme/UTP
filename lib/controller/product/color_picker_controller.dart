import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorPickerController extends GetxController {
  final int maxSelect = 2;

  final List<_ColorItem> options = [
    _ColorItem('Hitam', Colors.black),
    _ColorItem('Putih', Colors.white),
    _ColorItem('Abu-abu', Colors.grey),
    _ColorItem('Cokelat', Colors.brown),
    _ColorItem('Cokelat muda', const Color(0xFFD2AA6D)),
    _ColorItem('Krem', const Color(0xFFF7EECF)),
    _ColorItem('Kuning', Colors.yellow),
    _ColorItem('Merah', Colors.red),
    _ColorItem('Marun', Colors.redAccent),
    _ColorItem('Oranye', Colors.orange),
    _ColorItem('Pink', Colors.pinkAccent),
    _ColorItem('Ungu', Colors.purple),
  ];

  /// ✅ INI harus RxList
  final RxList<String> selected = <String>[].obs;

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
}

class _ColorItem {
  final String name;
  final Color color;
  _ColorItem(this.name, this.color);
}
