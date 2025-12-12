import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/product/material_picker_controller.dart';
import 'package:prelovedly/controller/sell_controller.dart';

class MaterialPickerPage extends StatelessWidget {
  const MaterialPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengakses MaterialPickerController
    final MaterialPickerController controller = Get.put(
      MaterialPickerController(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Material',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.search, size: 24),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subheader
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              'Pilih maksimal 3 opsi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          // List material
          // List material
          Expanded(
            child: Obx(() {
              controller.selectedList.length; // paksa Obx baca RxList

              return ListView.separated(
                itemCount: controller.materials.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = controller.materials[index];
                  final isSelected = controller.selectedList.contains(
                    item.name,
                  );

                  return ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      item.sub,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) {
                        controller.toggleMaterialSelection(
                          item.name,
                          !isSelected,
                        );
                      },
                    ),
                    onTap: () {
                      controller.toggleMaterialSelection(
                        item.name,
                        !isSelected,
                      );
                    },
                  );
                },
              );
            }),
          ),

          Obx(() {
            final disabled = controller.selectedList.isEmpty;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: disabled ? Colors.grey[300] : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: disabled
                    ? null
                    : () {
                        final sell = Get.find<SellController>();
                        sell.material.value = controller.selectedList.join(
                          ', ',
                        );
                        Get.back();
                      },
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
