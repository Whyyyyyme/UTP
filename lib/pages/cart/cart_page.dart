import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';

import 'package:prelovedly/view_model/cart_controller.dart';
import 'package:prelovedly/view_model/session_controller.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isEdit = false;

  late final CartController cartC;
  late final SessionController session;

  @override
  void initState() {
    super.initState();
    cartC = Get.find<CartController>(); // ✅ dari binding
    session = SessionController.to; // ✅ source of truth viewerId
  }

  String rp(dynamic value) {
    final v = value is int ? value : int.tryParse('$value') ?? 0;
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return "Rp $buf";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final viewerId = session.viewerId.value;

      if (viewerId.isEmpty) {
        return const Scaffold(body: Center(child: Text('Kamu belum login')));
      }

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: const Text("Keranjang", style: TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Get.back();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => setState(() => isEdit = !isEdit),
              child: Text(
                isEdit ? "Done" : "Edit",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: cartC.cartItemsStream(viewerId),
          builder: (context, snap) {
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error cart: ${snap.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  'Keranjang kosong',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }

            final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
            grouped = {};
            for (final d in docs) {
              final suid = (d.data()['seller_uid'] ?? '').toString();
              grouped.putIfAbsent(suid, () => []);
              grouped[suid]!.add(d);
            }

            final sellerIds = grouped.keys.toList()..sort();

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              itemCount: sellerIds.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final sellerId = sellerIds[index];
                final items = grouped[sellerId] ?? [];

                final total = items.fold<int>(0, (sum, d) {
                  final p = d.data()['price'];
                  final price = p is int ? p : int.tryParse('$p') ?? 0;
                  return sum + price;
                });

                return _SellerCartSectionDynamic(
                  sellerId: sellerId,
                  cartC: cartC,
                  isEdit: isEdit,
                  items: items,
                  total: total,
                  rp: rp,

                  onRemoveOne: (productId) async {
                    final res = await cartC.removeFromCart(
                      viewerId: viewerId,
                      productId: productId,
                    );
                    if (!res.$1) {
                      Get.snackbar('Error', res.$2);
                    }
                  },

                  onDeleteAllInSeller: () async {
                    final res = await cartC.deleteAllBySeller(
                      viewerId: viewerId,
                      sellerId: sellerId,
                    );
                    Get.snackbar(res.$1 ? 'Sukses' : 'Error', res.$2);
                  },

                  onBuyNow: () async {
                    final res = await cartC.selectOnlySeller(
                      viewerId: viewerId,
                      sellerUid: sellerId,
                    );
                    if (!res.$1) {
                      Get.snackbar('Error', res.$2);
                      return;
                    }
                    Get.toNamed(Routes.checkout);
                  },

                  onAddMore: () {
                    Get.snackbar('Info', 'Tambah item (TODO)');
                  },
                );
              },
            );
          },
        ),
      );
    });
  }
}

class _SellerCartSectionDynamic extends StatelessWidget {
  final String sellerId;
  final CartController cartC; // ✅ tambahan
  final bool isEdit;

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> items;
  final int total;
  final String Function(dynamic) rp;

  final VoidCallback onBuyNow;
  final VoidCallback onAddMore;

  final Future<void> Function() onDeleteAllInSeller;
  final Future<void> Function(String productId) onRemoveOne;

  const _SellerCartSectionDynamic({
    required this.sellerId,
    required this.cartC,
    required this.isEdit,
    required this.items,
    required this.total,
    required this.rp,
    required this.onBuyNow,
    required this.onAddMore,
    required this.onDeleteAllInSeller,
    required this.onRemoveOne,
  });

  // ✅ cache future per sellerId agar FutureBuilder tidak fetch terus
  static final Map<String, Future<Map<String, String>>> _sellerFutureCache = {};

  Future<Map<String, String>> _getSellerMeta(String sellerId) {
    return _sellerFutureCache.putIfAbsent(sellerId, () async {
      // asumsikan seller ada di collection 'users'
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .get();

      final data = doc.data() ?? {};

      final name =
          (data['name'] ?? data['username'] ?? data['displayName'] ?? 'Seller')
              .toString();

      final photoUrl =
          (data['photoUrl'] ?? data['profileUrl'] ?? data['avatarUrl'] ?? '')
              .toString();

      return {'name': name.isEmpty ? 'Seller' : name, 'photoUrl': photoUrl};
    });
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final showItems = items.take(2).toList();

    Widget buildTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final d = doc.data();
      final productId = doc.id;

      final title = (d['size'] ?? d['title'] ?? '').toString();

      final thumb = (d['thumbnail_url'] ?? '').toString();
      final urls = (d['image_urls'] is List)
          ? (d['image_urls'] as List).map((e) => '$e').toList()
          : <String>[];
      final img = thumb.isNotEmpty
          ? thumb
          : (urls.isNotEmpty ? urls.first : '');

      final priceFinal = d['price'] ?? 0;
      final priceOriginal = d['price_original'] ?? priceFinal;
      final offerStatus = (d['offer_status'] ?? '').toString();

      return _CartItemTileDynamic(
        title: title.isEmpty ? 'Item' : title,
        priceFinal: priceFinal,
        priceOriginal: priceOriginal,
        offerStatus: offerStatus,
        imgUrl: img,
        rp: rp,
        showRemove: isEdit,
        onRemove: isEdit
            ? () async {
                await onRemoveOne(productId);
              }
            : null,
      );
    }

    Widget addBox() {
      return InkWell(
        onTap: onAddMore,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: const Center(child: Icon(Icons.add, size: 32)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ HEADER SELLER (foto + nama + total)
        FutureBuilder<Map<String, String>>(
          future: _getSellerMeta(sellerId),
          builder: (context, snap) {
            final meta = snap.data ?? {'name': sellerId, 'photoUrl': ''};
            final sellerName = meta['name'] ?? sellerId;
            final photoUrl = meta['photoUrl'] ?? '';

            return Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: photoUrl.isEmpty
                      ? null
                      : NetworkImage(photoUrl),
                  child: photoUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.black54,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sellerName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rp(total),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      "+ ongkir",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 12),

        if (!isEdit) ...[
          SizedBox(
            height: 150,
            child: GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                buildTile(showItems[0]),
                if (items.length >= 2) buildTile(showItems[1]) else addBox(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onBuyNow,
              child: const Text("Beli sekarang"),
            ),
          ),
        ] else ...[
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [for (final d in items) buildTile(d)],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () async {
                await onDeleteAllInSeller();
              },
              child: Text("Hapus ${items.length} item"),
            ),
          ),
        ],
      ],
    );
  }
}

class _CartItemTileDynamic extends StatelessWidget {
  final String title;
  final int priceFinal;
  final int priceOriginal;
  final String offerStatus;
  final String imgUrl;
  final String Function(dynamic) rp;
  final bool showRemove;
  final Future<void> Function()? onRemove;

  const _CartItemTileDynamic({
    required this.title,
    required this.priceFinal,
    required this.priceOriginal,
    required this.offerStatus,

    required this.imgUrl,
    required this.rp,
    required this.showRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: Colors.grey.shade200,
              height: 150,
              width: double.infinity,
              child: imgUrl.isEmpty
                  ? const Center(child: Icon(Icons.image))
                  : Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ harga final (nego / normal)
                Text(
                  rp(priceFinal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 12)],
                  ),
                ),

                // ✅ tampilkan harga asli dicoret kalau nego accepted
                if (offerStatus == 'accepted' && priceOriginal > priceFinal)
                  Text(
                    rp(priceOriginal),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      shadows: [Shadow(blurRadius: 8)],
                    ),
                  ),

                if (offerStatus == 'accepted')
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Harga Nego',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (showRemove)
            Positioned(
              right: -6,
              top: -6,
              child: InkWell(
                onTap: onRemove == null
                    ? null
                    : () async {
                        await onRemove!();
                      },
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
