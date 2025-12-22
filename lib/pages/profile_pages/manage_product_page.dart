import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prelovedly/view_model/manage_product_controller.dart';
import 'package:prelovedly/models/product_model.dart';
import 'package:prelovedly/routes/app_routes.dart';

class ManageProductPage extends GetView<ManageProductController> {
  const ManageProductPage({super.key});

  String _rp(int value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _openMoreMenu(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ProductModel? p = controller.product.value;
        if (p == null) {
          return const Center(child: Text('Produk tidak ditemukan'));
        }

        final photoUrl = p.imageUrls.isNotEmpty ? p.imageUrls.first : '';

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            // ====== Header Product Card ======
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                // kalau mau arahkan ke detail product:
                // Get.toNamed(Routes.productDetail, arguments: {"id": p.id, "seller_id": p.sellerId});
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: photoUrl.isEmpty
                          ? Container(
                              width: 62,
                              height: 62,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image),
                            )
                          : Image.network(
                              photoUrl,
                              width: 62,
                              height: 62,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 62,
                                height: 62,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rp(p.price),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (p.size.isNotEmpty)
                            Text(
                              'Size ${p.size}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Lihat produk',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ====== Stats ======
            Obx(
              () => Row(
                children: [
                  _chip(
                    Icons.favorite_border,
                    '${controller.likes.value} Likes',
                  ),
                  const SizedBox(width: 8),
                  _chip(
                    Icons.chat_bubble_outline,
                    '${controller.offers.value} Offer',
                  ),
                  const SizedBox(width: 8),
                  _chip(
                    Icons.shopping_bag_outlined,
                    '${controller.carts.value} Keranjang',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Manage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            _menuTile(
              icon: Icons.edit_outlined,
              title: 'Edit produk',
              onTap: () {
                Get.toNamed(
                  Routes.editProduct,
                  arguments: {"id": controller.productId},
                );
              },
            ),
            _menuTile(
              icon: Icons.check_circle_outline,
              title: 'Tandai sudah terjual',
              onTap: () => controller.markAsSold(),
            ),
          ],
        );
      }),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  void _openMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Hapus produk',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Hapus produk?'),
                      content: const Text(
                        'Produk yang dihapus tidak bisa dikembalikan.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Get.back(result: true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );

                  if (ok == true) {
                    await controller.deleteProduct();
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
