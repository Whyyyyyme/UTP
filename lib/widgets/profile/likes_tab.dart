import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/like_controller.dart';

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
        if (snap.connectionState == ConnectionState.waiting) {
          return _box(child: const SizedBox.shrink());
        }
        if (!snap.hasData || !(snap.data?.exists ?? false)) {
          return const SizedBox.shrink();
        }

        final data = snap.data!.data() ?? {};

        final status = (data['status'] ?? '').toString().toLowerCase().trim();
        final isDraft = (data['is_draft'] == true) || status == 'draft';
        final isSold =
            (data['is_sold'] == true) ||
            status == 'sold' ||
            status == 'terjual';

        // Kalau draft / sold -> sembunyikan
        if (isDraft || isSold) {
          return const SizedBox.shrink();
        }

        final urls = ((data['image_urls'] as List?) ?? [])
            .map((e) => '$e')
            .toList();
        final thumb = (data['thumbnail_url'] ?? '').toString();
        final img = thumb.isNotEmpty
            ? thumb
            : (urls.isNotEmpty ? urls.first : '');

        final sellerId = (data['seller_id'] ?? '').toString();

        return InkWell(
          onTap: () {
            Get.toNamed(
              Routes.productDetail,
              arguments: {
                'id': productId,
                'seller_id': sellerId,
                'is_me': false,
              },
            );
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
