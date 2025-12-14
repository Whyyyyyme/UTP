import 'package:get/get.dart';

class MaterialPickerController extends GetxController {
  // Daftar material yang tersedia
  final List<_MaterialItem> materials = [
    _MaterialItem("Acrylic", "Akrilik"),
    _MaterialItem("Alpaca", "Alpaka"),
    _MaterialItem("Bamboo", "Bambu"),
    _MaterialItem("Canvas", "Kanvas"),
    _MaterialItem("Cardboard", "Kardus, Karton"),
    _MaterialItem("Cashmere", "Kasmir"),
    _MaterialItem("Ceramic", "Keramik"),
    _MaterialItem("Chiffon", "Sifon"),
    _MaterialItem("Corduroy", "Korduroi"),
    _MaterialItem("Cotton", "Katun"),
    _MaterialItem("Denim", "Denim"),
    _MaterialItem("Faux Leather", "Kulit sintetis"),
    _MaterialItem("Fleece", "Bulu domba sintetis"),
    _MaterialItem("Jute", "Goni"),
    _MaterialItem("Lace", "Renda"),
    _MaterialItem("Leather", "Kulit"),
    _MaterialItem("Linen", "Linen"),
    _MaterialItem("Mesh", "Jaring"),
    _MaterialItem("Nylon", "Nilon"),
    _MaterialItem("Polyester", "Poliester"),
    _MaterialItem("Rayon", "Rayon"),
    _MaterialItem("Satin", "Satin"),
    _MaterialItem("Silk", "Sutra"),
    _MaterialItem("Spandex", "Spandeks"),
    _MaterialItem("Suede", "Suede"),
    _MaterialItem("Velvet", "Beludru"),
    _MaterialItem("Wool", "Wol"),
    _MaterialItem("Other", "Lainnya"),
  ];

  final RxList<String> selectedList = <String>[].obs;

  // Fungsi untuk memilih material
  void toggleMaterialSelection(String materialName, bool isSelected) {
    if (isSelected) {
      if (selectedList.length < 3) {
        selectedList.add(materialName);
      } else {
        Get.snackbar(
          "Maksimal 3 material",
          "Kamu hanya bisa memilih 3 opsi",
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
      selectedList.remove(materialName);
    }
  }

  // Fungsi untuk menyimpan material yang dipilih
  void saveSelectedMaterials() {
    final selectedMaterialsString = selectedList.join(', ');
    print("Materials selected: $selectedMaterialsString");
  }
}

class _MaterialItem {
  final String name;
  final String sub;

  _MaterialItem(this.name, this.sub);
}
