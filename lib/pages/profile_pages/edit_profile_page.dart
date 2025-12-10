import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile/edit_bio_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile/edit_nama_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile/edit_username_page.dart';

class EditProfilePage extends GetView<AuthController> {
  const EditProfilePage({super.key});

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      final success = await controller.updateProfilePhoto(picked);

      if (success) {
        Get.snackbar(
          'Berhasil',
          'Foto profil berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          controller.errorMessage.value ?? 'Gagal mengubah foto profil',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah foto profil: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final u = controller.user.value;

      if (u == null) {
        return const Scaffold(
          body: Center(child: Text('Data profil belum tersedia')),
        );
      }

      final String username = u.username.isNotEmpty ? u.username : '-';
      final String nama = u.nama.isNotEmpty ? u.nama : 'Tidak ada nama';
      final String bio = u.bio.isNotEmpty ? u.bio : 'Tidak ada bio';

      final String initial = username != '-' && username.isNotEmpty
          ? username[0].toUpperCase()
          : (nama != 'Tidak ada nama' && nama.isNotEmpty
                ? nama[0].toUpperCase()
                : 'U');

      final bool hasPhoto = u.fotoProfilUrl.isNotEmpty;

      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3F4F6),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: const Text(
            'Edit profil',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            if (controller.isLoading.value)
              const LinearProgressIndicator(minHeight: 2),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 8),

                  Column(
                    children: [
                      CircleAvatar(
                        key: ValueKey(u.fotoProfilUrl),
                        radius: 40,
                        backgroundColor: Colors.pink,
                        backgroundImage: hasPhoto
                            ? NetworkImage(u.fotoProfilUrl)
                            : null,
                        child: hasPhoto
                            ? null
                            : Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (username != '-')
                        Text(
                          '@$username',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: controller.isLoading.value
                            ? null
                            : () => _pickAndUploadPhoto(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _ProfileRow(
                          label: 'Username',
                          value: username,
                          onTap: () {
                            Get.to(
                              () => EditUsernamePage(
                                initialUsername: username == '-'
                                    ? ''
                                    : username,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _ProfileRow(
                          label: 'Name',
                          value: nama,
                          onTap: () {
                            Get.to(() => const EditNamePage());
                          },
                        ),
                        const Divider(height: 1),
                        _ProfileRow(
                          label: 'Bio',
                          value: bio,
                          isHint: bio == 'Tidak ada bio',
                          onTap: () {
                            Get.to(() => const EditBioPage());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHint;
  final VoidCallback onTap;

  const _ProfileRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.isHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isHint ? Colors.grey : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
