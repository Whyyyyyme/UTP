import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/sell_controller.dart';

class StylePickerPage extends StatelessWidget {
  const StylePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sell = Get.find<SellController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Styles',
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
              // ✅ pastikan Rx terbaca
              final _ = sell.selectedStyles.length;

              return ListView.separated(
                itemCount: sell.availableStyles.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = sell.availableStyles[index];
                  final isSelected = sell.selectedStyles.contains(item);

                  return InkWell(
                    onTap: () => sell.selectStyle(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(item)),
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => sell.selectStyle(item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          Obx(() {
            final disabled = sell.selectedStyles.isEmpty;

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
                onPressed: disabled ? null : () => Get.back(),
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
