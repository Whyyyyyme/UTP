import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/pages/profile_pages/address/add_address_page.dart';
import '../../models/address_model.dart';
import '../../view_model/address_controller.dart';

class SelectAddressPage extends StatelessWidget {
  const SelectAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AddressController.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pilih Alamat',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.to(() => AddAddressPage()),
            child: const Text('Tambah', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: StreamBuilder<List<AddressModel>>(
        stream: c.userAddressesStream(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'Belum ada alamat',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final a = items[i];

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () async {
                  await c.pickAddress(a);
                  Get.back(result: a); // ✅ balik ke checkout
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        a.isDefault
                            ? Icons.check_circle
                            : Icons.location_on_outlined,
                        color: a.isDefault ? Colors.green : Colors.black54,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${a.receiverName} • ${a.phone}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a.regionDetail,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            if (a.isDefault) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Default',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'default') {
                            final res = await c.setDefault(a);
                            if (!res.$1) Get.snackbar('Error', res.$2);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'default',
                            child: Text('Jadikan default'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
