import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/auth_controller.dart';

class EditUsernamePage extends StatefulWidget {
  final String initialUsername;

  const EditUsernamePage({super.key, required this.initialUsername});

  @override
  State<EditUsernamePage> createState() => _EditUsernamePageState();
}

class _EditUsernamePageState extends State<EditUsernamePage> {
  late TextEditingController _usernameC;
  final _formKey = GlobalKey<FormState>();
  final _regex = RegExp(r'^[a-zA-Z0-9]+$');

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

    final authC = Get.find<AuthController>();
    final newUsername = _usernameC.text.trim();

    await authC.updateProfile(username: newUsername);

    Get.back(); // kembali ke EditProfilePage
    Get.snackbar(
      'Berhasil',
      'Username berhasil diperbarui',
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

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
              child: Text(
                'Simpan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isLoading ? Colors.grey : Colors.black,
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _usernameC,
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (val) {
                      final v = val?.trim() ?? '';
                      if (v.isEmpty) {
                        return 'Username harus diisi';
                      }
                      if (!_regex.hasMatch(v)) {
                        return 'Hanya boleh huruf dan angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hanya boleh huruf dan angka',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
