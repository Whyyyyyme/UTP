import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prelovedly/models/order_model.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/wallet_orders_controller.dart';

class WalletPage extends GetView<WalletOrdersController> {
  const WalletPage({super.key});

  String rupiah(int v) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final err = controller.error.value;
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _PendingRow(
                label: 'Saldo tertunda',
                value: rupiah(controller.pendingBalance.value),
                onInfo: () => Get.snackbar(
                  'Saldo tertunda',
                  'saldo masuk setelah pesanan selesai.',
                ),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Mau cuan lebih?',
                subtitle:
                    'Semakin banyak upload barang, makin gampang pembeli menemukanmu.',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _BalanceCard(
                balanceText: rupiah(controller.availableBalance.value),
                buttonEnabled: controller.canWithdraw,
                onWithdraw: () => Get.toNamed(Routes.withdraw),
              ),
              const SizedBox(height: 16),
              if (err != null) ...[
                Text(
                  err,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              _TxSection(grouped: controller.grouped),
            ],
          ),
        );
      }),
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({
    required this.label,
    required this.value,
    required this.onInfo,
  });

  final String label;
  final String value;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        InkWell(
          onTap: onInfo,
          child: Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.flash_on_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balanceText,
    required this.buttonEnabled,
    required this.onWithdraw,
  });

  final String balanceText;
  final bool buttonEnabled;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Text(
            balanceText,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text('Saldo tersedia', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: buttonEnabled ? onWithdraw : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                disabledBackgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text('Cairkan saldo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TxSection extends StatelessWidget {
  const _TxSection({required this.grouped});
  final Map<String, List<OrderModel>> grouped;

  @override
  Widget build(BuildContext context) {
    if (grouped.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          'Belum ada transaksi.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final entries = grouped.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(
              e.key,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          for (final o in e.value) _TxTile(order: o),
        ],
      ],
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.order});
  final OrderModel order;

  String rupiah(int v) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(v);

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt?.toDate();
    final dateText = date == null
        ? ''
        : DateFormat('dd MMM yyyy', 'id_ID').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pemasukan penjualan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  dateText.isEmpty
                      ? 'Order #${order.id}'
                      : '$dateText • Order #${order.id}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Text(
            rupiah(order.subtotal),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
