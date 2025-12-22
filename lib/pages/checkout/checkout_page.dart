import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/models/address_model.dart';
import 'package:prelovedly/models/shipping_method_model.dart';
import 'package:prelovedly/pages/checkout/select_address_page.dart';
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

  @override
  void initState() {
    super.initState();
    vm = Get.find<CheckoutController>();
    session = SessionController.to;

    final uid = session.viewerId.value;
    if (uid.isNotEmpty) {
      vm.load(uid);
    }
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

      // ✅ ambil sellerId dari item pertama (karena UI kamu memang pakai first item)
      final String sellerId = vm.items.isNotEmpty
          ? vm.items.first.sellerId
          : '';

      // ✅ ambil shipping untuk seller itu
      final sh = sellerId.isEmpty
          ? {'method': '', 'fee': 0, 'eta': ''}
          : vm.shippingFor(sellerId);

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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
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
                    _ItemRow(
                      title: vm.items.first.title,
                      size: vm.items.first.size,
                      imageUrl: vm.items.first.imageUrl,
                      priceFinal: rp(vm.items.first.priceFinal),
                      priceOriginal: rp(vm.items.first.priceOriginal),
                    ),
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
                      final res = await Get.to<AddressModel>(
                        () => const SelectAddressPage(),
                      );
                      if (res != null) {
                        AddressController.to.selectedAddress.value = res;
                        // ❌ gak perlu setState karena Obx akan rebuild
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // ===== Shipping
                  _SectionTile(
                    title: 'Pengiriman',
                    subtitle: (sh['method'] ?? '').toString().isEmpty
                        ? 'Pilih pengiriman'
                        : '${sh['method']} • ${sh['eta']}',
                    onTap: sellerId.isEmpty
                        ? () {
                            Get.snackbar(
                              'Info',
                              'SellerId tidak ditemukan dari item checkout',
                            );
                          }
                        : () async {
                            final sellerId = vm.items.isNotEmpty
                                ? vm.items.first.sellerId
                                : '';
                            final picked = await Get.toNamed(
                              Routes.selectShipping,
                              arguments: {'sellerId': sellerId},
                            );

                            if (picked is ShippingMethodModel) {
                              vm.setShippingForSeller(
                                sellerId: sellerId,
                                method: picked.name,
                                fee:
                                    0, // nanti bisa diisi dari method kalau ada fee
                                eta:
                                    '-', // nanti bisa diisi jika kamu punya ETA
                              );
                            }
                          },
                  ),

                  const SizedBox(height: 18),
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
                onPressed: vm.canPay ? () async => vm.payNow(uid) : null,
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
