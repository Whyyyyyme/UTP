import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryListPage extends StatefulWidget {
  final String title;
  final List<String> options;

  const CategoryListPage({
    super.key,
    required this.options,
    this.title = 'Pilih Kategori',
  });

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final RxString _query = ''.obs;

  List<String> get _filtered {
    final q = _query.value.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options.where((e) => e.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ======== SEARCH BAR ========
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => _query.value = v,
                      decoration: const InputDecoration(
                        hintText: 'Cari kategori',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ======== LIST ========
            Expanded(
              child: Obx(() {
                final items = _filtered;

                if (items.isEmpty) {
                  return const Center(child: Text('Kategori tidak ditemukan'));
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // INI KUNCI: return pilihan ke halaman sebelumnya
                        Get.back(result: item);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
