import 'package:get/get.dart';

class ConditionPickerController extends GetxController {
  // Daftar kondisi barang
  final List<_ConditionItem> options = [
    _ConditionItem(
      title: 'Baru dengan tag',
      desc:
          'Barang baru, belum pernah dipakai, dengan tag terpasang atau dalam kemasan asli.',
    ),
    _ConditionItem(
      title: 'Baru tanpa tag',
      desc: 'Barang baru, belum pernah dipakai, tanpa tag atau kemasan asli.',
    ),
    _ConditionItem(
      title: 'Sangat baik',
      desc:
          'Bekas pemakaian ringan, mungkin ada sedikit cacat, tapi masih terlihat bagus. Sertakan foto dan deskripsi cacat jika ada.',
    ),
    _ConditionItem(
      title: 'Baik',
      desc:
          'Bekas pemakaian medium, mungkin ada cacat dan tanda-tanda pemakaian. Sertakan foto dan deskripsi cacat jika ada.',
    ),
    _ConditionItem(
      title: 'Memuaskan',
      desc:
          'Barang sering dipakai, ada cacat dan tanda-tanda pemakaian. Sertakan foto dan deskripsi cacat jika ada.',
    ),
  ];
}

class _ConditionItem {
  final String title;
  final String desc;

  _ConditionItem({required this.title, required this.desc});
}
