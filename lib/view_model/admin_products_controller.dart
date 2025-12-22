// lib/view_model/admin_products_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:prelovedly/data/services/admin_product_service.dart';

class AdminProductsController extends GetxController {
  final AdminProductService _service = AdminProductService();

  final RxnString togglingProductId = RxnString();

  // search + filter state
  final query = ''.obs;

  /// filter:
  /// all | published | hidden | draft | non_published
  final statusFilter = 'all'.obs;

  void setSearchQuery(String val) => query.value = val.trim().toLowerCase();
  void setFilterStatus(String? val) {
    if (val == null) return;
    statusFilter.value = val;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProducts() {
    return _service.streamProducts();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> applyFilter(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final q = query.value;
    final f = statusFilter.value;

    return docs.where((doc) {
      final data = doc.data();

      final title = (data['title'] ?? '').toString().toLowerCase();
      final sellerId = (data['seller_id'] ?? '').toString().toLowerCase();

      // normalize status -> lowercase
      final statusRaw = (data['status'] ?? 'published').toString();
      final status = statusRaw.trim().toLowerCase();

      final matchQuery = q.isEmpty || title.contains(q) || sellerId.contains(q);

      bool matchStatus = true;
      if (f == 'all') {
        matchStatus = true;
      } else if (f == 'published') {
        matchStatus = status == 'published';
      } else if (f == 'hidden') {
        matchStatus = status == 'hidden';
      } else if (f == 'draft') {
        matchStatus = status == 'draft';
      } else if (f == 'non_published') {
        // semua selain published (draft + hidden + lainnya)
        matchStatus = status != 'published';
      }

      return matchQuery && matchStatus;
    }).toList();
  }

  Future<void> togglePublished({
    required String productId,
    required bool nextPublished,
  }) async {
    try {
      togglingProductId.value = productId;

      // kalau dimatikan -> pakai "hidden" (admin hide)
      final nextStatus = nextPublished ? 'published' : 'hidden';

      await _service.setProductStatus(productId: productId, status: nextStatus);
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak bisa mengubah status produk: $e');
    } finally {
      togglingProductId.value = null;
    }
  }
}
