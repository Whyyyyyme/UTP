import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/product/color_picker_controller.dart';
import 'package:prelovedly/view_model/sell_controller.dart';

class ColorPickerPage extends StatelessWidget {
  const ColorPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ColorPickerController>();
    final sell = Get.find<SellController>();

    // preload pilihan lama (sekali aja)
    if (sell.color.value.isNotEmpty && c.selected.isEmpty) {
      c.selected.assignAll(
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
              // ✅ pastikan Rx kebaca
              final _ = c.selected.length;

              return ListView.separated(
                itemCount: c.options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = c.options[index];
                  final isSelected = c.selected.contains(item.name);

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
                      onChanged: (_) => c.toggle(item.name),
                    ),
                    onTap: () => c.toggle(item.name),
                  );
                },
              );
            }),
          ),

          Obx(() {
            final disabled = c.selected.isEmpty;

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
                        sell.color.value = c.selected.join(', ');
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
