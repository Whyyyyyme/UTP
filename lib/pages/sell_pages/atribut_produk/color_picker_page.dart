import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/product/color_picker_controller.dart';
import 'package:prelovedly/controller/sell_controller.dart';

class ColorPickerPage extends StatelessWidget {
  const ColorPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorPickerController controller =
        Get.isRegistered<ColorPickerController>()
        ? Get.find()
        : Get.put(ColorPickerController());

    final SellController sell = Get.find<SellController>();

    // preload pilihan lama (biar pas balik masuk lagi tetap ke-checklist)
    if (sell.color.value.isNotEmpty && controller.selected.isEmpty) {
      controller.selected.assignAll(
        sell.color.value.split(', ').where((e) => e.isNotEmpty),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Pilih Warna',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              'Pilih maksimal 2 opsi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: Obx(() {
              controller.selected.length; // paksa Obx membaca Rx

              return ListView.separated(
                itemCount: controller.options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = controller.options[index];
                  final isSelected = controller.selected.contains(item.name);

                  return ListTile(
                    leading: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color,
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                    ),
                    title: Text(item.name),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) => controller.toggle(item.name),
                    ),
                    onTap: () => controller.toggle(item.name),
                  );
                },
              );
            }),
          ),

          Obx(() {
            final disabled = controller.selected.isEmpty;

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
                        sell.color.value = controller.selected.join(', ');
                        Get.back();
                      },
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
