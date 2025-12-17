import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _itemsRef(String viewerId) =>
      _db.collection('carts').doc(viewerId).collection('items');

  // ✅ stream isi keranjang (buat CartPage)
  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream(String viewerId) {
    return _itemsRef(
      viewerId,
    ).orderBy('created_at', descending: true).snapshots();
  }

  // ✅ cek apakah produk sudah ada di cart
  Stream<bool> isInCartStream({
    required String viewerId,
    required String productId,
  }) {
    return _itemsRef(viewerId).doc(productId).snapshots().map((d) => d.exists);
  }

  // ✅ add to cart (preloved: 1 item = 1 doc, id = productId)
  Future<void> addToCart({
    required String viewerId,
    required String productId,
  }) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');
    if (productId.isEmpty) throw Exception('productId kosong');

    final prodSnap = await _db.collection('products').doc(productId).get();
    if (!prodSnap.exists) throw Exception('Produk tidak ditemukan');

    final productData = prodSnap.data() ?? {};
    final status = (productData['status'] ?? '').toString();

    if (status.isNotEmpty && status != 'published') {
      throw Exception('Produk belum tersedia');
    }

    final sellerId = (productData['seller_id'] ?? '').toString();

    final price = (productData['price'] is int)
        ? productData['price'] as int
        : int.tryParse('${productData['price']}') ?? 0;

    final title = (productData['title'] ?? '').toString();
    final brand = (productData['brand'] ?? '').toString();
    final size = (productData['size'] ?? '').toString();

    final thumb = (productData['thumbnail_url'] ?? '').toString();
    final imageUrls = (productData['image_urls'] is List)
        ? (productData['image_urls'] as List).map((e) => '$e').toList()
        : <String>[];

    await _itemsRef(viewerId).doc(productId).set({
      'product_id': productId,
      'seller_id': sellerId,
      'price': price,
      'title': title,
      'brand': brand,
      'size': size,
      'thumbnail_url': thumb,
      'image_urls': imageUrls,
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ✅ remove 1 item
  Future<void> removeFromCart({
    required String viewerId,
    required String productId,
  }) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');
    if (productId.isEmpty) throw Exception('productId kosong');
    await _itemsRef(viewerId).doc(productId).delete();
  }

  // ✅ toggle (opsional, enak buat tombol)
  Future<void> toggleCart({
    required String viewerId,
    required String productId,
    required bool currentlyInCart,
  }) async {
    if (currentlyInCart) {
      await removeFromCart(viewerId: viewerId, productId: productId);
    } else {
      await addToCart(viewerId: viewerId, productId: productId);
    }
  }

  // ✅ clear cart
  Future<void> clearCart(String viewerId) async {
    if (viewerId.isEmpty) throw Exception('viewerId kosong');

    final snap = await _itemsRef(viewerId).get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
