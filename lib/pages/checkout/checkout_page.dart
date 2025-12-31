// lib/pages/checkout/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/models/checkout_item_model.dart';
import 'package:prelovedly/models/shipping_method_model.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/address_controller.dart';
import 'package:prelovedly/view_model/checkout_controller.dart';
import '../../view_model/session_controller.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final CheckoutController vm;
  late final SessionController session;

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

  late Worker _uidWorker;

  @override
  void initState() {
    super.initState();
    vm = Get.find<CheckoutController>();
    session = SessionController.to;

    final uid = session.viewerId.value;
    if (uid.isNotEmpty) {
      vm.load(uid);
    }

    _uidWorker = ever<String>(session.viewerId, (uid) {
      if (uid.trim().isNotEmpty) vm.load(uid);
    });
  }

  @override
  void dispose() {
    _uidWorker.dispose();
    super.dispose();
  }

  Future<void> _pickShipping(String sellerId) async {
    if (sellerId.trim().isEmpty) {
      Get.snackbar('Info', 'SellerId tidak ditemukan dari item checkout');
      return;
    }

    final picked = await Get.toNamed(
      Routes.selectShipping,
      arguments: {
        'sellerId': sellerId,
        'promo': vm.promoShippingDiscount(sellerId),
      },
    );

    if (picked is! ShippingMethodModel) return;

    vm.setShipping(
      method: picked.name,
      fee: picked.fee,
      eta: picked.eta,
      methodId: picked.id,
      methodKey: picked.key,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uid = session.viewerId.value;
      if (uid.isEmpty) {
        return const Scaffold(body: Center(child: Text('Kamu belum login')));
      }

      final loading = vm.isLoading.value;
      final err = vm.error.value;

      // ✅ single seller checkout: ambil sellerId dari item pertama
      final String sellerId = vm.items.isNotEmpty
          ? vm.items.first.sellerId
          : '';

      final shipMethod = (vm.shipping['method'] ?? '').toString();
      final shipEta = (vm.shipping['eta'] ?? '').toString();

      final feeOriginal = (vm.shipping['fee_original'] is int)
          ? vm.shipping['fee_original'] as int
          : int.tryParse('${vm.shipping['fee_original']}') ?? 0;

      final promoDiscount = (vm.shipping['promo_discount'] is int)
          ? vm.shipping['promo_discount'] as int
          : int.tryParse('${vm.shipping['promo_discount']}') ?? 0;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Checkout'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                children: [
                  if (err != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        err,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  if (vm.items.isNotEmpty) ...[
                    _CheckoutItemsCarousel(items: vm.items, rp: rp),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '${vm.items.length} item',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          rp(vm.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                  ],

                  // ===== Address
                  _SectionTile(
                    title: 'Alamat',
                    subtitle: (() {
                      final a = AddressController.to.selectedAddress.value;
                      if (a == null) return 'Pilih alamat';

                      final parts = <String>[
                        '${a.receiverName} • ${a.phone}',
                        a.regionDetail,
                      ].where((e) => e.trim().isNotEmpty).toList();

                      return parts.isEmpty ? 'Pilih alamat' : parts.join(', ');
                    })(),
                    onTap: () async {
                      // ✅ route ini harus ada di project kamu.
                      // kalau route-mu beda, ganti sesuai yang kamu pakai.
                      await Get.toNamed(Routes.selectAddress);
                    },
                  ),

                  const SizedBox(height: 12),

                  // ===== Shipping
                  _SectionTile(
                    title: 'Pengiriman',
                    subtitle: shipMethod.isEmpty
                        ? 'Pilih pengiriman'
                        : '$shipMethod${shipEta.isEmpty ? '' : ' • $shipEta'}',
                    onTap: () async => _pickShipping(sellerId),
                  ),

                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // ===== Breakdown
                  Row(
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        rp(vm.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text(
                        'Ongkir',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        rp(vm.shippingFee),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),

                  if (promoDiscount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Promo ongkir',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          '- ${rp(promoDiscount)}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],

                  if (feeOriginal > 0 && promoDiscount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Ongkir sebelum promo',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          rp(feeOriginal),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade700,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      Text(
                        rp(vm.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

        bottomSheet: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 18, color: Colors.black.withOpacity(0.10)),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    vm.items.isNotEmpty &&
                        vm.address.isNotEmpty &&
                        (vm.shipping['method'] ?? '').toString().isNotEmpty
                    ? () {
                        vm.startPaymentDeadline(); // ✅ set now + 1 jam
                        Get.toNamed(Routes.checkoutPayment);
                      }
                    : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Pilih pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _SectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final String title;
  final String size;
  final String imageUrl;
  final String priceFinal;
  final String priceOriginal;

  const _ItemRow({
    required this.title,
    required this.size,
    required this.imageUrl,
    required this.priceFinal,
    required this.priceOriginal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 56,
            height: 56,
            color: Colors.grey.shade200,
            child: imageUrl.isEmpty
                ? const Icon(Icons.image)
                : Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(
                size.isEmpty ? '-' : size,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    priceFinal,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    priceOriginal,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckoutItemsCarousel extends StatefulWidget {
  final List<CheckoutItemModel> items;
  final String Function(dynamic) rp;

  const _CheckoutItemsCarousel({required this.items, required this.rp});

  @override
  State<_CheckoutItemsCarousel> createState() => _CheckoutItemsCarouselState();
}

class _CheckoutItemsCarouselState extends State<_CheckoutItemsCarousel> {
  final PageController _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return Column(
      children: [
        SizedBox(
          height: 78, // tinggi area item preview
          child: PageView.builder(
            controller: _page,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final it = items[i];
              return _ItemRow(
                title: it.title,
                size: it.size,
                imageUrl: it.imageUrl,
                priceFinal: widget.rp(it.priceFinal),
                priceOriginal: widget.rp(it.priceOriginal),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? Colors.black : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}
