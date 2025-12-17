import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/cart_controller.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isEdit = false;

  final cartC = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController(), permanent: true);

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
    final viewerId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
          onPressed: () => Navigator.pop(context),
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

          // GROUP BY seller_id
          final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
          grouped = {};

          for (final d in docs) {
            final sid = (d.data()['seller_id'] ?? '').toString();
            grouped.putIfAbsent(sid, () => []);
            grouped[sid]!.add(d);
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
                isEdit: isEdit,
                items: items,
                total: total,
                rp: rp,
                onRemoveOne: (productId) async {
                  await cartC.removeFromCart(
                    viewerId: viewerId,
                    productId: productId,
                  );
                },
                onDeleteAllInSeller: () async {
                  final batch = FirebaseFirestore.instance.batch();
                  for (final d in items) {
                    batch.delete(d.reference);
                  }
                  await batch.commit();
                },
                onBuyNow: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Beli sekarang (TODO)")),
                  );
                },
                onAddMore: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tambah item (TODO)")),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ======================
// SECTION PER SELLER (DINAMIS) - FIX: Grid 2 kolom
// ======================
class _SellerCartSectionDynamic extends StatelessWidget {
  final String sellerId;
  final bool isEdit;

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> items;
  final int total;
  final String Function(dynamic) rp;

  final VoidCallback onBuyNow;
  final VoidCallback onDeleteAllInSeller;
  final void Function(String productId) onRemoveOne;
  final VoidCallback onAddMore;

  const _SellerCartSectionDynamic({
    required this.sellerId,
    required this.isEdit,
    required this.items,
    required this.total,
    required this.rp,
    required this.onBuyNow,
    required this.onDeleteAllInSeller,
    required this.onRemoveOne,
    required this.onAddMore,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // tampilkan max 2 item (sesuai screenshot)
    final showItems = items.take(2).toList();

    Widget buildTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final d = doc.data();
      final productId = doc.id;

      final title = (d['size'] ?? d['title'] ?? '').toString();
      final price = d['price'] ?? 0;

      final thumb = (d['thumbnail_url'] ?? '').toString();
      final urls = (d['image_urls'] is List)
          ? (d['image_urls'] as List).map((e) => '$e').toList()
          : <String>[];
      final img = thumb.isNotEmpty
          ? thumb
          : (urls.isNotEmpty ? urls.first : '');

      return _CartItemTileDynamic(
        title: title.isEmpty ? 'Item' : title,
        price: price,
        imgUrl: img,
        rp: rp,
        showRemove: isEdit,
        onRemove: isEdit ? () => onRemoveOne(productId) : null,
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
            color: Colors.white,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    "Gabung item, bayar\nongkir sekali",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<_SellerInfo>(
          future: _sellerInfoFuture(sellerId),
          builder: (context, snapInfo) {
            final info = snapInfo.data;
            final sellerName = info?.name ?? 'Seller';
            final foto = info?.photoUrl ?? '';

            final statusText =
                "${items.length} ${items.length <= 1 ? 'item' : 'items'}";

            return Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: foto.isNotEmpty ? NetworkImage(foto) : null,
                  child: foto.isEmpty
                      ? Text(
                          sellerName.isNotEmpty
                              ? sellerName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
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
          // ✅ RULE:
          // - 1 item  -> item + addBox
          // - >=2 item -> 2 item, addBox hilang
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
                // item 1 pasti ada
                buildTile(showItems[0]),

                // item 2 kalau ada, kalau tidak ada baru tampil addBox
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Beli sekarang",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
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
              onPressed: onDeleteAllInSeller,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Hapus ${items.length} item",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<_SellerInfo> _sellerInfoFuture(String sellerId) async {
    final db = FirebaseFirestore.instance;

    final q = await db
        .collection('users')
        .where('uid', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return _SellerInfo(name: 'Seller', photoUrl: '');

    final u = q.docs.first.data();
    final name = (u['username'] ?? u['nama'] ?? 'Seller').toString();
    final photo = (u['foto_profil_url'] ?? '').toString();
    return _SellerInfo(name: name, photoUrl: photo);
  }
}

class _SellerInfo {
  final String name;
  final String photoUrl;
  _SellerInfo({required this.name, required this.photoUrl});
}

// ======================
// TILE ITEM
// ======================
class _CartItemTileDynamic extends StatelessWidget {
  final String title;
  final dynamic price;
  final String imgUrl;
  final String Function(dynamic) rp;
  final bool showRemove;
  final VoidCallback? onRemove;

  const _CartItemTileDynamic({
    required this.title,
    required this.price,
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
                Text(
                  rp(price),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(blurRadius: 12)],
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(blurRadius: 12)],
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
                onTap: onRemove,
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
