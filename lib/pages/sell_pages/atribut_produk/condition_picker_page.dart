import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/product/condition_picker_controller.dart';
import 'package:prelovedly/view_model/sell_controller.dart';

class ConditionPickerPage extends StatefulWidget {
  const ConditionPickerPage({super.key});

  @override
  State<ConditionPickerPage> createState() => _ConditionPickerPageState();
}

class _ConditionPickerPageState extends State<ConditionPickerPage> {
  late final ConditionPickerController c;
  late final SellController sell;

  @override
  void initState() {
    super.initState();
    c = Get.find<ConditionPickerController>();
    sell = Get.find<SellController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.preload(sell.condition.value); // ✅ preload sekali
    });
  }

  void _commitAndClose() {
    if (!c.canSave) {
      Get.snackbar('Kondisi kosong', 'Pilih salah satu kondisi dulu');
      return;
    }
    sell.setCondition(c.selected.value); // ✅ commit via SellController
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _commitAndClose,
            child: const Text('Selesai', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        final selected = c.selected.value;

        return ListView.separated(
          itemCount: c.options.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = c.options[index];

            return InkWell(
              onTap: () {
                c.select(item.title);
                _commitAndClose(); // kalau mau langsung back saat pilih
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
                        if (val == null) return;
                        c.select(val);
                        _commitAndClose();
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
