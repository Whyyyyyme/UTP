import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/data/repository/shipping_repository.dart';
import '../../models/shipping_method_model.dart';
import '../../view_model/shipping_controller.dart';

class SelectShippingPage extends StatelessWidget {
  const SelectShippingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final sellerId = (args['sellerId'] ?? '').toString();

    if (sellerId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('sellerId kosong. Tidak bisa memuat kurir.')),
      );
    }
    final c = Get.put(
      ShippingController(Get.find<ShippingRepository>(), sellerId: sellerId),
      tag: 'shipping_$sellerId',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kurir pengiriman'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<ShippingMethodModel>>(
        stream: c.streamEnabled(), // ✅ hanya enabled
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
                subtitle: Text(m.desc),
                onTap: () => Get.back(result: m), // ✅ return ke checkout
              );
            },
          );
        },
      ),
    );
  }
}
