import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/sell_controller.dart';

class SizePickerPage extends StatelessWidget {
  const SizePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SellController controller = Get.find<SellController>();

    // Mendapatkan kategori yang dipilih
    final String cat = controller.categoryName.value.toLowerCase();
    final bool isFootwear =
        cat.contains('footwear') ||
        cat.contains('sepatu') ||
        cat.contains('sneakers');
    // final bool isJersey = cat.contains('jersey');

    // Mendapatkan daftar ukuran berdasarkan kategori
    final availableSizes = controller.getAvailableSizes();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ukuran',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final selected = controller.size.value;

        // Jika kategori adalah Footwear, tampilkan opsi ukuran EU / US
        if (isFootwear) {
          return ListView.separated(
            itemCount: availableSizes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = availableSizes[index];
              return InkWell(
                onTap: () {
                  controller.selectSize(item); // Memilih ukuran
                  Get.back(); // Langsung kembali setelah memilih
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 16)),
                      ),
                      Radio<String>(
                        value: item,
                        groupValue: selected,
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectSize(val); // Memilih ukuran
                            Get.back();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // Jika kategori adalah Jersey atau lainnya
        return ListView.separated(
          itemCount: availableSizes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = availableSizes[index];
            return InkWell(
              onTap: () {
                controller.selectSize(item); // Memilih ukuran
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 16)),
                    ),
                    Radio<String>(
                      value: item,
                      groupValue: selected,
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectSize(val); // Memilih ukuran
                          Get.back();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
