import 'package:get/get.dart';

class MaterialPickerController extends GetxController {
  final int maxSelect = 3;

  // Daftar material yang tersedia
  final List<MaterialItem> materials = const [
    MaterialItem("Acrylic", "Akrilik"),
    MaterialItem("Alpaca", "Alpaka"),
    MaterialItem("Bamboo", "Bambu"),
    MaterialItem("Canvas", "Kanvas"),
    MaterialItem("Cardboard", "Kardus, Karton"),
    MaterialItem("Cashmere", "Kasmir"),
    MaterialItem("Ceramic", "Keramik"),
    MaterialItem("Chiffon", "Sifon"),
    MaterialItem("Corduroy", "Korduroi"),
    MaterialItem("Cotton", "Katun"),
    MaterialItem("Denim", "Denim"),
    MaterialItem("Faux Leather", "Kulit sintetis"),
    MaterialItem("Fleece", "Bulu domba sintetis"),
    MaterialItem("Jute", "Goni"),
    MaterialItem("Lace", "Renda"),
    MaterialItem("Leather", "Kulit"),
    MaterialItem("Linen", "Linen"),
    MaterialItem("Mesh", "Jaring"),
    MaterialItem("Nylon", "Nilon"),
    MaterialItem("Polyester", "Poliester"),
    MaterialItem("Rayon", "Rayon"),
    MaterialItem("Satin", "Satin"),
    MaterialItem("Silk", "Sutra"),
    MaterialItem("Spandex", "Spandeks"),
    MaterialItem("Suede", "Suede"),
    MaterialItem("Velvet", "Beludru"),
    MaterialItem("Wool", "Wol"),
    MaterialItem("Other", "Lainnya"),
  ];

  final RxList<String> selected = <String>[].obs;

  void preloadFromSell(String current) {
    if (selected.isNotEmpty) return; // ✅ preload sekali
    final v = current.trim();
    if (v.isEmpty) return;

    selected.assignAll(
      v
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .take(maxSelect),
    );
  }

  void toggle(String name) {
    if (selected.contains(name)) {
      selected.remove(name);
      return;
    }

    if (selected.length >= maxSelect) {
      Get.snackbar(
        "Maksimal $maxSelect material",
        "Kamu hanya bisa memilih $maxSelect opsi",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    selected.add(name);
  }

  bool get canSave => selected.isNotEmpty;

  String get selectedAsString => selected.join(', ');
}

class MaterialItem {
  final String name;
  final String sub;
  const MaterialItem(this.name, this.sub);
}
