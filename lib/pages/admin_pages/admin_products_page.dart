import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/admin_products_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  Future<bool> _confirmToggle({
    required bool nextPublished,
    required String title,
  }) async {
    final actionText = nextPublished
        ? 'menampilkan (publish)'
        : 'menyembunyikan';

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin $actionText produk:\n\n$title'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya'),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProductsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Produk'),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          // ================= SEARCH + FILTER =================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: controller.setSearchQuery,
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => DropdownButton<String>(
                    value: controller.statusFilter.value,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua')),
                      DropdownMenuItem(
                        value: 'published',
                        child: Text('Published'),
                      ),
                      DropdownMenuItem(value: 'draft', child: Text('Draft (seller)')),
                      DropdownMenuItem(
                        value: 'hidden',
                        child: Text('Hidden (Admin)'),
                      ),
                    ],
                    onChanged: controller.setFilterStatus,
                  ),
                ),

              ],
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: controller.streamProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat produk:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rawDocs = snapshot.data!.docs;

                // ✅ Obx DI DALAM builder (ini yang bener)
                return Obx(() {
                  final docs = controller.applyFilter(rawDocs);

                  if (docs.isEmpty) {
                    return const Center(child: Text('Produk tidak ditemukan'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data();

                      final productId = (data['id'] ?? doc.id).toString();
                      final title = (data['title'] ?? '-').toString();
                      final price = data['price'] ?? 0;
                      final sellerId = (data['seller_id'] ?? '-').toString();
                      final status = (data['status'] ?? 'published').toString();

                      final isPublished = status == 'published';

                      final urls = (data['image_urls'] is List)
                          ? data['image_urls'] as List
                          : <dynamic>[];
                      final thumb = urls.isNotEmpty
                          ? urls.first.toString()
                          : null;

                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            Routes.adminProductDetail,
                            arguments: {'productId': productId},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // THUMBNAIL
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 54,
                                  width: 54,
                                  color: Colors.grey.shade200,
                                  child: (thumb == null || thumb.isEmpty)
                                      ? const Icon(Icons.image_not_supported)
                                      : Image.network(
                                          thumb,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Rp $price'),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Seller: $sellerId',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),

                              // TOGGLE (Obx kecil tetap boleh)
                              Obx(() {
                                final isLoading =
                                    controller.togglingProductId.value ==
                                    productId;

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: isPublished,
                                      onChanged: isLoading
                                          ? null
                                          : (val) async {
                                              final ok = await _confirmToggle(
                                                nextPublished: val,
                                                title: title,
                                              );
                                              if (!ok) return;

                                              await controller.togglePublished(
                                                productId: productId,
                                                nextPublished: val,
                                              );
                                            },
                                    ),
                                    isLoading
                                        ? const SizedBox(
                                            height: 12,
                                            width: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            isPublished
                                                ? 'Published'
                                                : 'Hidden',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isPublished
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
