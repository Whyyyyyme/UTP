import 'package:get/get.dart';

class ConditionPickerController extends GetxController {
  final List<ConditionItem> options = const [
    ConditionItem(
      title: 'Baru dengan tag',
      desc:
          'Barang baru, belum pernah dipakai, dengan tag terpasang atau dalam kemasan asli.',
    ),
    ConditionItem(
      title: 'Baru tanpa tag',
      desc: 'Barang baru, belum pernah dipakai, tanpa tag atau kemasan asli.',
    ),
    ConditionItem(
      title: 'Sangat baik',
      desc:
          'Bekas pemakaian ringan, mungkin ada sedikit cacat, tapi masih terlihat bagus. Sertakan foto dan deskripsi cacat jika ada.',
    ),
    ConditionItem(
      title: 'Baik',
      desc:
          'Bekas pemakaian medium, mungkin ada cacat dan tanda-tanda pemakaian. Sertakan foto dan deskripsi cacat jika ada.',
    ),
    ConditionItem(
      title: 'Memuaskan',
      desc:
          'Barang sering dipakai, ada cacat dan tanda-tanda pemakaian. Sertakan foto dan deskripsi cacat jika ada.',
    ),
  ];

  final selected = ''.obs;

  void preload(String current) {
    if (selected.value.isNotEmpty) return; // ✅ hanya sekali
    selected.value = current.trim();
  }

  void select(String val) {
    selected.value = val.trim();
  }

  bool get canSave => selected.value.trim().isNotEmpty;
}

class ConditionItem {
  final String title;
  final String desc;
  const ConditionItem({required this.title, required this.desc});
}
