import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/shipping_method_model.dart';
import '../../view_model/shipping_controller.dart';

class SelectShippingPage extends StatelessWidget {
  const SelectShippingPage({super.key});

  String rp(dynamic value) {
    final v = value is int ? value : int.tryParse('$value') ?? 0;
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return "Rp $buf";
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShippingController>();

    // ✅ ambil promo dari arguments (default 0)
    final args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final promo = (args['promo'] is int)
        ? args['promo'] as int
        : int.tryParse('${args['promo']}') ?? 0;

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

              final feeOriginal = m.fee;
              final discount = promo > feeOriginal ? feeOriginal : promo;
              final feeFinal = feeOriginal - discount;

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
                      'Estimasi: ${m.eta}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),

                    // ✅ Ongkir setelah promo (yang ditampilin utama)
                    Row(
                      children: [
                        Text(
                          'Ongkir: ${rp(feeFinal)}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        if (discount > 0)
                          Text(
                            rp(feeOriginal),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),

                    // ✅ info diskon
                    if (discount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Diskon ongkir: -${rp(discount)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  debugPrint(
                    'PICK ${m.name} feeOriginal=$feeOriginal promo=$promo feeFinal=$feeFinal eta=${m.eta}',
                  );
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
