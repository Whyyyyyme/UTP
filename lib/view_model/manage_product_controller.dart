import 'dart:async';

import 'package:get/get.dart';
import 'package:prelovedly/models/product_model.dart';
import '../data/repository/manage_product_repository.dart';

class ManageProductController extends GetxController {
  ManageProductController(this.repo);

  final ManageProductRepository repo;

  final isLoading = true.obs;
  final product = Rxn<ProductModel>();

  late final String productId;

  // stats realtime
  final likes = 0.obs;
  final offers = 0.obs; // (belum dipakai, tetap 0)
  final carts = 0.obs;

  final discountActive = false.obs;

  StreamSubscription<int>? _likesSub;
  StreamSubscription<int>? _cartsSub;

  @override
  void onInit() {
    super.onInit();
    productId = Get.parameters['id'] ?? (Get.arguments?['id'] ?? '').toString();

    _load();
    _listenStats(); // ✅ realtime likes & carts
  }

  void _listenStats() {
    _likesSub?.cancel();
    _cartsSub?.cancel();

    _likesSub = repo.likesCountStream(productId).listen((count) {
      likes.value = count;
    });

    _cartsSub = repo.cartsCountStream(productId).listen((count) {
      carts.value = count;
    });
  }

  @override
  void onClose() {
    _likesSub?.cancel();
    _cartsSub?.cancel();
    super.onClose();
  }

  Future<void> _load() async {
    try {
      isLoading.value = true;
      product.value = await repo.fetchProduct(productId);

      // kalau diskon disimpan di product, kamu bisa sinkronkan di sini
      // final p = product.value;
      // if (p != null) discountActive.value = p.discountActive;
    } catch (_) {
      product.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<(bool, String)> markAsSold() async {
    try {
      await repo.markAsSold(productId);
      await _load();
      return (true, 'Produk ditandai sold');
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> toggleDiscount(bool enabled) async {
    try {
      await repo.toggleDiscount(productId, enabled);
      await _load();
      return (true, enabled ? 'Diskon diaktifkan' : 'Diskon dimatikan');
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> deleteProduct() async {
    try {
      isLoading.value = true;

      await repo.deleteProduct(productId);

      Get.snackbar(
        'Berhasil',
        'Produk berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
      return (true, 'Produk dihapus');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus produk: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return (false, e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
