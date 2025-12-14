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
import 'package:prelovedly/models/image_model.dart';

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
  final images = <SellImage>[].obs;

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

  final canPublish = false.obs;

  @override
  void onInit() {
    super.onInit();

    // listener untuk field yang bukan Rx (TextEditingController)
    titleC.addListener(_recalcCanPublish);
    descC.addListener(_recalcCanPublish);
    priceC.addListener(_recalcCanPublish);
    promoC.addListener(_recalcCanPublish);

    // listener untuk field Rx
    ever(categoryName, (_) => _recalcCanPublish());
    ever(categoryId, (_) => _recalcCanPublish());
    ever(priceText, (_) => _recalcCanPublish());

    ever(size, (_) => _recalcCanPublish());
    ever(brand, (_) => _recalcCanPublish());
    ever(condition, (_) => _recalcCanPublish());
    ever(color, (_) => _recalcCanPublish());
    ever(style, (_) => _recalcCanPublish());
    ever(material, (_) => _recalcCanPublish());

    ever(promoActive, (_) => _recalcCanPublish());
    ever<List>(images, (_) => _recalcCanPublish());

    _recalcCanPublish();
  }

  void _recalcCanPublish() {
    final titleOk = titleC.text.trim().isNotEmpty;
    final descOk = descC.text.trim().isNotEmpty;

    final categoryOk = categoryName.value.trim().isNotEmpty;

    // harga valid (min 25.000)
    final price = parseInt(
      priceText.value.isNotEmpty ? priceText.value : priceC.text,
    );
    final priceOk = price != null && price >= 25000;

    // minimal 1 foto untuk publish
    final imagesOk = images.isNotEmpty;

    // semua atribut wajib (sesuai request kamu)
    final sizeOk = size.value.trim().isNotEmpty;
    final brandOk = brand.value.trim().isNotEmpty;
    final conditionOk = condition.value.trim().isNotEmpty;
    final colorOk = color.value.trim().isNotEmpty;
    final styleOk = style.value.trim().isNotEmpty;
    final materialOk = material.value.trim().isNotEmpty;

    // promo jika aktif harus valid
    bool promoOk = true;
    if (promoActive.value) {
      final promo = parseInt(promoC.text);
      final maxPromo = price == null ? 0 : (price * 0.8).floor();
      promoOk = promo != null && promo >= 5000 && promo <= maxPromo;
    }

    canPublish.value =
        titleOk &&
        descOk &&
        categoryOk &&
        priceOk &&
        imagesOk &&
        sizeOk &&
        brandOk &&
        conditionOk &&
        colorOk &&
        styleOk &&
        materialOk &&
        promoOk;
  }

  final _modeReady = false.obs;
  String? _lastLoadedDraftId;

  void prepareCreate() {
    // kalau sedang edit, reset dulu
    if (isEditing || _modeReady.value) {
      _resetForm();
    }
    _modeReady.value = true;
    _lastLoadedDraftId = null;
  }

  Future<void> prepareEditDraft(String productId) async {
    if (_lastLoadedDraftId == productId && isEditing) return;
    await loadDraft(productId);
    _lastLoadedDraftId = productId;
    _modeReady.value = true;
  }

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
      images.add(SellImage.local(picked));
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
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (promoActive.value) {
      final promo = parseInt(promoC.text);
      if (promo == null) {
        Get.snackbar(
          'Promo ongkir',
          'Masukkan nominal promo ongkir',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final int maxPromo = (price * 0.8).floor();

      if (promo < 5000 || promo > maxPromo) {
        Get.snackbar(
          'Promo ongkir tidak valid',
          'Min. Rp 5.000 dan maks. Rp ${_formatter.format(maxPromo)}',
          snackPosition: SnackPosition.TOP,
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

  Future<bool> saveDraft() => _save(status: 'draft');
  Future<bool> uploadProduct() => _save(status: 'published');

  Future<bool> _save({required String status}) async {
    final auth = AuthController.to;
    final currentUser = auth.user.value;

    if (currentUser == null) {
      Get.snackbar('Error', 'Kamu belum login');
      return false;
    }

    final error = _validate(publish: status == 'published');
    if (error != null) {
      Get.snackbar('Error', error);
      return false;
    }

    try {
      isSaving.value = true;

      final sellerId = currentUser.id;
      final now = Timestamp.now();

      final docRef = isEditing
          ? _db.collection('products').doc(editingProductId.value!)
          : _db.collection('products').doc();

      // ✅ kalau edit: ambil data lama dulu (buat createdAt & image lama)
      Map<String, dynamic>? oldData;
      if (isEditing) {
        final oldDoc = await docRef.get();
        oldData = oldDoc.data();
      }

      // ✅ upload hanya kalau ada gambar baru
      final List<String> uploadedUrls = images.isNotEmpty
          ? await _uploadImages(sellerId: sellerId, productId: docRef.id)
          : <String>[];

      // ✅ kalau tidak upload gambar baru saat edit -> pakai image_urls lama
      final List<String> finalImageUrls = uploadedUrls.isNotEmpty
          ? uploadedUrls
          : (oldData?['image_urls'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                <String>[];

      final priceInt = parseInt(priceC.text) ?? 0;

      final product = ProductModel(
        id: docRef.id, // ✅ id konsisten doc.id
        sellerId: sellerId,
        title: titleC.text.trim(),
        description: descC.text.trim(),
        categoryId: categoryId.value,
        categoryName: categoryName.value,
        price: priceInt,
        imageUrls: finalImageUrls,
        status: status,

        // ✅ createdAt tidak boleh berubah saat edit
        createdAt: isEditing ? (oldData?['created_at'] ?? now) : now,

        updatedAt: now,

        size: size.value,
        brand: brand.value,
        condition: condition.value,
        color: color.value,
        style: style.value,
        material: material.value,
      );

      await docRef.set(product.toMap(), SetOptions(merge: true));

      Get.snackbar(
        'Berhasil',
        status == 'draft' ? 'Draft disimpan' : 'Produk berhasil diupload',
        snackPosition: SnackPosition.BOTTOM,
      );

      _resetForm();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan produk: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
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
      // 1) kalau URL lama (draft), langsung simpan lagi
      if (img.isUrl) {
        urls.add(img.url!);
        continue;
      }

      // 2) kalau lokal, upload ke supabase
      final xfile = img.local!;
      final fileName =
          '$sellerId/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        final resp = await _supabase.storage
            .from('product_photos')
            .uploadBinary(fileName, bytes);

        if (resp.isEmpty) throw Exception('Upload gagal (web)');
      } else {
        final file = File(xfile.path);
        final resp = await _supabase.storage
            .from('product_photos')
            .upload(fileName, file);

        if (resp.isEmpty) throw Exception('Upload gagal (mobile)');
      }

      final publicUrl = _supabase.storage
          .from('product_photos')
          .getPublicUrl(fileName);
      urls.add(publicUrl);
    }

    return urls;
  }

  Future<bool> updateProduct(String productId) async {
    final auth = AuthController.to;
    final currentUser = auth.user.value;

    if (currentUser == null) {
      Get.snackbar('Error', 'Kamu belum login');
      return false;
    }

    final error = _validate(publish: true); // edit published harus valid
    if (error != null) {
      Get.snackbar('Error', error);
      return false;
    }

    try {
      isSaving.value = true;

      final sellerId = currentUser.id;
      final now = Timestamp.now();

      final docRef = _db.collection('products').doc(productId);

      // ambil data lama untuk jaga created_at
      final oldDoc = await docRef.get();
      final oldData = oldDoc.data() ?? {};

      // upload + merge image (SellImage sudah handle url vs local)
      final finalImageUrls = await _uploadImages(
        sellerId: sellerId,
        productId: productId,
      );

      final priceInt =
          parseInt(
            priceText.value.isNotEmpty ? priceText.value : priceC.text,
          ) ??
          0;

      await docRef.set({
        'title': titleC.text.trim(),
        'description': descC.text.trim(),
        'category_id': categoryId.value,
        'category_name': categoryName.value,
        'size': size.value,
        'brand': brand.value,
        'condition': condition.value,
        'color': color.value,
        'style': style.value,
        'material': material.value,
        'price': priceInt,
        'image_urls': finalImageUrls,
        'status': 'published',
        'created_at': oldData['created_at'] ?? now,
        'updated_at': now,
      }, SetOptions(merge: true));

      Get.snackbar(
        'Berhasil',
        'Perubahan disimpan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      debugPrint('updateProduct error: $e');
      Get.snackbar(
        'Error',
        'Gagal menyimpan perubahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> moveProductToDraft(String productId) async {
    try {
      isSaving.value = true;
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'status': 'draft', 'updated_at': Timestamp.now()});
      return true;
    } catch (e) {
      debugPrint('moveProductToDraft error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  //  Edit Draft Product
  final editingProductId = RxnString();
  bool get isEditing => editingProductId.value != null;

  void startCreate() {
    editingProductId.value = null;
    _resetForm();
  }

  Future<void> loadDraft(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    final data = doc.data();
    if (data == null) throw Exception('Draft tidak ditemukan');

    editingProductId.value = productId;

    titleC.text = (data['title'] ?? '').toString();
    descC.text = (data['description'] ?? '').toString();

    categoryId.value = (data['category_id'] ?? data['categoryId'] ?? '')
        .toString();
    categoryName.value = (data['category_name'] ?? data['categoryName'] ?? '')
        .toString();

    final priceRaw = data['price'];
    final priceInt = priceRaw is int
        ? priceRaw
        : int.tryParse('$priceRaw') ?? 0;
    final formatted = _formatter.format(priceInt);
    priceC.text = formatted;
    priceText.value = formatted;

    size.value = (data['size'] ?? '').toString();
    brand.value = (data['brand'] ?? '').toString();
    condition.value = (data['condition'] ?? '').toString();
    color.value = (data['color'] ?? '').toString();
    style.value = (data['style'] ?? '').toString();
    material.value = (data['material'] ?? '').toString();

    // preload images dari image_urls
    final List raw = (data['image_urls'] as List?) ?? [];
    images.assignAll(raw.map((e) => SellImage.url(e.toString())).toList());
  }

  // Edit Product
  Future<void> loadProductForEdit(String productId) async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (!doc.exists) return;
    final data = doc.data() ?? {};

    // isi form
    titleC.text = (data['title'] ?? '').toString();
    descC.text = (data['description'] ?? '').toString();

    categoryId.value = (data['category_id'] ?? '').toString();
    categoryName.value = (data['category_name'] ?? '').toString();

    size.value = (data['size'] ?? '').toString();
    brand.value = (data['brand'] ?? '').toString();
    condition.value = (data['condition'] ?? '').toString();
    color.value = (data['color'] ?? '').toString();
    style.value = (data['style'] ?? '').toString();
    material.value = (data['material'] ?? '').toString();

    final p = data['price'];
    priceText.value = (p ?? '').toString(); // kalau kamu pakai priceText
    priceC.text = (p ?? '').toString(); // kalau kamu pakai priceC juga

    // gambar
    images.clear();
    final urls =
        (data['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];

    images.assignAll(urls.map((u) => SellImage.url(u)).toList());
  }

  // ATRIBUT TAMBAHAN

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
          snackPosition: SnackPosition.TOP,
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

  Future<void> startEditDraft(String productId) async {
    await loadDraft(productId);
  }

  Future<void> deleteDraft() async {
    final id = editingProductId.value;
    if (id == null) return;

    try {
      await _db.collection('products').doc(id).delete();

      Get.snackbar(
        'Berhasil',
        'Draft berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );

      _resetForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus draft: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
    editingProductId.value = null;
    canPublish.value = false;
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
