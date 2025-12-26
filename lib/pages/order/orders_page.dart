import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/utils/rupiah.dart';

import '../../view_model/orders_controller.dart';
import '../../models/order_model.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<OrdersController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Pesanan',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: TabBar(
              indicatorColor: Colors.black,
              indicatorWeight: 2.2,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: [
                Tab(text: 'Terjual'),
                Tab(text: 'Dibeli'),
              ],
            ),
          ),
        ),
        body: Obx(() {
          if (vm.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              // ================= TERJUAL =================
              Obx(() {
                final err = vm.soldError.value;
                if (err != null) {
                  return _OrdersError(
                    message: err,
                    buttonText: '+ Tambah item',
                    onTap: () => Get.toNamed(Routes.sellProduct),
                  );
                }
                return _OrdersTab(
                  list: vm.sold,
                  emptyTitle: 'Belum ada penjualan',
                  emptySubtitle: 'Kalau kamu jual barang, bakal muncul di sini',
                  buttonText: '+ Tambah item',
                  assetPath: 'assets/butterfly.png',
                  onTap: () => Get.toNamed(Routes.sellProduct),
                );
              }),

              // ================= DIBELI =================
              Obx(() {
                final err = vm.boughtError.value;
                if (err != null) {
                  return _OrdersError(
                    message: err,
                    buttonText: 'Mulai belanja',
                    onTap: () => Get.toNamed(Routes.home),
                  );
                }
                return _OrdersTab(
                  list: vm.bought,
                  emptyTitle: 'Belum ada pembelian',
                  emptySubtitle: 'Kalau kamu beli barang, bakal muncul di sini',
                  buttonText: 'Mulai belanja',
                  assetPath: 'assets/eyes.png',
                  onTap: () => Get.toNamed(Routes.home),
                  showReceiveButton: true,
                  onReceive: (orderId) async {
                    await vm.markAsReceived(
                      orderId,
                    ); // pastikan method ini ada di OrdersController
                  },
                );
              }),
            ],
          );
        }),
      ),
    );
  }
}

class _OrdersError extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onTap;

  const _OrdersError({
    required this.message,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.black26),
            const SizedBox(height: 14),
            const Text(
              'Tidak bisa memuat data',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final List<OrderModel> list;
  final String emptyTitle;
  final String emptySubtitle;
  final String buttonText;
  final String assetPath;
  final VoidCallback onTap;
  final bool showReceiveButton;
  final Future<void> Function(String orderId)? onReceive;

  const _OrdersTab({
    required this.list,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.buttonText,
    required this.assetPath,
    required this.onTap,
    this.showReceiveButton = false,
    this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<OrdersController>();

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 110,
                height: 110,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_outlined,
                  size: 90,
                  color: Colors.black26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final o = list[i];
        final sellerUid = o.sellerUids.isNotEmpty
            ? o.sellerUids.first.toString()
            : '';

        vm.ensureOrderItemPreview(o.id);
        vm.ensureUserPreview(sellerUid);

        final item = vm.orderItemPreview[o.id] ?? {};
        final title = (item['title'] ?? 'Produk').toString();
        final imageUrl = (item['image_url'] ?? '').toString();

        final seller = vm.userPreview[sellerUid] ?? {};
        final sellerName = (seller['nama'] ?? '').toString();
        final sellerUsername = (seller['username'] ?? '').toString();
        final foto = (seller['foto_profil_url'] ?? '').toString();

        final dt = o.createdAt?.toDate();
        final dateText = dt == null
            ? ''
            : DateFormat('dd MMM yyyy', 'id_ID').format(dt);

        final canReceive = showReceiveButton && o.status != 'received';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey.shade200,
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : const Icon(
                              Icons.image_outlined,
                              color: Colors.black26,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateText.isEmpty
                              ? 'Order #${o.id}'
                              : '$dateText • Order #${o.id}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: foto.isNotEmpty
                                  ? NetworkImage(foto)
                                  : null,
                              child: foto.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.black45,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sellerUsername.isNotEmpty
                                    ? '$sellerName • @$sellerUsername'
                                    : (sellerName.isNotEmpty
                                          ? sellerName
                                          : sellerUid),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${o.status}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    rupiah(o.total),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),

              if (showReceiveButton) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: canReceive
                        ? () async {
                            if (onReceive != null) await onReceive!(o.id);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      o.status == 'received'
                          ? 'Pesanan sudah diterima'
                          : 'Pesanan diterima',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
