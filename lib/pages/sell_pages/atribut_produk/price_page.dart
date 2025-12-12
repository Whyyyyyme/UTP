import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prelovedly/controller/sell_controller.dart';

class PricePage extends StatelessWidget {
  const PricePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SellController controller = Get.find<SellController>();
    final formatter = NumberFormat.decimalPattern('id');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Harga',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rp',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  TextField(
                    controller: controller.priceC,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                    onChanged: controller.setFormattedPriceFromRaw,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Minimum Rp 25.000',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // ===== CARD PROMO ONGKIR =====
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 22),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Aktifkan promo ongkir',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Pembeli lebih cenderung membeli produk yang memiliki diskon ongkir',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Switch reaktif + auto clear promo saat off
                              Obx(() {
                                return Switch(
                                  value: controller.promoActive.value,
                                  onChanged: (val) {
                                    controller.togglePromo(val);
                                    if (!val)
                                      controller.promoC
                                          .clear(); // ✅ clear saat off
                                  },
                                );
                              }),
                            ],
                          ),
                        ),

                        // Bagian promo tampil/hilang
                        Obx(() {
                          final active = controller.promoActive.value;
                          if (!active) return const SizedBox.shrink();

                          final price = controller.parseInt(
                            controller.priceText.value,
                          );
                          final maxPromo = price == null
                              ? 0
                              : (price * 0.8).floor();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Text(
                                  'Max promo ongkir yang kamu tanggung',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Rp',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: controller.promoC,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '0',
                                        ),
                                        // ✅ format promo + angka-only
                                        onChanged:
                                            controller.setFormattedPromoFromRaw,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Text(
                                  'Min. Rp 5.000 & Max. Rp ${formatter.format(maxPromo)} (80% harga produkmu)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.savePrice();

                  final price = controller.parseInt(controller.priceText.value);
                  if (price == null || price < 25000) return;

                  if (!controller.promoActive.value) {
                    Get.back();
                    return;
                  }

                  final promo = controller.parseInt(controller.promoC.text);
                  final maxPromo = (price * 0.8).floor();
                  if (promo != null && promo >= 5000 && promo <= maxPromo) {
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
