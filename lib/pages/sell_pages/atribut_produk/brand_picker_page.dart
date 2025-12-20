import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/product/brand_controller.dart';

class BrandPickerPage extends StatelessWidget {
  const BrandPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BrandController brandController = Get.find<BrandController>();

    const brands = [
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
    ];

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
            onPressed: () =>
                Get.back(), // ✅ cukup back, sinkron ada di controller
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text(
              'Lainnya',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Pilih ini kalau brand tidak ada',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            trailing: Obx(() {
              final selected = brandController.brand.value.trim();
              return Radio<String>(
                value: 'Lainnya',
                groupValue: selected.isEmpty ? 'Lainnya' : selected,
                onChanged: (val) {
                  if (val == null) return;
                  brandController.setBrand('Lainnya');
                  Get.back();
                },
              );
            }),
            onTap: () {
              brandController.setBrand('Lainnya');
              Get.back();
            },
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

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

          Expanded(
            child: ListView.separated(
              itemCount: brands.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final b = brands[index];

                return ListTile(
                  title: Text(b),
                  trailing: Obx(() {
                    return Radio<String>(
                      value: b,
                      groupValue: brandController.brand.value,
                      onChanged: (val) {
                        if (val == null) return;
                        brandController.setBrand(val);
                        Get.back();
                      },
                    );
                  }),
                  onTap: () {
                    brandController.setBrand(b);
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
