import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/like_controller.dart';

class LikesTab extends StatelessWidget {
  final String viewerId;
  final LikeController likeC;

  const LikesTab({super.key, required this.viewerId, required this.likeC});

  @override
  Widget build(BuildContext context) {
    if (viewerId.isEmpty) {
      return const Center(child: Text("User tidak ditemukan"));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: likeC.likesStream(viewerId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text("Error: ${snap.error}"));
        }

        final likeDocs = snap.data?.docs ?? [];
        if (likeDocs.isEmpty) {
          return const Center(child: Text("Belum ada likes"));
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // ✅ sama seperti screenshot (2 kolom)
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1, // kotak
          ),
          itemCount: likeDocs.length,
          itemBuilder: (context, i) {
            final likeDoc = likeDocs[i];
            final productId = likeDoc.id; // ✅ docId = productId

            return _LikedProductTile(productId: productId);
          },
        );
      },
    );
  }
}

class _LikedProductTile extends StatelessWidget {
  final String productId;
  const _LikedProductTile({required this.productId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: db.collection('products').doc(productId).snapshots(),
      builder: (context, snap) {
        // kalau produk hilang / dihapus
        if (!snap.hasData || !(snap.data?.exists ?? false)) {
          return _box(child: const Icon(Icons.image, size: 40));
        }

        final data = snap.data!.data() ?? {};
        final urls = ((data['image_urls'] as List?) ?? [])
            .map((e) => '$e')
            .toList();
        final thumb = (data['thumbnail_url'] ?? '').toString();
        final img = thumb.isNotEmpty
            ? thumb
            : (urls.isNotEmpty ? urls.first : '');

        return InkWell(
          onTap: () {
            Get.toNamed('/product-detail', arguments: {'id': productId});
          },
          child: _box(
            child: img.isEmpty
                ? const Icon(Icons.image, size: 40)
                : Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 40),
                  ),
          ),
        );
      },
    );
  }

  Widget _box({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(color: Colors.grey.shade200, child: child),
    );
  }
}
