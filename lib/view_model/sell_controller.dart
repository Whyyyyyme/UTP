import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:prelovedly/models/product_model.dart';
import 'package:prelovedly/models/image_model.dart';
import 'package:prelovedly/data/repository/sell_repository.dart';
import 'package:prelovedly/view_model/auth_controller.dart';
import 'package:prelovedly/view_model/product/brand_controller.dart';
import 'package:prelovedly/view_model/product/category_controller.dart';

class SellController extends GetxController {
  SellController({
    required SellRepository repo,
    required BrandController brandController,
    required AuthController authController,
  }) : _repo = repo,
       _brandController = brandController,
       _auth = authController;

  final SellRepository _repo;
  final BrandController _brandController;
  final AuthController _auth;

  // --- FORM ---
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final priceC = TextEditingController();
  final promoC = TextEditingController();

  final _formatter = NumberFormat.decimalPattern('id');

  final priceText = ''.obs;
  final images = <SellImage>[].obs;

  final categoryName = ''.obs;
  final categoryId = ''.obs;

  final size = ''.obs;
  final brand = ''.obs;
  final condition = ''.obs;
  final color = ''.obs;
  final style = ''.obs;
  final material = ''.obs;

  final promoActive = false.obs;

  final isSaving = false.obs;
  final canPublish = false.obs;

  final editingProductId = RxnString();
  bool get isEditing => editingProductId.value != null;

  // ===== STYLE =====
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

  @override
  void onInit() {
    super.onInit();

    final brandC = Get.find<BrandController>();
    ever(brandC.brand, (val) {
      brand.value = val;
    });

    titleC.addListener(_recalcCanPublish);
    descC.addListener(_recalcCanPublish);
    priceC.addListener(_recalcCanPublish);
    promoC.addListener(_recalcCanPublish);

    everAll([
      categoryName,
      categoryId,
      priceText,
      size,
      brand,
      condition,
      color,
      style,
      material,
      promoActive,
    ], (_) => _recalcCanPublish());

    ever<List<SellImage>>(images, (_) => _recalcCanPublish());

    _recalcCanPublish();
  }

  // =====================
  // ENTRY POINT buat page
  // =====================
  /// Dipakai di JualPage: sell.startCreate();
  void startCreate() => prepareCreate();

  /// Dipakai di EditDraftPage: sell.startEditDraft(id);
  Future<void> startEditDraft(String productId) => prepareEditDraft(productId);

  // =====================
  // HELPERS
  // =====================
  int? parseInt(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

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
    priceText.value = formatted;
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

  void togglePromo(bool value) => promoActive.value = value;

  void _recalcCanPublish() {
    final titleOk = titleC.text.trim().isNotEmpty;
    final descOk = descC.text.trim().isNotEmpty;
    final categoryOk = categoryName.value.trim().isNotEmpty;

    final price = parseInt(
      priceText.value.isNotEmpty ? priceText.value : priceC.text,
    );
    final priceOk = price != null && price >= 25000;

    final imagesOk = images.isNotEmpty;

    final sizeOk = size.value.trim().isNotEmpty;
    final brandOk = brand.value.trim().isNotEmpty;
    final conditionOk = condition.value.trim().isNotEmpty;
    final colorOk = color.value.trim().isNotEmpty;
    final styleOk = style.value.trim().isNotEmpty;
    final materialOk = material.value.trim().isNotEmpty;

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

  String? _validate({required bool publish}) {
    if (titleC.text.trim().isEmpty) return 'Judul wajib diisi';
    if (descC.text.trim().isEmpty) return 'Deskripsi wajib diisi';
    if (categoryName.value.trim().isEmpty) return 'Kategori belum dipilih';

    final p = parseInt(priceC.text);
    if (p == null || p < 25000) return 'Harga minimal Rp 25.000';

    if (publish && images.isEmpty) return 'Tambah minimal 1 foto';

    if (size.value.trim().isEmpty) return 'Size belum dipilih';
    if (brand.value.trim().isEmpty) return 'Brand belum dipilih';
    if (condition.value.trim().isEmpty) return 'Condition belum dipilih';
    if (color.value.trim().isEmpty) return 'Color belum dipilih';
    if (style.value.trim().isEmpty) return 'Style belum dipilih';
    if (material.value.trim().isEmpty) return 'Material belum dipilih';

    if (promoActive.value) {
      final price = parseInt(priceC.text) ?? 0;
      final promo = parseInt(promoC.text);
      final maxPromo = (price * 0.8).floor();
      if (promo == null) return 'Masukkan promo ongkir';
      if (promo < 5000 || promo > maxPromo) {
        return 'Promo min Rp 5.000 dan maks Rp ${_formatter.format(maxPromo)}';
      }
    }

    return null;
  }

  // =================
  //      Price
  // =================
  void savePrice() {
    final price = parseInt(
      priceText.value.isNotEmpty ? priceText.value : priceC.text,
    );

    // harga wajib & minimal
    if (price == null || price < 25000) {
      Get.snackbar(
        'Harga tidak valid',
        'Minimal harga Rp 25.000',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // kalau promo aktif, promo wajib valid
    if (promoActive.value) {
      final promo = parseInt(promoC.text);
      final maxPromo = (price * 0.8).floor();

      if (promo == null) {
        Get.snackbar(
          'Promo ongkir',
          'Masukkan nominal promo ongkir',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

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

  bool trySavePriceAndPop() {
    savePrice();

    final price = parseInt(
      priceText.value.isNotEmpty ? priceText.value : priceC.text,
    );
    if (price == null || price < 25000) return false;

    if (!promoActive.value) {
      Get.back();
      return true;
    }

    final promo = parseInt(promoC.text);
    final maxPromo = (price * 0.8).floor();

    if (promo != null && promo >= 5000 && promo <= maxPromo) {
      Get.back();
      return true;
    }

    return false;
  }

  void setPromoActive(bool val) {
    promoActive.value = val;
    if (!val) promoC.clear();
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
    if (picked != null) images.add(SellImage.local(picked));
  }

  void removeImageAt(int index) {
    if (index >= 0 && index < images.length) images.removeAt(index);
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

  void selectBrand(String value) {
    brand.value = value;
  }

  void setColorFromList(List<String> colors) {
    color.value = colors.join(', ');
  }

  void setCondition(String val) {
    condition.value = val;
  }

  void setMaterial(String val) {
    material.value = val;
  }

  // =====================
  // MODE
  // =====================
  void prepareCreate() {
    // reset + mode create
    editingProductId.value = null;
    _resetForm();
  }

  Future<void> prepareEditDraft(String productId) async {
    await loadDraft(productId);
  }

  Future<void> loadDraft(String productId) async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

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

    promoActive.value = (data['promo_shipping_active'] ?? false) == true;

    final promoRaw = data['promo_shipping_amount'];
    final promoInt = promoRaw is int
        ? promoRaw
        : int.tryParse('$promoRaw') ?? 0;

    if (promoActive.value && promoInt > 0) {
      promoC.text = _formatter.format(promoInt);
    } else {
      promoC.clear();
    }

    // style multi (kalau kamu simpan "A, B")
    selectedStyles.clear();
    if (style.value.trim().isNotEmpty) {
      selectedStyles.assignAll(
        style.value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
      );
    }

    final raw = (data['image_urls'] as List?) ?? [];
    images.assignAll(raw.map((e) => SellImage.url(e.toString())).toList());
  }

  // =====================
  // SAVE
  // =====================
  Future<bool> saveDraft() => _save(status: 'draft');
  Future<bool> uploadProduct() => _save(status: 'published');

  Future<bool> _save({required String status}) async {
    final currentUser = _auth.user.value;
    if (currentUser == null) {
      Get.snackbar('Error', 'Kamu belum login');
      return false;
    }

    final err = _validate(publish: status == 'published');
    if (err != null) {
      Get.snackbar('Error', err, snackPosition: SnackPosition.TOP);
      return false;
    }

    try {
      isSaving.value = true;

      final sellerId = currentUser.id;
      final now = Timestamp.now();

      final docRef = await _repo.resolveDocRef(
        isEditing: isEditing,
        editingProductId: editingProductId.value,
      );

      final oldData = await _repo.getOldDataIfEditing(
        isEditing: isEditing,
        docRef: docRef,
      );

      final finalImageUrls = await _repo.uploadImagesAndMerge(
        sellerId: sellerId,
        productId: docRef.id,
        images: images.toList(),
        oldData: oldData,
      );

      final priceInt = parseInt(priceC.text) ?? 0;

      final product = ProductModel(
        id: docRef.id,
        sellerId: sellerId,
        title: titleC.text.trim(),
        description: descC.text.trim(),
        categoryId: categoryId.value,
        categoryName: categoryName.value,
        price: priceInt,
        imageUrls: finalImageUrls,
        status: status,
        createdAt: isEditing ? (oldData?['created_at'] ?? now) : now,
        updatedAt: now,
        size: size.value,
        brand: brand.value,
        condition: condition.value,
        color: color.value,
        style: style.value,
        material: material.value,
        promoShippingActive: promoActive.value,
        promoShippingAmount: promoActive.value
            ? (parseInt(promoC.text) ?? 0)
            : 0,
      );

      await _repo.saveProduct(docRef: docRef, data: product.toMap());

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

  Future<bool> moveProductToDraft(String productId) async {
    try {
      isSaving.value = true;
      await _repo.moveToDraft(productId);
      return true;
    } catch (_) {
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteDraftById(String productId) async {
    if (productId.isEmpty) return false;

    try {
      isSaving.value = true;

      await _repo.deleteDraft(productId);

      Get.snackbar(
        'Berhasil',
        'Draft berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );

      if (editingProductId.value == productId) {
        _resetForm();
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus draft: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickCategory() async {
    final categoryC = Get.find<CategoryController>();
    final result = await categoryC.pickCategory3Level();
    if (result == null) return;

    categoryName.value = (result['full'] ?? '').toString();
    categoryId.value =
        '${result['gender']}/${result['section']}/${result['item']}';
  }

  Future<void> loadProductForEdit(String productId) async {
    await loadDraft(productId);
  }

  Future<bool> updateProduct(String productId) async {
    editingProductId.value = productId;

    return _save(status: 'published');
  }

  // =====================
  // ATRIBUT TAMBAHAN: SIZE
  // =====================
  void selectSize(String selectedSize) => size.value = selectedSize;

  List<String> getAvailableSizes() {
    final cat = categoryName.value.toLowerCase().trim();

    final isFootwear =
        cat.contains('footwear') ||
        cat.contains('sepatu') ||
        cat.contains('sneakers') ||
        cat.contains('shoes');

    if (isFootwear) {
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
        'Lainnya',
      ];
    }

    if (cat.contains('jersey')) {
      return ['S', 'M', 'L', 'XL', 'XXL', 'Lainnya'];
    }

    return ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'Lainnya'];
  }

  // =====================
  // ATRIBUT TAMBAHAN: STYLE
  // =====================
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
  // RESET & DISPOSE
  // =====================
  void _resetForm() {
    titleC.clear();
    descC.clear();
    priceC.clear();
    promoC.clear();

    priceText.value = '';
    categoryId.value = '';
    categoryName.value = '';
    size.value = '';
    brand.value = '';
    condition.value = '';
    color.value = '';
    style.value = '';
    material.value = '';

    selectedStyles.clear();
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
