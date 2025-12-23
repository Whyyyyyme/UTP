import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/shipping_method_model.dart';
import '../../view_model/shipping_controller.dart';

class SelectShippingPage extends StatelessWidget {
  const SelectShippingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShippingController>();

    if (c.sellerId.trim().isEmpty) {
      return const Scaffold(
        body: Center(child: Text('sellerId kosong. Tidak bisa memuat kurir.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kurir pengiriman'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<ShippingMethodModel>>(
        stream: c.streamEnabled(),
        builder: (context, snap) {
          final list = snap.data ?? [];
          if (snap.connectionState == ConnectionState.waiting && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (list.isEmpty) {
            return const Center(child: Text('Seller belum mengaktifkan kurir'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = list[i];
              return ListTile(
                title: Text(
                  m.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.desc),
                    const SizedBox(height: 4),
                    Text(
                      'Estimasi: ${m.eta} • Ongkir: Rp ${m.fee}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                onTap: () {
                  debugPrint('PICK ${m.name} fee=${m.fee} eta=${m.eta}');
                  Get.back(result: m);
                },
              );
            },
          );
        },
      ),
    );
  }
}
