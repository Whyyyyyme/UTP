import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prelovedly/view_model/like_controller.dart';
import 'package:prelovedly/view_model/product_detail_controller.dart';

import '../../routes/app_routes.dart';
import '../../view_model/home_controller.dart';

class ProductDetailPage extends StatelessWidget {
  ProductDetailPage({super.key});

  final controller = Get.find<ProductDetailController>();

  @override
  Widget build(BuildContext context) {
    if (controller.productId.value.isEmpty) {
      return const Scaffold(body: Center(child: Text('Product id kosong')));
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: controller.productStream(),
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

        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data;
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('Produk tidak ditemukan')),
          );
        }

        final String productId = (data['id'] ?? controller.productId.value)
            .toString();
        final String sellerId =
            (data['seller_id'] ?? controller.sellerIdArg.value).toString();

        final String status = (data['status'] ?? '').toString();
        final bool isSold = status == 'sold';

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

        final dynamic updatedAt =
            data['updated_at']; // bisa Timestamp/DateTime/String

        final int price = (data['price'] is int)
            ? data['price'] as int
            : int.tryParse('${data['price']}') ?? 0;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadChatButtonsState(
            sellerId: sellerId,
            productId: productId,
          );
        });

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
                        pageIndex: controller.pageIndex,
                        onBack: () => Get.back(),
                        onCart: () => Get.toNamed(Routes.cart),
                        productId: productId,
                        sellerId: sellerId,
                        viewerId: controller.viewerId,
                        likeC: controller.likeC,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SellerHeader(
                              sellerId: sellerId,
                              isMe: controller.isMe.value,
                              fetchSeller: controller.getSellerUser,

                              // ✅ jika sold, jangan bisa message dari sini
                              onMessage: isSold
                                  ? () {
                                      Get.snackbar(
                                        'Info',
                                        'Produk ini sudah terjual',
                                      );
                                    }
                                  : () async {
                                      final cover = images.isNotEmpty
                                          ? images.first
                                          : '';

                                      await controller.openChatFromProduct(
                                        sellerId: sellerId,
                                        productId: productId,
                                        productTitle: title,
                                        productImage: cover,
                                      );
                                    },

                              onSeeProfile: () {},
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

                            Obx(() {
                              final t = controller.offerThread.value;
                              final off = t?.offer;

                              int shownPrice = price;

                              if (off != null &&
                                  off.status == 'accepted' &&
                                  off.buyerId == controller.viewerId &&
                                  off.offerPrice > 0) {
                                shownPrice = off.offerPrice;
                              }

                              return Text(
                                controller.rp(shownPrice),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              );
                            }),

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
                              value: controller.timeAgo(updatedAt),
                            ),

                            const SizedBox(height: 18),
                            const Divider(height: 1),
                            const SizedBox(height: 16),

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
                                  onPressed: () {},
                                  child: const Text('>'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            _OtherFromSeller(
                              stream: controller.otherFromSellerStream(
                                sellerId,
                              ),
                              onTap: (id) {
                                Get.toNamed(
                                  '/product-detail',
                                  arguments: {
                                    'id': id,
                                    'seller_id': sellerId,
                                    'is_me': controller.isMe.value,
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Kamu mungkin suka',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _YouMayLike(
                              stream: controller.youMayLikeStream(),
                              onTap: (id, sid) {
                                Get.toNamed(
                                  '/product-detail',
                                  arguments: {
                                    'id': id,
                                    'seller_id': sid,
                                    'is_me': false,
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 110),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Obx(() {
                    if (isSold) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 18,
                              color: Colors.black.withOpacity(0.10),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Produk sudah terjual',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final tOffer =
                        controller.offerThread.value; // offer khusus produk ini
                    final tSeller = controller
                        .sellerChatThread
                        .value; // thread terbaru dengan seller
                    final lockedToMessage =
                        controller.hasAcceptedOfferWithSeller.value;

                    // ===== label + aksi default =====
                    String negoLabel = 'Nego';
                    VoidCallback onLeft = () {
                      final cover = images.isNotEmpty ? images.first : '';

                      Get.toNamed(
                        Routes.nego,
                        arguments: {
                          'productId': productId,
                          'sellerId': sellerId,
                          'title': title,
                          'imageUrl': cover,
                          'price': price,
                        },
                      );
                    };

                    // ✅ PRIORITAS 1: Produk ini sudah ada offer → Cek Offer
                    if (tOffer != null && tOffer.offer != null) {
                      negoLabel = 'Cek Offer';
                      onLeft = () {
                        Get.toNamed(
                          Routes.chat,
                          arguments: {
                            'threadId': tOffer.threadId,
                            'peerId': sellerId,
                            'productId': productId,
                          },
                        );
                      };
                    }
                    // ✅ PRIORITAS 2: Sudah accepted dengan seller → Message (produk lain jadi message)
                    else if (lockedToMessage) {
                      negoLabel = 'Message';
                      onLeft = () async {
                        final cover = images.isNotEmpty ? images.first : '';

                        // kalau sudah ada thread seller, langsung buka
                        if (tSeller != null) {
                          Get.toNamed(
                            Routes.chat,
                            arguments: {
                              'threadId': tSeller.threadId,
                              'peerId': sellerId,
                              'productId': productId,
                            },
                          );
                          return;
                        }

                        // kalau belum ada, bikin thread lalu buka
                        await controller.openChatFromProduct(
                          sellerId: sellerId,
                          productId: productId,
                          productTitle: title,
                          productImage: cover,
                        );
                      };
                    }

                    return _BottomBar(
                      canBuy: controller.canBuy,
                      canManage: controller.canManage,
                      negoLabel: negoLabel,
                      onNego: onLeft,

                      onBuy: () async {
                        await controller.buy(
                          sellerId: sellerId,
                          productId: productId,
                        );
                        Get.toNamed(Routes.cart);
                      },
                      onEdit: () => Get.toNamed(
                        Routes.editProduct,
                        arguments: {'id': productId, 'seller_id': sellerId},
                      ),
                      onManage: () => Get.toNamed(
                        Routes.manageProduct,
                        arguments: {'id': productId, 'seller_id': sellerId},
                      ),
                    );
                  }),
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
            child: Obx(() {
              final homeC = Get.find<HomeController>(); // pastikan sudah ada
              return _CircleBtn(
                icon: Icons.shopping_bag_outlined,
                onTap: onCart,
                badge: homeC.cartCount.value,
              );
            }),
          ),

          // ✅ LIKE BUTTON
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

          // indikator page
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
/// NOTE: Tidak query Firestore di sini.
/// Data seller diambil via `fetchSeller(sellerId)` dari VM/Repo.
class _SellerHeader extends StatelessWidget {
  final String sellerId;
  final bool isMe;
  final VoidCallback onMessage;
  final VoidCallback onSeeProfile;
  final Future<Map<String, dynamic>> Function(String sellerId) fetchSeller;

  const _SellerHeader({
    required this.sellerId,
    required this.isMe,
    required this.onMessage,
    required this.onSeeProfile,
    required this.fetchSeller,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchSeller(sellerId),
      builder: (context, snap) {
        final user = snap.data ?? {};
        final username = (user['username'] ?? 'seller').toString();
        final foto = (user['foto_profil_url'] ?? '').toString();

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
/// NOTE: stream dikirim dari VM -> repo -> service.
/// widget tidak boleh bikin query Firestore sendiri.
class _OtherFromSeller extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> stream;
  final void Function(String id) onTap;

  const _OtherFromSeller({required this.stream, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          final items = snap.data ?? [];

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Text(
              'Error: ${snap.error}',
              style: const TextStyle(color: Colors.red),
            );
          }
          if (items.isEmpty) {
            return Text(
              'Belum ada produk lain',
              style: TextStyle(color: Colors.grey.shade600),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length.clamp(0, 8),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final d = items[i];
              final id = (d['id'] ?? '').toString();

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
/// NOTE: stream dikirim dari VM -> repo -> service.
/// widget tidak query Firestore langsung.
class _YouMayLike extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> stream;
  final void Function(String id, String sellerId) onTap;

  const _YouMayLike({required this.stream, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          final items = snap.data ?? [];

          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Text(
              'Error: ${snap.error}',
              style: const TextStyle(color: Colors.red),
            );
          }
          if (items.isEmpty) {
            return Text(
              'Belum ada rekomendasi',
              style: TextStyle(color: Colors.grey.shade600),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length.clamp(0, 10),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final d = items[i];
              final id = (d['id'] ?? '').toString();
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

  final String negoLabel;
  final VoidCallback onNego;
  final VoidCallback onBuy;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  const _BottomBar({
    required this.canBuy,
    required this.canManage,
    required this.negoLabel,
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
                  child: Text(
                    negoLabel, // ✅ pakai label dinamis
                    style: const TextStyle(fontWeight: FontWeight.w800),
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
