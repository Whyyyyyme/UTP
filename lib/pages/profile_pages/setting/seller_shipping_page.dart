import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_model/shipping_controller.dart';
import '../../../models/shipping_method_model.dart';

class SellerShippingPage extends StatelessWidget {
  const SellerShippingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShippingController>(); // dari binding

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kurir pengiriman'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<ShippingMethodModel>>(
        stream: c.streamAll(),
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: list
                      .map(
                        (m) => _ShippingTile(
                          m: m,
                          onChanged: (v) => c.toggle(m: m, enabled: v),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Perhatian! Sistem checkout hanya menampilkan kurir yang kamu aktifkan.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShippingTile extends StatelessWidget {
  final ShippingMethodModel m;
  final ValueChanged<bool> onChanged;

  const _ShippingTile({required this.m, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(m.desc, style: TextStyle(color: Colors.grey.shade700)),
      trailing: Switch(value: m.isEnabled, onChanged: onChanged),
    );
  }
}
