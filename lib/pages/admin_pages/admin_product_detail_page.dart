// lib/pages/admin_pages/admin_product_detail_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/utils/rupiah.dart';

class AdminProductDetailPage extends StatelessWidget {
  const AdminProductDetailPage({super.key});

  // ===== THEME =====
  static const Color _bg = Color(0xFFF5F6FA);

  // cache nama user biar hemat reads (static)
  static final Map<String, Future<String>> _userNameCache = {};

  Future<String> _fetchUserName(String uid) {
    if (uid.trim().isEmpty || uid == '-') return Future.value('Tidak diketahui');

    return _userNameCache.putIfAbsent(uid, () async {
      try {
        final snap =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (!snap.exists) return 'Tidak diketahui';

        final data = snap.data() as Map<String, dynamic>;
        final name = (data['username'] ??
                data['nama'] ??
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

  Color _statusColor(String s) {
    final v = s.toLowerCase();
    if (v == 'published') return Colors.green;
    if (v == 'hidden') return Colors.red;
    if (v == 'draft') return Colors.orange;
    return Colors.blueGrey;
  }

  String _statusLabel(String s) {
    final v = s.toLowerCase();
    if (v == 'published') return 'Published';
    if (v == 'hidden') return 'Hidden';
    if (v == 'draft') return 'Draft';
    return s;
  }

  // num safety
  num _toNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  // grid columns responsive
  int _gridCrossAxisCount(double width) {
    if (width >= 1100) return 6;
    if (width >= 800) return 5;
    if (width >= 520) return 4;
    if (width >= 380) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map<String, dynamic>?) ?? {};
    final productId = (args['productId'] ?? '').toString();

    if (productId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Product ID tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _GradientHeader(
              title: 'Detail Produk',
              subtitle: 'Informasi lengkap barang',
              onBack: () => Get.back(),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Text('Gagal memuat detail: ${snap.error}'),
                    );
                  }

                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final doc = snap.data!;
                  if (!doc.exists) {
                    return const Center(child: Text('Produk tidak ditemukan'));
                  }

                  final data = doc.data() ?? <String, dynamic>{};

                  final title = (data['title'] ?? '-').toString();
                  final desc = (data['description'] ?? '').toString();

                  final num priceNum = _toNum(data['price'] ?? 0);

                  final sellerId = (data['seller_id'] ?? '-').toString();
                  final statusRaw = (data['status'] ?? 'published').toString();

                  final List<dynamic> urls = (data['image_urls'] is List)
                      ? (data['image_urls'] as List)
                      : <dynamic>[];

                  final thumb = urls.isNotEmpty ? urls.first.toString() : '';

                  final statusColor = _statusColor(statusRaw);
                  final statusText = _statusLabel(statusRaw);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxis =
                          _gridCrossAxisCount(constraints.maxWidth);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HERO IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                height: 220,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: thumb.isEmpty
                                    ? const Center(
                                        child: Icon(Icons.image_not_supported),
                                      )
                                    : Image.network(
                                        thumb,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // MAIN CARD
                            Container(
                              width: double.infinity,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TITLE + STATUS
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      _Pill(
                                        text: statusText,
                                        color: statusColor,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // PRICE
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.payments_rounded,
                                        size: 18,
                                        color: Color(0xFF0E2E72),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        rupiah(priceNum),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // SELLER
                                  FutureBuilder<String>(
                                    future: _fetchUserName(sellerId),
                                    builder: (context, snapName) {
                                      final sellerName =
                                          snapName.data ?? 'Memuat...';
                                      final showSeller =
                                          sellerName == 'Tidak diketahui'
                                              ? sellerId
                                              : sellerName;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const _InfoLabel('Seller'),
                                          const SizedBox(height: 4),
                                          Text(
                                            showSeller,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            sellerId,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  // DESCRIPTION
                                  const _InfoLabel('Deskripsi'),
                                  const SizedBox(height: 6),
                                  Text(
                                    desc.isEmpty ? '-' : desc,
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // OTHER IMAGES
                            if (urls.length > 1) ...[
                              const _SectionTitle(
                                title: 'Foto Lainnya',
                                subtitle: 'Gambar tambahan produk',
                              ),
                              const SizedBox(height: 10),

                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: urls.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxis,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: (context, i) {
                                  final url = urls[i].toString();
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: Colors.grey.shade200,
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================
/// HEADER (samakan admin pages)
/// ==========================
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoLabel extends StatelessWidget {
  final String text;
  const _InfoLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
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
