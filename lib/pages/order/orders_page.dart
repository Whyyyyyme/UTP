import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        final isBusy = vm.receiving[o.id] == true;
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

        // final canReceive = showReceiveButton && o.status != 'received';

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

                if (o.status != 'received')
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: (isBusy || onReceive == null)
                          ? null
                          : () async {
                              await onReceive!(o.id);
                            },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Pesanan diterima',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () => showReviewSheet(context, order: o),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Beri ulasan',
                        style: TextStyle(fontWeight: FontWeight.w800),
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

Future<void> showReviewSheet(
  BuildContext context, {
  required OrderModel order,
}) async {
  final db = FirebaseFirestore.instance;

  // seller uid untuk shop reviews
  final sellerUid = order.sellerUids.isNotEmpty
      ? order.sellerUids.first.toString()
      : '';
  if (sellerUid.isEmpty) {
    Get.snackbar('Gagal', 'Seller tidak ditemukan di order ini');
    return;
  }

  // Ambil 1 item order buat preview
  final itemSnap = await db
      .collection('orders')
      .doc(order.id)
      .collection('items')
      .limit(1)
      .get();

  if (itemSnap.docs.isEmpty) {
    Get.snackbar('Gagal', 'Item order tidak ditemukan');
    return;
  }

  final item = itemSnap.docs.first.data();
  final title = (item['title'] ?? 'Produk').toString();
  final imageUrl = (item['image_url'] ?? '').toString();
  final productId = (item['product_id'] ?? itemSnap.docs.first.id).toString();

  final authUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (authUid.isEmpty) {
    Get.snackbar('Gagal', 'Kamu belum login');
    return;
  }

  // 1 review per order+product (ID unik)
  final reviewId = '${order.id}_$productId';

  // ✅ CEK: kalau review sudah ada, jangan buka sheet
  final reviewRef = db
      .collection('sellers')
      .doc(sellerUid)
      .collection('reviews')
      .doc(reviewId);

  final reviewSnap = await reviewRef.get();
  if (reviewSnap.exists) {
    Get.snackbar('Info', 'Kamu sudah memberi ulasan untuk item ini');
    return;
  }

  final reviewC = TextEditingController();
  int rating = 5;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 44,
                        height: 44,
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
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return IconButton(
                      onPressed: () => setState(() => rating = star),
                      icon: Icon(
                        Icons.star,
                        color: star <= rating
                            ? Colors.amber
                            : Colors.grey.shade300,
                        size: 34,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: reviewC,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Contoh: Barangnya pas sesuai deskripsi.\nMinusnya dikit, Rekomen...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final text = reviewC.text.trim();
                      if (text.isEmpty) {
                        Get.snackbar('Info', 'Tulis ulasan dulu ya');
                        return;
                      }

                      // ambil buyer profile (nama + foto) untuk ditampilkan di list review
                      final buyerDoc = await db
                          .collection('users')
                          .doc(authUid)
                          .get();
                      final buyer = buyerDoc.data() ?? {};
                      final buyerName =
                          (buyer['nama'] ?? buyer['username'] ?? 'Pembeli')
                              .toString();
                      final buyerPhoto = (buyer['foto_profil_url'] ?? '')
                          .toString();

                      // double-check sebelum nulis (antisipasi user klik 2x / race)
                      final again = await reviewRef.get();
                      if (again.exists) {
                        Navigator.pop(ctx);
                        Get.snackbar('Info', 'Ulasan sudah pernah dikirim');
                        return;
                      }

                      await reviewRef.set({
                        'review_id': reviewId,
                        'order_id': order.id,
                        'product_id': productId,
                        'product_title': title,
                        'product_image_url': imageUrl,
                        'buyer_id': authUid,
                        'buyer_name': buyerName,
                        'buyer_photo_url': buyerPhoto,
                        'buyer_role': 'Pembeli',
                        'rating': rating,
                        'text': text,
                        'created_at': FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(ctx);
                      Get.snackbar('Sukses', 'Ulasan terkirim');
                    },
                    child: const Text('Kirim'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
