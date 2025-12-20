import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/auth_controller.dart';

class EditUsernamePage extends StatefulWidget {
  final String initialUsername;

  const EditUsernamePage({super.key, required this.initialUsername});

  @override
  State<EditUsernamePage> createState() => _EditUsernamePageState();
}

class _EditUsernamePageState extends State<EditUsernamePage> {
  final AuthController authC = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final _regex = RegExp(r'^[a-zA-Z0-9]+$');

  late TextEditingController _usernameC;

  @override
  void initState() {
    super.initState();
    _usernameC = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _usernameC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newUsername = _usernameC.text.trim();

    // kalau tidak berubah, langsung back
    if (newUsername == widget.initialUsername) {
      Get.back();
      return;
    }

    await authC.updateProfile(username: newUsername);

    Get.back();
    Get.snackbar(
      'Berhasil',
      'Username berhasil diperbarui',
      snackPosition: SnackPosition.TOP,
    );
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
            'Username',
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
          child: Form(
            key: _formKey,
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
                  TextFormField(
                    controller: _usernameC,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => isLoading ? null : _save(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan username',
                    ),
                    validator: (val) {
                      final v = val?.trim() ?? '';
                      if (v.isEmpty) {
                        return 'Username harus diisi';
                      }
                      if (!_regex.hasMatch(v)) {
                        return 'Hanya boleh huruf dan angka';
                      }
                      if (v.length < 3) {
                        return 'Username minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hanya huruf dan angka, tanpa spasi.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
