import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prelovedly/controller/like_controller.dart';
import 'package:prelovedly/controller/cart_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _db = FirebaseFirestore.instance;

  final pageIndex = 0.obs;

  String _rp(dynamic value) {
    final v = value is int ? value : int.tryParse('$value') ?? 0;
    final f = NumberFormat.decimalPattern('id_ID').format(v);
    return 'Rp $f';
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '-';
    final dt = ts.toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }

  late final LikeController likeC;

  @override
  void initState() {
    super.initState();
    likeC = Get.isRegistered<LikeController>()
        ? Get.find<LikeController>()
        : Get.put(LikeController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments is Map) ? (Get.arguments as Map) : {};
    final String productId = (args['id'] ?? '').toString();
    final String sellerIdArg = (args['seller_id'] ?? '').toString();
    final String viewerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isMe = (args['is_me'] == true);

    if (productId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Product id kosong')));
    }

    final productStream = _db.collection('products').doc(productId).snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: productStream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                'Gagal memuat produk: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final doc = snap.data!;
        if (!doc.exists) {
          return const Scaffold(
            body: Center(child: Text('Produk tidak ditemukan')),
          );
        }

        final data = doc.data() ?? {};
        final String sellerId = (data['seller_id'] ?? sellerIdArg).toString();

        final List<String> images = ((data['image_urls'] as List?) ?? [])
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();

        final String title = (data['title'] ?? '').toString();
        final String desc = (data['description'] ?? '').toString();
        final String brand = (data['brand'] ?? '').toString();
        final String size = (data['size'] ?? '').toString();
        final String condition = (data['condition'] ?? '').toString();
        final String color = (data['color'] ?? '').toString();
        final String material = (data['material'] ?? '').toString();
        final String style = (data['style'] ?? '').toString();
        final String categoryName = (data['category_name'] ?? '').toString();
        final Timestamp? updatedAt = data['updated_at'] is Timestamp
            ? data['updated_at']
            : null;

        final int price = (data['price'] is int)
            ? data['price'] as int
            : int.tryParse('${data['price']}') ?? 0;

        final bool canBuy =
            !isMe; // kalau bukan punya sendiri -> tampil “Nego/Beli”
        final bool canManage =
            isMe; // kalau punya sendiri -> tampil “Edit/Manage”

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _TopMedia(
                        images: images,
                        pageIndex: pageIndex,
                        onBack: () => Get.back(),
                        onCart: () {
                          // TODO: ke cart
                        },
                        productId: productId,
                        sellerId: sellerId,
                        viewerId: viewerId,
                        likeC: likeC,
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== Seller header row (avatar + name + rating + message icon) =====
                            _SellerHeader(
                              sellerId: sellerId,
                              isMe: isMe,
                              onMessage: () {
                                // TODO: chat
                              },
                              onSeeProfile: () {
                                // TODO: buka shop profile seller
                                // Get.toNamed(Routes.shopProfile, arguments: {"userId": sellerId});
                              },
                            ),

                            const SizedBox(height: 14),

                            Text(
                              title.isNotEmpty
                                  ? title
                                  : (brand.isNotEmpty ? brand : 'Produk'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              [
                                    if (size.isNotEmpty) size,
                                    if (condition.isNotEmpty) condition,
                                  ].join(' • ').isEmpty
                                  ? '-'
                                  : [
                                      if (size.isNotEmpty) size,
                                      if (condition.isNotEmpty) condition,
                                    ].join(' • '),
                              style: TextStyle(color: Colors.grey.shade700),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              _rp(price),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Gratis ongkir hingga 5rb',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 12),

                            // ===== Detail section =====
                            const Text(
                              'Detail',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),

                            if (desc.isNotEmpty)
                              Text(desc, style: const TextStyle(height: 1.35))
                            else
                              Text(
                                'Tidak ada deskripsi',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),

                            const SizedBox(height: 14),

                            _KVRow(
                              label: 'Kategori',
                              value: categoryName.isEmpty ? '-' : categoryName,
                            ),
                            _KVRow(
                              label: 'Kondisi',
                              value: condition.isEmpty ? '-' : condition,
                            ),
                            _KVRow(
                              label: 'Warna',
                              value: color.isEmpty ? '-' : color,
                            ),
                            _KVRow(
                              label: 'Bahan',
                              value: material.isEmpty ? '-' : material,
                            ),
                            _KVRow(
                              label: 'Styles',
                              value: style.isEmpty ? '-' : style,
                            ),
                            _KVRow(
                              label: 'Uploaded',
                              value: _timeAgo(updatedAt),
                            ),

                            const SizedBox(height: 18),
                            const Divider(height: 1),
                            const SizedBox(height: 16),

                            // ===== Lainnya dari seller =====
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Lainnya dari seller',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // TODO: ke shop seller
                                  },
                                  child: const Text('>'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            _OtherFromSeller(
                              sellerId: sellerId,
                              excludeProductId: productId,
                              onTap: (id) {
                                Get.toNamed(
                                  '/product-detail',
                                  arguments: {
                                    'id': id,
                                    'seller_id': sellerId,
                                    'viewer_id': viewerId,
                                    'is_me':
                                        isMe, // kalau owner, tetap owner mode
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 18),

                            // ===== Kamu mungkin suka =====
                            const Text(
                              'Kamu mungkin suka',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _YouMayLike(
                              excludeProductId: productId,
                              onTap: (id, sid) {
                                Get.toNamed(
                                  '/product-detail',
                                  arguments: {
                                    'id': id,
                                    'seller_id': sid,
                                    'viewer_id': viewerId,
                                    'is_me':
                                        false, // rekomendasi biasanya bukan punya sendiri
                                  },
                                );
                              },
                            ),

                            const SizedBox(
                              height: 110,
                            ), // ruang buat bottom bar
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ===== Bottom bar =====
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomBar(
                    canBuy: canBuy,
                    canManage: canManage,
                    onNego: () {
                      Get.snackbar('Nego', 'Fitur nego belum dihubungkan');
                    },
                    onBuy: () async {
                      final viewerId =
                          FirebaseAuth.instance.currentUser?.uid ?? '';

                      if (viewerId.isEmpty) {
                        Get.snackbar(
                          'Login dulu',
                          'Sesi kamu habis, silakan login ulang',
                        );
                        return;
                      }

                      // ✅ cegah beli barang sendiri (seller_id harus uid auth)
                      if (sellerId == viewerId) {
                        Get.snackbar(
                          'Info',
                          'Tidak bisa membeli produk sendiri',
                        );
                        return;
                      }

                      final cartC = Get.isRegistered<CartController>()
                          ? Get.find<CartController>()
                          : Get.put(CartController(), permanent: true);

                      try {
                        await cartC.addToCart(
                          viewerId: viewerId,
                          productId: productId,
                        );

                        Get.toNamed(Routes.cart);
                      } catch (e) {
                        Get.snackbar('Gagal', e.toString());
                      }
                    },

                    onEdit: () {
                      // TODO: route edit
                      Get.snackbar('Edit', 'Arahkan ke edit produk');
                    },
                    onManage: () {
                      // ✅ kalau punya sendiri: ke manage product
                      Get.toNamed(
                        '/manage-product',
                        arguments: {'id': productId, 'seller_id': sellerId},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ===================== TOP MEDIA =====================
class _TopMedia extends StatelessWidget {
  final List<String> images;
  final RxInt pageIndex;
  final VoidCallback onBack;
  final VoidCallback onCart;

  final String viewerId;
  final String productId;
  final String sellerId;
  final LikeController likeC;

  const _TopMedia({
    required this.images,
    required this.pageIndex,
    required this.onBack,
    required this.onCart,
    required this.viewerId,
    required this.productId,
    required this.sellerId,
    required this.likeC,
  });

  @override
  Widget build(BuildContext context) {
    final list = images.isNotEmpty ? images : [''];

    return SizedBox(
      height: 420,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: list.length,
            onPageChanged: (i) => pageIndex.value = i,
            itemBuilder: (_, i) {
              final url = list[i];
              return Container(
                color: Colors.grey.shade200,
                child: url.isEmpty
                    ? const Center(child: Icon(Icons.image, size: 60))
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 60),
                        ),
                      ),
              );
            },
          ),

          Positioned(
            left: 10,
            top: 10,
            child: _CircleBtn(icon: Icons.arrow_back, onTap: onBack),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: _CircleBtn(
              icon: Icons.shopping_bag_outlined,
              onTap: onCart,
              badge: 0, // TODO: sambungkan cart count
            ),
          ),

          // ✅ LIKE BUTTON (sesuai LikeController kamu)
          Positioned(
            right: 12,
            bottom: 25,
            child: StreamBuilder<bool>(
              stream: (viewerId.isEmpty)
                  ? Stream.value(false)
                  : likeC.isLikedStream(
                      viewerId: viewerId,
                      productId: productId,
                    ),
              builder: (context, snap) {
                final liked = snap.data == true;

                return _CircleBtn(
                  icon: liked ? Icons.favorite : Icons.favorite_border,
                  onTap: () async {
                    if (viewerId.isEmpty) {
                      Get.snackbar('Login dulu', 'Kamu harus login untuk like');
                      return;
                    }
                    try {
                      await likeC.toggleLike(
                        viewerId: viewerId,
                        productId: productId,
                        sellerId: sellerId,
                        currentlyLiked: liked,
                      );
                    } catch (e) {
                      Get.snackbar('Gagal', e.toString());
                    }
                  },
                );
              },
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Obx(() {
              final idx = pageIndex.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(list.length, (i) {
                  final active = i == idx;
                  return Container(
                    width: active ? 10 : 6,
                    height: active ? 10 : 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  const _CircleBtn({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 22),
            ),
          ),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// ===================== SELLER HEADER =====================
class _SellerHeader extends StatelessWidget {
  final String sellerId;
  final bool isMe;
  final VoidCallback onMessage;
  final VoidCallback onSeeProfile;

  const _SellerHeader({
    required this.sellerId,
    required this.isMe,
    required this.onMessage,
    required this.onSeeProfile,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: db
          .collection('users')
          .where('uid', isEqualTo: sellerId)
          .limit(1)
          .get(),
      builder: (context, snap) {
        final user = (snap.data?.docs.isNotEmpty ?? false)
            ? snap.data!.docs.first.data()
            : {};
        final username = (user['username'] ?? 'seller').toString();
        final foto = (user['foto_profil_url'] ?? '').toString();

        // rating dummy (kalau belum ada field rating)
        final double rating = (user['rating'] is num)
            ? (user['rating'] as num).toDouble()
            : 5.0;
        final int ratingCount = (user['rating_count'] is num)
            ? (user['rating_count'] as num).toInt()
            : 41;

        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: foto.isNotEmpty ? NetworkImage(foto) : null,
              child: foto.isEmpty
                  ? Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'S',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    )
                  : null,
            ),
            const SizedBox(width: 10),

            Expanded(
              child: InkWell(
                onTap: onSeeProfile,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${rating.toStringAsFixed(1)} ($ratingCount)',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (!isMe)
              IconButton(
                onPressed: onMessage,
                icon: const Icon(Icons.mail_outline),
              ),
          ],
        );
      },
    );
  }
}

/// ===================== KEY VALUE ROW =====================
class _KVRow extends StatelessWidget {
  final String label;
  final String value;

  const _KVRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(height: 1, color: Colors.grey.shade200),
        const SizedBox(height: 10),
      ],
    );
  }
}

/// ===================== OTHER FROM SELLER =====================
class _OtherFromSeller extends StatelessWidget {
  final String sellerId;
  final String excludeProductId;
  final void Function(String id) onTap;

  const _OtherFromSeller({
    required this.sellerId,
    required this.excludeProductId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    // ✅ pakai index kamu: status + seller_id + updated_at
    final stream = db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .where('seller_id', isEqualTo: sellerId)
        .orderBy('updated_at', descending: true)
        .limit(10)
        .snapshots();

    return SizedBox(
      height: 130,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          final filtered = docs.where((d) => d.id != excludeProductId).toList();

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Text(
              'Error: ${snap.error}',
              style: const TextStyle(color: Colors.red),
            );
          }
          if (filtered.isEmpty) {
            return Text(
              'Belum ada produk lain',
              style: TextStyle(color: Colors.grey.shade600),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length.clamp(0, 8),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final d = filtered[i].data();
              final id = filtered[i].id;

              final urls = ((d['image_urls'] as List?) ?? [])
                  .map((e) => e.toString())
                  .toList();
              final thumb = (d['thumbnail_url'] ?? '').toString();
              final img = thumb.isNotEmpty
                  ? thumb
                  : (urls.isNotEmpty ? urls.first : '');

              final priceRaw = d['price'];
              final price = priceRaw is int
                  ? priceRaw
                  : int.tryParse('$priceRaw') ?? 0;

              return InkWell(
                onTap: () => onTap(id),
                child: SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 90,
                          width: 110,
                          color: Colors.grey.shade200,
                          child: img.isEmpty
                              ? const Icon(Icons.image)
                              : Image.network(img, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${NumberFormat.decimalPattern('id_ID').format(price)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ===================== YOU MAY LIKE =====================
class _YouMayLike extends StatelessWidget {
  final String excludeProductId;
  final void Function(String id, String sellerId) onTap;

  const _YouMayLike({required this.excludeProductId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    // ✅ pakai index kamu: status + updated_at
    final stream = db
        .collection('products')
        .where('status', isEqualTo: 'published')
        .orderBy('updated_at', descending: true)
        .limit(20)
        .snapshots();

    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];
          final filtered = docs.where((d) => d.id != excludeProductId).toList();

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Text(
              'Error: ${snap.error}',
              style: const TextStyle(color: Colors.red),
            );
          }
          if (filtered.isEmpty) {
            return Text(
              'Belum ada rekomendasi',
              style: TextStyle(color: Colors.grey.shade600),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length.clamp(0, 10),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final d = filtered[i].data();
              final id = filtered[i].id;
              final sid = (d['seller_id'] ?? '').toString();

              final urls = ((d['image_urls'] as List?) ?? [])
                  .map((e) => e.toString())
                  .toList();
              final thumb = (d['thumbnail_url'] ?? '').toString();
              final img = thumb.isNotEmpty
                  ? thumb
                  : (urls.isNotEmpty ? urls.first : '');

              final priceRaw = d['price'];
              final price = priceRaw is int
                  ? priceRaw
                  : int.tryParse('$priceRaw') ?? 0;

              return InkWell(
                onTap: () => onTap(id, sid),
                child: SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 95,
                          width: 120,
                          color: Colors.grey.shade200,
                          child: img.isEmpty
                              ? const Icon(Icons.image)
                              : Image.network(img, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${NumberFormat.decimalPattern('id_ID').format(price)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ===================== BOTTOM BAR =====================
class _BottomBar extends StatelessWidget {
  final bool canBuy;
  final bool canManage;
  final VoidCallback onNego;
  final VoidCallback onBuy;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  const _BottomBar({
    required this.canBuy,
    required this.canManage,
    required this.onNego,
    required this.onBuy,
    required this.onEdit,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 18, color: Colors.black.withOpacity(0.10)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (canBuy) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onNego,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Nego',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Beli',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ] else if (canManage) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onManage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Manage',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
