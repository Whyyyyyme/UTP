import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/controller/product/brand_controller.dart';
import 'package:prelovedly/controller/sell_controller.dart';

class BrandPickerPage extends StatelessWidget {
  const BrandPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BrandController brandController =
        Get.find<BrandController>(); // Use the BrandController
    final SellController sellController = Get.find<SellController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Brand',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save the selected brand
              sellController.saveBrand();
              Get.back();
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== SEARCH BAR =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: TextEditingController(
                text: brandController.brand.value,
              ),
              decoration: InputDecoration(
                hintText: 'Cari brand',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                brandController.setBrand(val); // Update brand as user types
              },
            ),
          ),
          const Divider(height: 1),

          // ===== LAINNYA =====
          ListTile(
            title: const Text(
              'Lainnya',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Pilih ini kalau brand tidak ada',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            trailing: Obx(
              () => Radio<String>(
                value: 'Lainnya',
                groupValue: brandController.brand.value.isEmpty
                    ? 'Lainnya'
                    : brandController.brand.value,
                onChanged: (val) {
                  if (val == null) return;
                  brandController.setBrand('Lainnya');
                  sellController.saveBrand();
                  Get.back();
                },
              ),
            ),
            onTap: () {
              brandController.setBrand('Lainnya');
              sellController.saveBrand();
              Get.back();
            },
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // ===== LABEL "Brand populer" =====
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Brand populer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ===== LIST BRAND POPULER =====
          Expanded(
            child: ListView.separated(
              itemCount: [
                'Uniqlo',
                'Adidas',
                'Nike',
                'Japanese brand',
                'H&M',
                'Polo Ralph Lauren',
                'Zara',
                'New Balance',
                'Dickies',
                'Puma',
              ].length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final b = [
                  'Uniqlo',
                  'Adidas',
                  'Nike',
                  'Japanese brand',
                  'H&M',
                  'Polo Ralph Lauren',
                  'Zara',
                  'New Balance',
                  'Dickies',
                  'Puma',
                ][index];

                return ListTile(
                  title: Text(b),
                  trailing: Obx(
                    () => Radio<String>(
                      value: b,
                      groupValue: brandController.brand.value,
                      onChanged: (val) {
                        if (val == null) return;
                        brandController.setBrand(val);
                        sellController.saveBrand();
                        Get.back();
                      },
                    ),
                  ),
                  onTap: () {
                    brandController.setBrand(b);
                    sellController.saveBrand();
                    Get.back();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
