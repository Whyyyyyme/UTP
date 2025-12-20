import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/product/material_picker_controller.dart';
import 'package:prelovedly/view_model/sell_controller.dart';

class MaterialPickerPage extends StatefulWidget {
  const MaterialPickerPage({super.key});

  @override
  State<MaterialPickerPage> createState() => _MaterialPickerPageState();
}

class _MaterialPickerPageState extends State<MaterialPickerPage> {
  late final MaterialPickerController c;
  late final SellController sell;

  @override
  void initState() {
    super.initState();
    c = Get.find<MaterialPickerController>();
    sell = Get.find<SellController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.preloadFromSell(sell.material.value);
    });
  }

  void _save() {
    if (!c.canSave) return;
    sell.setMaterial(c.selectedAsString); // ✅ commit via SellController
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              'Pilih maksimal 3 opsi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: Obx(() {
              // ✅ WAJIB: paksa Obx membaca Rx
              final _ = c.selected.length;
              final selected = c.selected; // RxList<String>

              return ListView.separated(
                itemCount: c.materials.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = c.materials[index];
                  final isSelected = selected.contains(item.name);

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
                      onChanged: (_) => c.toggle(item.name),
                    ),
                    onTap: () => c.toggle(item.name),
                  );
                },
              );
            }),
          ),

          Obx(() {
            // ✅ canSave harus baca Rx (lihat controller di bawah)
            final disabled = !c.canSave;

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
                onPressed: disabled ? null : _save,
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
