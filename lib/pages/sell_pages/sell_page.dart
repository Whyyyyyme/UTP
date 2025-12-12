import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/product/category_controller.dart';

import 'package:prelovedly/controller/sell_controller.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/brand_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/color_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/condition_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/material_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/price_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/size_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/style_picker_page.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/sell/sell_add_photo_card.dart';
import 'package:prelovedly/widgets/sell/sell_label.dart';
import 'package:prelovedly/widgets/sell/sell_photo_preview_card.dart';

class JualPage extends StatelessWidget {
  const JualPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lebih aman: cari dulu kalau sudah ada, kalau belum baru put.
    final SellController c = Get.isRegistered<SellController>()
        ? Get.find()
        : Get.put(SellController());

    final CategoryController categoryController =
        Get.isRegistered<CategoryController>()
        ? Get.find()
        : Get.put(CategoryController());

    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (Get.key.currentState?.canPop() ?? false) {
                Get.back();
              } else {
                Get.offAllNamed(Routes.home);
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            'Jual',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= FOTO =================
                    SizedBox(
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
                            file: img,
                            onRemove: () => c.removeImageAt(index - 1),
                          );
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    // ================= JUDUL =================
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

                    // ================= DESKRIPSI =================
                    const SizedBox(height: 12),
                    const SellLabel("Deskripsi"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: c.descC,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'cth. Jarang dipakai, size M, bahan adem...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const Divider(height: 1),

                    // ================= KATEGORI (FIXED) =================
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

                        // Simpan hasil kategori ke SellController
                        c.categoryName.value = result['full']!;
                        c.categoryId.value =
                            '${result['gender']}/${result['section']}/${result['item']}';
                      },
                    ),

                    const Divider(height: 1),

                    // ========== ATRIBUT TAMBAHAN ==========
                    // SIZE
                    ListTile(
                      title: const Text("Ukuran"),
                      trailing: const Icon(Icons.chevron_right),
                      subtitle: Text(
                        c.size.value.isEmpty ? 'Pilih ukuran' : c.size.value,
                        style: TextStyle(
                          color: c.size.value.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      onTap: () => Get.to(() => const SizePickerPage()),
                    ),
                    const Divider(height: 1),

                    // BRAND
                    ListTile(
                      title: const Text("Brand"),
                      trailing: const Icon(Icons.chevron_right),
                      subtitle: Text(
                        c.brand.value.isEmpty
                            ? 'Tambahkan brand'
                            : c.brand.value,
                        style: TextStyle(
                          color: c.brand.value.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      onTap: () => Get.to(() => const BrandPickerPage()),
                    ),
                    const Divider(height: 1),

                    // CONDITION
                    ListTile(
                      title: const Text("Kondisi"),
                      trailing: const Icon(Icons.chevron_right),
                      subtitle: Text(
                        c.condition.value.isEmpty
                            ? 'Pilih kondisi'
                            : c.condition.value,
                        style: TextStyle(
                          color: c.condition.value.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      onTap: () => Get.to(() => const ConditionPickerPage()),
                    ),
                    const Divider(height: 1),

                    // COLOR
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
                      onTap: () async {
                        await Get.to(() => ColorPickerPage());
                      },
                    ),

                    const Divider(height: 1),

                    // STYLE
                    ListTile(
                      title: const Text("Styles"),
                      trailing: const Icon(Icons.chevron_right),
                      subtitle: Text(
                        c.style.value.isEmpty ? 'Pilih style' : c.style.value,
                        style: TextStyle(
                          color: c.style.value.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      onTap: () => Get.to(() => const StylePickerPage()),
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
                      onTap: () => Get.to(() => const MaterialPickerPage()),
                    ),

                    const Divider(height: 1),

                    // ================= HARGA =================
                    ListTile(
                      title: const Text('Harga'),
                      trailing: const Icon(Icons.chevron_right),
                      subtitle: Obx(() {
                        final text = c.priceText.value.trim();
                        return Text(
                          text.isEmpty ? 'Masukkan harga' : 'Rp $text',
                          style: TextStyle(
                            color: text.isEmpty
                                ? Colors.grey[500]
                                : Colors.black,
                          ),
                        );
                      }),
                      onTap: () => Get.to(() => const PricePage()),
                    ),
                  ],
                ),
              ),
            ),

            // ================= BUTTON =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: c.isSaving.value ? null : () => c.saveDraft(),
                      child: const Text("Save draft"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: c.isSaving.value
                          ? null
                          : () => c.uploadProduct(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text("Upload"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
