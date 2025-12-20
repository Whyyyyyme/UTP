import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/auth_controller.dart';

class EditNamePage extends StatefulWidget {
  const EditNamePage({super.key});

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  final AuthController authC = Get.find<AuthController>();

  late TextEditingController _nameC;

  @override
  void initState() {
    super.initState();
    final currentName = authC.user.value?.nama ?? '';
    _nameC = TextEditingController(text: currentName);
  }

  @override
  void dispose() {
    _nameC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newName = _nameC.text.trim();

    if (newName.isEmpty) {
      Get.snackbar('Nama kosong', 'Nama tidak boleh kosong');
      return;
    }

    // kalau tidak berubah, langsung back
    if (newName == (authC.user.value?.nama ?? '')) {
      Get.back();
      return;
    }

    await authC.updateProfile(nama: newName);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = authC.isLoading.value;

      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3F4F6),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: const Text(
            'Name',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : _save,
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameC,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => isLoading ? null : _save(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Masukkan nama',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pakai nama asli, panggilan, atau nama toko '
                  'biar gampang ditemukan. Jangan spam atau pakai kata nggak relevan.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
