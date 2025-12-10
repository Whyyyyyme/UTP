import 'dart:io' show File;
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/models/product_model.dart';

class SellController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _supabase = supa.Supabase.instance.client;

  // form controller
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final priceC = TextEditingController();

  // state
  final images = <XFile>[].obs; // foto yang dipilih
  final categoryName = ''.obs;
  final categoryId = ''.obs;
  final isSaving = false.obs;

  // PILIH FOTO (boleh beberapa kali tap)
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      images.add(picked);
    }
  }

  // HAPUS FOTO DARI LIST
  void removeImageAt(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  // VALIDASI INPUT
  String? _validate({required bool publish}) {
    if (titleC.text.trim().isEmpty) return 'Judul wajib diisi';
    if (descC.text.trim().isEmpty) return 'Deskripsi wajib diisi';

    if (categoryName.value.isEmpty) return 'Kategori belum dipilih';

    if (priceC.text.trim().isEmpty) return 'Harga wajib diisi';

    final p = int.tryParse(
      priceC.text.trim().replaceAll('.', '').replaceAll(',', ''),
    );
    if (p == null || p <= 0) return 'Harga tidak valid';

    if (publish && images.isEmpty) {
      return 'Tambah minimal 1 foto untuk upload';
    }

    return null;
  }

  // SIMPAN DRAFT
  Future<void> saveDraft() async {
    await _save(status: 'draft');
  }

  // UPLOAD (publish)
  Future<void> uploadProduct() async {
    await _save(status: 'published');
  }

  // CORE SAVE (dipakai draft & publish)
  Future<void> _save({required String status}) async {
    final auth = AuthController.to;
    final currentUser = auth.user.value;

    if (currentUser == null) {
      Get.snackbar('Error', 'Kamu belum login');
      return;
    }

    final error = _validate(publish: status == 'published');
    if (error != null) {
      Get.snackbar('Error', error);
      return;
    }

    try {
      isSaving.value = true;

      final sellerId = currentUser.id;
      final docRef = _db.collection('products').doc();

      // upload foto ke Supabase
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        imageUrls = await _uploadImages(
          sellerId: sellerId,
          productId: docRef.id,
        );
      }

      final priceInt = int.parse(
        priceC.text.trim().replaceAll('.', '').replaceAll(',', ''),
      );

      final now = Timestamp.now();

      final product = ProductModel(
        id: docRef.id,
        sellerId: sellerId,
        title: titleC.text.trim(),
        description: descC.text.trim(),
        categoryId: categoryId.value,
        categoryName: categoryName.value,
        price: priceInt,
        imageUrls: imageUrls,
        status: status,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(product.toMap());

      Get.snackbar(
        'Berhasil',
        status == 'draft' ? 'Draft disimpan' : 'Produk berhasil diupload',
        snackPosition: SnackPosition.BOTTOM,
      );

      // bersihkan form
      _resetForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan produk: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // UPLOAD FOTO KE SUPABASE
  Future<List<String>> _uploadImages({
    required String sellerId,
    required String productId,
  }) async {
    final urls = <String>[];

    for (final img in images) {
      final fileName =
          '$sellerId/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (kIsWeb) {
        final bytes = await img.readAsBytes();
        final resp = await _supabase.storage
            .from('product_photos')
            .uploadBinary(fileName, bytes);

        if (resp.isEmpty) {
          throw Exception('Upload gagal (web)');
        }
      } else {
        final file = File(img.path);
        final resp = await _supabase.storage
            .from('product_photos')
            .upload(fileName, file);

        if (resp.isEmpty) {
          throw Exception('Upload gagal (mobile)');
        }
      }

      final publicUrl = _supabase.storage
          .from('product_photos')
          .getPublicUrl(fileName);
      urls.add(publicUrl);
    }

    return urls;
  }

  // PILIH KATEGORI SEDERHANA (sementara: list lokal)
  Future<void> pickCategory() async {
    final result = await Get.bottomSheet<String>(
      Container(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 32,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _CategoryItem('1', 'Atasan'),
            _CategoryItem('2', 'Bawahan'),
            _CategoryItem('3', 'Outer'),
            _CategoryItem('4', 'Sepatu'),
            _CategoryItem('5', 'Aksesoris'),
          ],
        ),
      ),
    );

    if (result != null) {
      final parts = result.split('|'); // "id|name"
      categoryId.value = parts[0];
      categoryName.value = parts[1];
    }
  }

  void _resetForm() {
    titleC.clear();
    descC.clear();
    priceC.clear();
    categoryId.value = '';
    categoryName.value = '';
    images.clear();
  }

  @override
  void onClose() {
    titleC.dispose();
    descC.dispose();
    priceC.dispose();
    super.onClose();
  }
}

class _CategoryItem extends StatelessWidget {
  final String id;
  final String name;

  const _CategoryItem(this.id, this.name);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: () {
        Get.back(result: '$id|$name');
      },
    );
  }
}
