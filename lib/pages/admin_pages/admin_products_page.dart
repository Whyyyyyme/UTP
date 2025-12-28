// lib/pages/admin_pages/admin_products_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/admin_products_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/utils/rupiah.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  // ===== THEME =====
  static const Color _bg = Color(0xFFF5F6FA);

  // =======================
  // CONFIRM PUBLISH / HIDE
  // =======================
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
        content: Text(
          'Apakah Anda yakin ingin $actionText produk berikut?\n\n$title',
        ),
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
    );

    return result == true;
  }

  // =======================
  // CONFIRM DELETE PRODUCT
  // =======================
  Future<bool> _confirmDelete({required String title}) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
          'Produk ini akan DIHAPUS PERMANEN dari sistem.\n\n$title\n\nTindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    return result == true;
  }

  /// =======================
  /// Helper sold-out
  /// =======================
  bool _isSoldOut(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString().toLowerCase();

    final byStatus =
        status == 'sold' ||
        status == 'sold_out' ||
        status == 'soldout' ||
        status == 'checkout' ||
        status == 'checked_out' ||
        status == 'completed' ||
        status == 'done' ||
        status == 'terjual';

    final byBool =
        data['isSold'] == true ||
        data['sold'] == true ||
        data['is_sold'] == true ||
        data['isSoldOut'] == true ||
        data['soldOut'] == true;

    final stockRaw = data['stock'];
    final byStock = stockRaw is num ? stockRaw <= 0 : false;

    return byStatus || byBool || byStock;
  }

  /// =======================
  /// Helper parsing price -> num
  /// (biar rupiah() aman walau price string)
  /// =======================
  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return 0;

    // buang karakter non angka
    final cleaned = s.replaceAll(RegExp(r'[^0-9]'), '');
    return num.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProductsController());

    // loading delete product
    final RxnString deletingIdRx = RxnString();

    // cache seller name
    final Map<String, Future<String>> sellerNameCache = {};

    Future<String> fetchSellerName(String sellerId) {
      if (sellerId.trim().isEmpty || sellerId == '-') {
        return Future.value('Tidak diketahui');
      }

      return sellerNameCache.putIfAbsent(sellerId, () async {
        try {
          final snap = await FirebaseFirestore.instance
              .collection('users')
              .doc(sellerId)
              .get();

          if (!snap.exists) return 'Tidak diketahui';

          final data = snap.data()!;
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

          return name.isEmpty ? 'Tidak diketahui' : name;
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
              subtitle: 'Publish / Hidden / Delete Produk Seller',
              onBack: () => Get.back(),
            ),

            // SEARCH + FILTER
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
                      onChanged: controller.setFilterStatus,
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
                    final notSoldDocs = rawDocs
                        .where((d) => !_isSoldOut(d.data()))
                        .toList();

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

                        // ✅ ambil price raw lalu parsing ke num
                        final dynamic priceRaw = data['price'] ?? 0;
                        final num priceNum = _toNum(priceRaw);

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
                              final sellerName = snapName.data ?? 'Memuat...';

                              return _ProductCard(
                                productId: productId,
                                title: title,
                                priceNum: priceNum, // ✅ kirim num
                                sellerId: sellerId,
                                sellerName: sellerName,
                                thumbUrl: thumb,
                                isPublished: isPublished,
                                togglingIdRx: controller.togglingProductId,
                                deletingIdRx: deletingIdRx,
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
                                onDelete: () async {
                                  final ok = await _confirmDelete(title: title);
                                  if (!ok) return;

                                  try {
                                    deletingIdRx.value = productId;
                                    await FirebaseFirestore.instance
                                        .collection('products')
                                        .doc(productId)
                                        .delete();

                                    Get.snackbar(
                                      'Berhasil',
                                      'Produk dihapus permanen.',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      'Gagal',
                                      'Tidak bisa hapus produk:\n$e',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } finally {
                                    deletingIdRx.value = null;
                                  }
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
// HEADER
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
// SEARCH FIELD
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
// FILTER DROPDOWN
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
            DropdownMenuItem(value: 'draft', child: Text('Draft (Seller)')),
            DropdownMenuItem(value: 'hidden', child: Text('Hidden (Admin)')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ==========================
// PRODUCT CARD
// ==========================
class _ProductCard extends StatelessWidget {
  final String productId;
  final String title;

  final num priceNum; // ✅ sekarang num, bukan string

  final String sellerId;
  final String sellerName;

  final String? thumbUrl;
  final bool isPublished;

  final RxnString togglingIdRx;
  final RxnString deletingIdRx;

  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.productId,
    required this.title,
    required this.priceNum,
    required this.sellerId,
    required this.sellerName,
    required this.thumbUrl,
    required this.isPublished,
    required this.togglingIdRx,
    required this.deletingIdRx,
    required this.onToggle,
    required this.onDelete,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 56,
              height: 56,
              color: Colors.grey.shade200,
              child: thumbUrl == null || thumbUrl!.isEmpty
                  ? const Icon(Icons.image_not_supported)
                  : Image.network(
                      thumbUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),

                // ✅ INI YANG MEMPERBAIKI FORMAT HARGA
                Text(
                  rupiah(priceNum),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 6),
                Text(
                  'Seller: $sellerName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                _Pill(text: statusText, color: statusColor),
              ],
            ),
          ),

          Obx(() {
            final isToggling = togglingIdRx.value == productId;
            final isDeleting = deletingIdRx.value == productId;

            return Row(
              children: [
                IconButton(
                  onPressed: (isToggling || isDeleting) ? null : onDelete,
                  icon: isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete, color: Colors.red),
                ),
                Switch(
                  value: isPublished,
                  onChanged: (isToggling || isDeleting) ? null : onToggle,
                ),
              ],
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
