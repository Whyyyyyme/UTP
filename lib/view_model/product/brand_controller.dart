import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrandController extends GetxController {
  var brand = ''.obs; // Observable brand value

  // Method to set the brand
  void setBrand(String value) {
    brand.value = value;
  }

  // Method to get the current brand value
  String getBrand() {
    return brand.value;
  }

  // Modify inputBrand to return the selected brand
  Future<String?> inputBrand(String initial) async {
    final result = await _inputText(
      'Brand',
      initial,
    ); // Return the result from the input dialog
    return result; // Return the brand or null if not selected
  }

  // Helper method for input dialogs
  Future<String?> _inputText(String title, String? initial) async {
    final controller = TextEditingController(text: initial ?? '');
    final result = await Get.dialog<String>(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Masukkan $title'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return result?.trim(); // Return the text input or null if canceled
  }
}
