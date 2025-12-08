import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/auth_controller.dart';

class EditBioPage extends StatefulWidget {
  const EditBioPage({super.key});

  @override
  State<EditBioPage> createState() => _EditBioPageState();
}

class _EditBioPageState extends State<EditBioPage> {
  late TextEditingController _bioC;
  int _length = 0;

  @override
  void initState() {
    super.initState();
    final authC = Get.find<AuthController>();
    final currentBio = authC.user.value?.bio ?? '';
    _bioC = TextEditingController(text: currentBio);
    _length = currentBio.length;
  }

  @override
  void dispose() {
    _bioC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final authC = Get.find<AuthController>();
    final newBio = _bioC.text.trim();

    // boleh kosong, tapi kalau sama persis juga nggak usah update
    if (newBio == (authC.user.value?.bio ?? '')) {
      Get.back();
      return;
    }

    await authC.updateProfile(bio: newBio);
    Get.back();
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
            'Bio',
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
                  controller: _bioC,
                  maxLines: 4,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (val) {
                    setState(() {
                      _length = val.length;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Bio jelas: siapa kamu, jualan apa, atau gaya unikmu. Tanpa spam.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    Text(
                      '$_length/120',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
