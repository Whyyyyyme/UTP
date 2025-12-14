import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/product/category_controller.dart';
import 'package:prelovedly/controller/sell_controller.dart';

import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/sell/sell_add_photo_card.dart';
import 'package:prelovedly/widgets/sell/sell_label.dart';
import 'package:prelovedly/widgets/sell/sell_photo_preview_card.dart';

class SellFormBody extends StatelessWidget {
  final VoidCallback onAfterSave;

  final String leftText;
  final String rightText;
  final Future<bool> Function()? onLeftPressed;
  final Future<bool> Function()? onRightPressed;

  const SellFormBody({
    super.key,
    required this.onAfterSave,
    this.leftText = "Save draft",
    this.rightText = "Upload",
    this.onLeftPressed,
    this.onRightPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SellController>();
    final categoryController = Get.find<CategoryController>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO
                Obx(() {
                  return SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: c.images.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return SellAddPhotoCard(onTap: c.pickImage);
                        }
                        final img = c.images[index - 1];
                        return SellPhotoPreviewCard(
                          image: img,
                          onRemove: () => c.removeImageAt(index - 1),
                        );
                      },
                    ),
                  );
                }),

                const Divider(height: 1),

                const SizedBox(height: 12),
                const SellLabel("Judul"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: c.titleC,
                    decoration: const InputDecoration(
                      hintText: "cth. Levi's baggy jeans hitam",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const Divider(height: 1),

                const SizedBox(height: 12),
                const SellLabel("Deskripsi"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: c.descC,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'cth. Jarang dipakai, size M, bahan adem...',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const Divider(height: 1),

                // KATEGORI
                ListTile(
                  title: const Text("Kategori"),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: Obx(
                    () => Text(
                      c.categoryName.value.isEmpty
                          ? 'Pilih kategori'
                          : c.categoryName.value,
                      style: TextStyle(
                        color: c.categoryName.value.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () async {
                    final result = await categoryController
                        .pickCategory3Level();
                    if (result == null) return;

                    c.categoryName.value = result['full'] ?? '';
                    c.categoryId.value =
                        '${result['gender']}/${result['section']}/${result['item']}';
                  },
                ),

                const Divider(height: 1),

                // ================= UKURAN =================
                ListTile(
                  title: const Text("Ukuran"),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: Obx(
                    () => Text(
                      c.size.value.isEmpty ? 'Pilih ukuran' : c.size.value,
                      style: TextStyle(
                        color: c.size.value.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () => Get.toNamed(Routes.size),
                ),
                const Divider(height: 1),

                // BRAND
                ListTile(
                  title: const Text("Brand"),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: Obx(
                    () => Text(
                      c.brand.value.isEmpty ? 'Tambahkan brand' : c.brand.value,
                      style: TextStyle(
                        color: c.brand.value.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () => Get.toNamed(Routes.brand),
                ),
                const Divider(height: 1),

                // KONDISI
                ListTile(
                  title: const Text("Kondisi"),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: Obx(
                    () => Text(
                      c.condition.value.isEmpty
                          ? 'Pilih kondisi'
                          : c.condition.value,
                      style: TextStyle(
                        color: c.condition.value.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () => Get.toNamed(Routes.condition),
                ),
                const Divider(height: 1),

                // WARNA
                ListTile(
                  title: const Text("Warna"),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: Obx(
                    () => Text(
                      c.color.value.isEmpty ? 'Pilih warna' : c.color.value,
                      style: TextStyle(
                        color: c.color.value.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () => Get.toNamed(Routes.color),
                ),
                const Divider(height: 1),

                // STYLES
                ListTile(
                  title: const Text("Styles"),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: Obx(
                    () => Text(
                      c.style.value.isEmpty ? 'Pilih style' : c.style.value,
                      style: TextStyle(
                        color: c.style.value.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () => Get.toNamed(Routes.style),
                ),
                const Divider(height: 1),

                // MATERIAL
                ListTile(
                  title: const Text("Material"),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: Obx(
                    () => Text(
                      c.material.value.isEmpty
                          ? 'Pilih material'
                          : c.material.value,
                      style: TextStyle(
                        color: c.material.value.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () => Get.toNamed(Routes.material),
                ),
                const Divider(height: 1),

                // HARGA
                ListTile(
                  title: const Text('Harga'),
                  trailing: const Icon(Icons.chevron_right),
                  subtitle: Obx(() {
                    final text = c.priceText.value.trim();
                    return Text(
                      text.isEmpty ? 'Masukkan harga' : 'Rp $text',
                      style: TextStyle(
                        color: text.isEmpty ? Colors.grey[500] : Colors.black,
                      ),
                    );
                  }),
                  onTap: () => Get.toNamed(Routes.price),
                ),
              ],
            ),
          ),
        ),

        Obx(() {
          final saving = c.isSaving.value;
          final canUpload = c.canPublish.value;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final fn = onLeftPressed ?? c.saveDraft;
                            final ok = await fn();
                            if (ok) onAfterSave();
                          },
                    child: Text(leftText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            // default upload harus tetap pakai canUpload
                            if (onRightPressed == null && !canUpload) return;

                            final fn = onRightPressed ?? c.uploadProduct;
                            final ok = await fn();
                            if (ok) onAfterSave();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text(rightText),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
