import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/controller/product/brand_controller.dart';
import 'package:prelovedly/models/product_model.dart';
import 'package:intl/intl.dart';

class SellController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _supabase = supa.Supabase.instance.client;
  final _brandController = Get.put(BrandController());

  // --- FORM ---
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final priceC = TextEditingController();
  final promoC = TextEditingController();

  final _formatter = NumberFormat.decimalPattern('id');

  /// ✅ agar subtitle harga di SellPage bisa Obx tanpa error
  final priceText = ''.obs;

  // --- FOTO ---
  final images = <XFile>[].obs;

  // --- KATEGORI (3 level) ---
  final categoryName = ''.obs;
  final categoryId = ''.obs;

  // --- ATRIBUT TAMBAHAN ---
  final size = ''.obs;
  final brand = ''.obs;
  final condition = ''.obs;
  final color = ''.obs;
  final style = ''.obs;
  final material = ''.obs;

  final isSaving = false.obs;

  // Promo status
  final promoActive = false.obs;

  // =====================
  // FOTO
  // =====================

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

  void removeImageAt(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
    }
  }

  // =====================
  // HARGA HELPERS (✅ baru)
  // =====================

  /// parsing aman dari "25.000" -> 25000
  int? parseInt(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// ✅ sinkronkan priceC + priceText sekaligus (dipanggil dari PricePage)
  void setFormattedPriceFromRaw(String rawInput) {
    final digits = rawInput.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      priceC.clear();
      priceText.value = '';
      return;
    }

    final number = int.parse(digits);
    final formatted = _formatter.format(number);

    priceC.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    priceText.value = formatted; // ✅ ini yang dipakai Obx di SellPage
  }

  void togglePromo(bool value) {
    promoActive.value = value;
  }

  void setFormattedPromoFromRaw(String rawInput) {
    final digits = rawInput.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      promoC.clear();
      return;
    }

    final number = int.parse(digits);
    final formatted = _formatter.format(number);

    promoC.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // Fungsi untuk menyimpan harga dan promo (validasi)
  void savePrice() {
    final price = parseInt(priceC.text);
    if (price == null || price < 25000) {
      Get.snackbar(
        'Harga tidak valid',
        'Minimal harga Rp 25.000',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (promoActive.value) {
      final promo = parseInt(promoC.text);
      if (promo == null) {
        Get.snackbar(
          'Promo ongkir',
          'Masukkan nominal promo ongkir',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final int maxPromo = (price * 0.8).floor();

      if (promo < 5000 || promo > maxPromo) {
        Get.snackbar(
          'Promo ongkir tidak valid',
          'Min. Rp 5.000 dan maks. Rp ${_formatter.format(maxPromo)}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }
  }

  // =====================
  // VALIDASI
  // =====================

  String? _validate({required bool publish}) {
    if (titleC.text.trim().isEmpty) return 'Judul wajib diisi';
    if (descC.text.trim().isEmpty) return 'Deskripsi wajib diisi';
    if (categoryName.value.isEmpty) return 'Kategori belum dipilih';
    if (priceC.text.trim().isEmpty) return 'Harga wajib diisi';

    final p = parseInt(priceC.text);
    if (p == null || p <= 0) return 'Harga tidak valid';

    if (publish && images.isEmpty) {
      return 'Tambah minimal 1 foto untuk upload';
    }

    return null;
  }

  // =====================
  // ENTRY POINT SAVE
  // =====================

  Future<void> saveDraft() async => _save(status: 'draft');
  Future<void> uploadProduct() async => _save(status: 'published');

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

      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        imageUrls = await _uploadImages(
          sellerId: sellerId,
          productId: docRef.id,
        );
      }

      final priceInt = parseInt(priceC.text) ?? 0;
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
        size: size.value,
        brand: brand.value,
        condition: condition.value,
        color: color.value,
        style: style.value,
        material: material.value,
      );

      await docRef.set(product.toMap());

      Get.snackbar(
        'Berhasil',
        status == 'draft' ? 'Draft disimpan' : 'Produk berhasil diupload',
        snackPosition: SnackPosition.BOTTOM,
      );

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

  // =====================
  // UPLOAD FOTO → SUPABASE
  // =====================

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

  // =====================
  // ATRIBUT TAMBAHAN
  // =====================

  void selectSize(String selectedSize) => size.value = selectedSize;

  List<String> getAvailableSizes() {
    final cat = categoryName.value.toLowerCase();
    if (cat.contains('footwear') ||
        cat.contains('sepatu') ||
        cat.contains('sneakers')) {
      return [
        'EU35 / US8',
        'EU36 / US8.5',
        'EU37 / US9',
        'EU38 / US9.5',
        'EU39 / US10',
        'EU40 / US10.5',
        'EU41 / US11',
        'EU42 / US11.5',
        'EU43 / US12',
        'EU44 / US12.5',
        'EU45 / US13',
        'EU46 / US13.5',
        'EU47 / US14',
        'EU47.5 / US14.5',
        'EU48 / US15',
        'One size',
        'Other',
      ];
    } else if (cat.contains('jersey')) {
      return ['S', 'M', 'L', 'XL', 'XXL', 'Lainnya'];
    } else {
      return ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'Lainnya'];
    }
  }

  final List<String> availableStyles = [
    'Avant Garde',
    'Batik',
    'Biker',
    'Casual',
    'Coquette',
    'Cosplay',
    'Cottagecore',
    'Emo',
    'Fairy',
    'Futurist',
    'Gorpcore',
    'Goth',
    'Grunge',
    'Harajuku',
    'Korean Style',
    'Minimalist',
    'Vintage',
    'Sporty',
    'Lainnya',
  ];

  final selectedStyles = <String>[].obs;

  void selectStyle(String selectedStyle) {
    if (selectedStyles.contains(selectedStyle)) {
      selectedStyles.remove(selectedStyle);
    } else {
      if (selectedStyles.length < 2) {
        selectedStyles.add(selectedStyle);
      } else {
        Get.snackbar(
          'Maksimal 2 style',
          'Kamu hanya bisa memilih 2 style.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
    style.value = selectedStyles.join(', ');
  }

  // =====================
  // BRAND
  // =====================
  void saveBrand() => brand.value = _brandController.getBrand();

  Future<void> inputBrand() async {
    final result = await _brandController.inputBrand(brand.value);
    if (result != null && result.isNotEmpty) {
      brand.value = result;
      _brandController.setBrand(result);
    }
  }

  // =====================
  // RESET & DISPOSE
  // =====================

  void _resetForm() {
    titleC.clear();
    descC.clear();
    priceC.clear();
    promoC.clear();

    priceText.value = ''; // ✅ reset text reactive

    categoryId.value = '';
    categoryName.value = '';
    size.value = '';
    brand.value = '';
    condition.value = '';
    color.value = '';
    style.value = '';
    material.value = '';
    images.clear();
    promoActive.value = false;
  }

  @override
  void onClose() {
    titleC.dispose();
    descC.dispose();
    priceC.dispose();
    promoC.dispose();
    super.onClose();
  }
}
