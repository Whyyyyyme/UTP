import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminProductDetailPage extends StatelessWidget {
  const AdminProductDetailPage({super.key});

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
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat detail: ${snap.error}'));
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final doc = snap.data!;
          if (!doc.exists) {
            return const Center(child: Text('Produk tidak ditemukan'));
          }

          final data = doc.data() ?? {};

          final title = (data['title'] ?? '-').toString();
          final desc = (data['description'] ?? '').toString();
          final price = (data['price'] ?? 0).toString();
          final sellerId = (data['seller_id'] ?? '-').toString();
          final status = (data['status'] ?? 'published').toString();

          final List<dynamic> urls = (data['image_urls'] is List)
              ? (data['image_urls'] as List)
              : [];
          final thumb = urls.isNotEmpty ? urls.first.toString() : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: thumb.isEmpty
                        ? const Center(child: Icon(Icons.image_not_supported))
                        : Image.network(
                            thumb,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),

                Text('Harga: Rp $price'),
                const SizedBox(height: 4),
                Text('Seller: $sellerId'),
                const SizedBox(height: 4),
                Text('Status: $status'),
                const SizedBox(height: 16),

                const Text(
                  'Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(desc.isEmpty ? '-' : desc),

                const SizedBox(height: 24),

                if (urls.length > 1) ...[
                  const Text(
                    'Foto Lainnya',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: urls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final url = urls[i].toString();
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 86,
                            height: 86,
                            color: Colors.grey.shade200,
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
