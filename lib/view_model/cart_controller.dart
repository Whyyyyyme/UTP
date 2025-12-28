import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/repository/cart_repository.dart';

class CartController extends GetxController {
  CartController(this.repo);

  final CartRepository repo;

  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream(
    String viewerId,
  ) => repo.cartItemsStream();

  Stream<bool> isInCartStream({
    required String viewerId,
    required String productId,
  }) => repo.isInCartStream(productId: productId);

  Future<(bool, String)> addToCart({
    required String viewerId,
    required String productId,
  }) async {
    if (viewerId.isEmpty) return (false, 'Kamu belum login');
    if (productId.isEmpty) return (false, 'productId kosong');

    try {
      await repo.addToCart(productId: productId);
      return (true, 'Berhasil ditambahkan ke keranjang');
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> removeFromCart({
    required String viewerId,
    required String productId,
  }) async {
    if (viewerId.isEmpty) return (false, 'Kamu belum login');
    if (productId.isEmpty) return (false, 'productId kosong');

    try {
      await repo.removeFromCart(productId: productId);
      return (true, 'Dihapus dari keranjang');
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> toggleCart({
    required String viewerId,
    required String productId,
    required bool currentlyInCart,
  }) async {
    if (viewerId.isEmpty) return (false, 'Kamu belum login');
    if (productId.isEmpty) return (false, 'productId kosong');

    try {
      await repo.toggleCart(
        productId: productId,
        currentlyInCart: currentlyInCart,
      );
      return (
        true,
        currentlyInCart ? 'Dihapus dari keranjang' : 'Ditambahkan ke keranjang',
      );
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> clearCart(String viewerId) async {
    if (viewerId.isEmpty) return (false, 'Kamu belum login');

    try {
      await repo.clearCart();
      return (true, 'Keranjang dikosongkan');
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// ✅ Hapus semua item berdasarkan seller di cart user
  Future<(bool, String)> deleteAllBySeller({
    required String viewerId,
    required String sellerId,
  }) async {
    if (viewerId.isEmpty) return (false, 'Kamu belum login');
    if (sellerId.isEmpty) return (false, 'sellerId kosong');

    try {
      await repo.deleteAllBySeller(sellerId: sellerId);
      return (true, 'Item seller dihapus');
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> setItemSelected({
    required String viewerId,
    required String productId,
    required bool selected,
  }) async {
    if (viewerId.isEmpty) return (false, 'Kamu belum login');
    if (productId.isEmpty) return (false, 'productId kosong');
    try {
      await repo.setItemSelected(productId: productId, selected: selected);
      return (true, 'OK');
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> selectOnlySeller({
    required String viewerId,
    required String sellerUid,
  }) async {
    if (viewerId.isEmpty) return (false, 'Kamu belum login');
    if (sellerUid.trim().isEmpty) return (false, 'sellerUid kosong');
    try {
      await repo.selectOnlySeller(sellerUid: sellerUid);
      return (true, 'OK');
    } catch (e) {
      return (false, e.toString());
    }
  }
}
