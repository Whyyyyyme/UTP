import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prelovedly/models/product_model.dart';

class ManageProductController extends GetxController {
  final isLoading = true.obs;
  final product = Rxn<ProductModel>();

  late final String productId;

  @override
  void onInit() {
    super.onInit();
    productId = Get.parameters['id'] ?? '';
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading.value = true;

      if (productId.isEmpty) {
        product.value = null;
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (!doc.exists) {
        product.value = null;
        return;
      }

      product.value = ProductModel.fromDoc(doc);
    } catch (e) {
      product.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsSold() async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'status': 'sold', 'updated_at': Timestamp.now()});
    await _load();
  }

  Future<void> toggleDiscount(bool enabled) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'discount_active': enabled, 'updated_at': Timestamp.now()});
    await _load();
  }

  Future<void> deleteProduct() async {
    try {
      isLoading.value = true;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      Get.snackbar(
        'Berhasil',
        'Produk berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back(); // keluar dari halaman manage product
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus produk: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
