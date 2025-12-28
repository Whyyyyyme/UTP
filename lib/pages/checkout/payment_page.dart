import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import '../../view_model/checkout_controller.dart';
import '../../models/payment_method_model.dart';

class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({super.key});

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  final vm = Get.find<CheckoutController>();

  bool _showSummary = false;
  final RxString openedGroup = ''.obs;

  String idr(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return "IDR $buf";
  }

  String formatDeadline(DateTime dt) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final d = dt.day.toString().padLeft(2, '0');
    final m = bulan[dt.month];
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');

    return 'BAYAR SEBELUM $d $m $y\nPUKUL $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final total = vm.total;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            // ====== RINGKASAN PESANAN (dropdown) ======
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _showSummary = !_showSummary),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'RINGKASAN PESANAN',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Icon(
                      _showSummary
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _showSummary
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _SummaryBox(
                subtotal: vm.subtotal,
                shippingFee: vm.shippingFee,
                promoDiscount: _toInt(vm.shipping['promo_discount']),
                total: vm.total,
                idr: idr,
                // item list singkat
                items: vm.items
                    .map(
                      (e) => _SummaryItem(title: e.title, price: e.priceFinal),
                    )
                    .toList(),
              ),
              secondChild: const SizedBox(height: 10),
            ),

            const SizedBox(height: 16),

            // ====== HEADER TOTAL BESAR ======
            Center(
              child: Column(
                children: [
                  Obx(() {
                    final dt = vm.paymentDeadline.value;
                    if (dt == null) return const SizedBox();

                    return Text(
                      formatDeadline(dt),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  Text(
                    idr(total),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'METODE PEMBAYARAN',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 10),

            // ====== DROPDOWN LIST (mirip gambar) ======
            _PaymentGroupTile(
              groupKey: 'bank',
              icon: Icons.account_balance_outlined,
              title: 'Transfer\nBank',
              openedGroup: openedGroup,
              previewRight: const _LogoRow(texts: ['mandiri', 'BNI', '+1']),
              children: [
                _PaymentOptionTile(
                  id: 'va_mandiri',
                  title: 'Mandiri Virtual Account',
                  subtitle: 'VA instan',
                  onTap: () => _pick(
                    PaymentMethodModel(
                      id: 'va_mandiri',
                      title: 'Mandiri VA',
                      subtitle: 'Virtual Account',
                      iconKey: 'bank',
                    ),
                  ),
                ),
                _PaymentOptionTile(
                  id: 'va_bni',
                  title: 'BNI Virtual Account',
                  subtitle: 'VA instan',
                  onTap: () => _pick(
                    PaymentMethodModel(
                      id: 'va_bni',
                      title: 'BNI VA',
                      subtitle: 'Virtual Account',
                      iconKey: 'bank',
                    ),
                  ),
                ),
                _PaymentOptionTile(
                  id: 'bank_transfer',
                  title: 'Transfer Bank Manual',
                  subtitle: 'Upload bukti transfer (dummy)',
                  onTap: () => _pick(
                    PaymentMethodModel(
                      id: 'bank_transfer',
                      title: 'Transfer Bank',
                      subtitle: 'Manual transfer',
                      iconKey: 'bank',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _PaymentGroupTile(
              groupKey: 'ewallet',
              icon: Icons.phone_iphone_outlined,
              title: 'E-Wallet',
              openedGroup: openedGroup,
              previewRight: const _LogoRow(
                texts: ['OVO', 'GoPay', 'ShopeePay', 'DANA'],
              ),
              children: [
                _PaymentOptionTile(
                  id: 'ewallet_ovo',
                  title: 'OVO',
                  subtitle: 'Saldo',
                  onTap: () => _pick(
                    PaymentMethodModel(
                      id: 'ewallet_ovo',
                      title: 'OVO',
                      subtitle: 'E-Wallet',
                      iconKey: 'wallet',
                    ),
                  ),
                ),
                _PaymentOptionTile(
                  id: 'ewallet_dana',
                  title: 'DANA',
                  subtitle: 'Saldo',
                  onTap: () => _pick(
                    PaymentMethodModel(
                      id: 'ewallet_dana',
                      title: 'DANA',
                      subtitle: 'E-Wallet',
                      iconKey: 'wallet',
                    ),
                  ),
                ),
                _PaymentOptionTile(
                  id: 'ewallet_gopay',
                  title: 'GoPay',
                  subtitle: 'Saldo',
                  onTap: () => _pick(
                    PaymentMethodModel(
                      id: 'ewallet_gopay',
                      title: 'GoPay',
                      subtitle: 'E-Wallet',
                      iconKey: 'wallet',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _PaymentGroupTile(
              groupKey: 'qr',
              icon: Icons.qr_code_2_outlined,
              title: 'Pembayaran QR',
              openedGroup: openedGroup,
              previewRight: const _LogoRow(texts: ['QRIS']),
              children: [
                _PaymentOptionTile(
                  id: 'qris',
                  title: 'QRIS',
                  subtitle: 'Scan QR',
                  onTap: () => _pick(
                    PaymentMethodModel(
                      id: 'qris',
                      title: 'QRIS',
                      subtitle: 'Pembayaran QR',
                      iconKey: 'qr',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const SizedBox(height: 20),

            Obx(() {
              final picked = vm.selectedPayment.value;

              return ElevatedButton(
                onPressed: picked == null
                    ? null
                    : () async {
                        final buyerId =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        if (buyerId.isEmpty) {
                          Get.snackbar('Gagal', 'Kamu belum login');
                          return;
                        }

                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

                        try {
                          await vm.payNow(buyerId, popAfter: false);

                          if (vm.error.value != null) {
                            Get.snackbar('Gagal', vm.error.value!);
                            return;
                          }

                          Get.offAllNamed(Routes.checkoutSuccess);
                        } catch (e) {
                          Get.snackbar('Gagal', e.toString());
                        } finally {
                          if (Get.isDialogOpen == true) Get.back();
                        }
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  picked == null ? 'Pilih metode pembayaran' : 'Bayar',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  void _pick(PaymentMethodModel m) {
    vm.setPayment(m);
  }
}

class _PaymentGroupTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String groupKey;
  final RxString openedGroup;
  final Widget previewRight;
  final List<Widget> children;

  const _PaymentGroupTile({
    required this.icon,
    required this.title,
    required this.groupKey,
    required this.openedGroup,
    required this.previewRight,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOpen = openedGroup.value == groupKey;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey(isOpen),
            initiallyExpanded: isOpen,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            leading: Icon(icon),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                previewRight,
                const SizedBox(width: 6),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
              ],
            ),
            onExpansionChanged: (open) {
              openedGroup.value = open ? groupKey : '';
            },
            children: children,
          ),
        ),
      );
    });
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<CheckoutController>();

    return Obx(() {
      final selectedId = vm.selectedPayment.value?.id ?? '';
      final selected = selectedId == id;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected
                ? Colors.black.withOpacity(0.06)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected ? Colors.black : Colors.black45,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.black : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: selected ? Colors.black54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.chevron_right,
                color: selected ? Colors.black : Colors.black38,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _LogoRow extends StatelessWidget {
  final List<String> texts;
  const _LogoRow({required this.texts});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: texts.map((t) {
        return Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            t,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryItem {
  final String title;
  final int price;
  _SummaryItem({required this.title, required this.price});
}

class _SummaryBox extends StatelessWidget {
  final List<_SummaryItem> items;
  final int subtotal;
  final int shippingFee;
  final int promoDiscount;
  final int total;
  final String Function(int) idr;

  const _SummaryBox({
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.promoDiscount,
    required this.total,
    required this.idr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final it in items) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    it.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  idr(it.price),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          const Divider(),
          _row('Subtotal', idr(subtotal)),
          _row('Shipping', idr(shippingFee)),
          if (promoDiscount > 0)
            _row('Promo Ongkir', 'IDR -${promoDiscount.toString()}'),
          const Divider(),
          _row('Total', idr(total), bold: true),
        ],
      ),
    );
  }

  Widget _row(String left, String right, {bool bold = false}) {
    final st = TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(left, style: st.copyWith(color: Colors.black54)),
          const Spacer(),
          Text(right, style: st),
        ],
      ),
    );
  }
}
