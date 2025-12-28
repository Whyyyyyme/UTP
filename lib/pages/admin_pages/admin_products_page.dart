import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/admin_products_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  // ===== THEME =====
  static const Color _bg = Color(0xFFF5F6FA);

  Future<bool> _confirmToggle({
    required bool nextPublished,
    required String title,
  }) async {
    final actionText = nextPublished
        ? 'menampilkan (publish)'
        : 'menyembunyikan';

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin $actionText produk:\n\n$title'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya'),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    return result == true;
  }

  /// ✅ Helper sold-out: produk yang sudah terjual tidak ditampilkan
  bool _isSoldOut(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString().toLowerCase();

    final bool byStatus =
        status == 'sold' ||
        status == 'sold_out' ||
        status == 'soldout' ||
        status == 'checkout' ||
        status == 'checked_out' ||
        status == 'completed' ||
        status == 'done' ||
        status == 'terjual';

    final bool byBool =
        data['isSold'] == true ||
        data['sold'] == true ||
        data['is_sold'] == true ||
        data['isSoldOut'] == true ||
        data['soldOut'] == true;

    final dynamic stockRaw = data['stock'];
    final bool byStock = stockRaw is num ? stockRaw <= 0 : false;

    return byStatus || byBool || byStock;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProductsController());

    // ✅ cache nama seller supaya tidak fetch berulang
    final Map<String, Future<String>> sellerNameCache = {};

    Future<String> fetchSellerName(String sellerId) {
      if (sellerId.trim().isEmpty || sellerId == '-') {
        return Future.value('Tidak diketahui');
      }
      return sellerNameCache.putIfAbsent(sellerId, () async {
        try {
          // ✅ asumsi: collection users, docId = UID
          final snap = await FirebaseFirestore.instance
              .collection('users')
              .doc(sellerId)
              .get();

          if (!snap.exists) return 'Tidak diketahui';

          final data = snap.data() as Map<String, dynamic>;

          // coba beberapa kemungkinan nama field
          final name =
              (data['username'] ??
                      data['name'] ??
                      data['full_name'] ??
                      data['fullName'] ??
                      data['displayName'] ??
                      data['email'] ??
                      '')
                  .toString()
                  .trim();

          if (name.isEmpty) return 'Tidak diketahui';
          return name;
        } catch (_) {
          return 'Tidak diketahui';
        }
      });
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _GradientHeader(
              title: 'Semua Produk',
              subtitle: 'Publish/hidden produk seller',
              onBack: () => Get.back(),
            ),

            // SEARCH + FILTER (modern)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _SearchField(
                      hint: 'Cari produk...',
                      onChanged: controller.setSearchQuery,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(
                    () => _FilterDropdown(
                      value: controller.statusFilter.value,
                      onChanged: (v) => controller.setFilterStatus(v),
                    ),
                  ),
                ],
              ),
            ),

            // LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.streamProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat produk:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final rawDocs = snapshot.data!.docs;

                  return Obx(() {
                    // ✅ 1) Hilangkan produk sold out dulu
                    final notSoldDocs = rawDocs.where((d) {
                      final data = d.data();
                      return !_isSoldOut(data);
                    }).toList();

                    // ✅ 2) Baru apply filter search & dropdown
                    final docs = controller.applyFilter(notSoldDocs);

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Produk tidak ditemukan'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data();

                        final productId = (data['id'] ?? doc.id).toString();
                        final title = (data['title'] ?? '-').toString();
                        final price = data['price'] ?? 0;

                        // seller id
                        final sellerId = (data['seller_id'] ?? '-').toString();

                        final status = (data['status'] ?? 'published')
                            .toString()
                            .toLowerCase();
                        final isPublished = status == 'published';

                        final urls = (data['image_urls'] is List)
                            ? data['image_urls'] as List
                            : <dynamic>[];

                        final thumb = urls.isNotEmpty
                            ? urls.first.toString()
                            : null;

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Get.toNamed(
                              Routes.adminProductDetail,
                              arguments: {'productId': productId},
                            );
                          },
                          child: FutureBuilder<String>(
                            future: fetchSellerName(sellerId),
                            builder: (context, snapName) {
                              final sellerName = (snapName.data ?? 'Memuat...')
                                  .toString();

                              return _ProductCard(
                                productId: productId,
                                title: title,
                                price: price.toString(),
                                sellerId: sellerId,
                                sellerName: sellerName, // ✅ tampil nama
                                thumbUrl: thumb,
                                isPublished: isPublished,
                                togglingIdRx: controller.togglingProductId,
                                onToggle: (val) async {
                                  final ok = await _confirmToggle(
                                    nextPublished: val,
                                    title: title,
                                  );
                                  if (!ok) return;

                                  await controller.togglePublished(
                                    productId: productId,
                                    nextPublished: val,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// HEADER (linear dashboard)
// ==========================
class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _GradientHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E2E72), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================
// SEARCH FIELD (modern)
// ==========================
class _SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================
// FILTER DROPDOWN (modern)
// ==========================
class _FilterDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Semua')),
            DropdownMenuItem(value: 'published', child: Text('Published')),
            DropdownMenuItem(value: 'draft', child: Text('Draft (seller)')),
            DropdownMenuItem(value: 'hidden', child: Text('Hidden (Admin)')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ==========================
// PRODUCT CARD (modern)
// ==========================
class _ProductCard extends StatelessWidget {
  final String productId;
  final String title;
  final String price;

  final String sellerId;
  final String sellerName;

  final String? thumbUrl;
  final bool isPublished;

  final RxnString togglingIdRx;
  final ValueChanged<bool> onToggle;

  const _ProductCard({
    required this.productId,
    required this.title,
    required this.price,
    required this.sellerId,
    required this.sellerName,
    required this.thumbUrl,
    required this.isPublished,
    required this.togglingIdRx,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isPublished ? Colors.green : Colors.red;
    final statusText = isPublished ? 'Published' : 'Hidden';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // THUMB
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 56,
              height: 56,
              color: Colors.grey.shade200,
              child: (thumbUrl == null || thumbUrl!.isEmpty)
                  ? const Icon(Icons.image_not_supported, color: Colors.grey)
                  : Image.network(
                      thumbUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp $price',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),

                // ✅ tampil nama seller
                Text(
                  'Seller: $sellerName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // (opsional) kalau kamu masih mau lihat UID kecil:
                const SizedBox(height: 2),
                Text(
                  sellerId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),
                _Pill(text: statusText, color: statusColor),
              ],
            ),
          ),

          const SizedBox(width: 10),
          Obx(() {
            final isLoading = togglingIdRx.value == productId;
            return SizedBox(
              width: 92,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Switch(
                      value: isPublished,
                      onChanged: isLoading ? null : onToggle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isLoading)
                    const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
