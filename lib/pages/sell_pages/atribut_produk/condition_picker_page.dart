import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/product/condition_picker_controller.dart';
import 'package:prelovedly/controller/sell_controller.dart';

class ConditionPickerPage extends StatelessWidget {
  const ConditionPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ConditionPickerController c =
        Get.isRegistered<ConditionPickerController>()
        ? Get.find()
        : Get.put(ConditionPickerController());

    final SellController sell = Get.find<SellController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Kondisi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Selesai', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        final selected = sell.condition.value; // ambil dari SellController

        return ListView.separated(
          itemCount: c.options.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = c.options[index];

            return InkWell(
              onTap: () {
                sell.condition.value = item.title; // set ke SellController
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.desc,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: item.title,
                      groupValue: selected,
                      onChanged: (val) {
                        if (val != null) {
                          sell.condition.value = val; // set ke SellController
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
