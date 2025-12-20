import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/repository/cart_repository.dart';

class CartController extends GetxController {
  CartController(this.repo);

  final CartRepository repo;

  Stream<QuerySnapshot<Map<String, dynamic>>> cartItemsStream(
    String viewerId,
  ) => repo.cartItemsStream(viewerId);

  Stream<bool> isInCartStream({
    required String viewerId,
    required String productId,
  }) => repo.isInCartStream(viewerId: viewerId, productId: productId);

  Future<(bool, String)> addToCart({
    required String viewerId,
    required String productId,
  }) async {
    if (viewerId.isEmpty) return (false, 'Kamu belum login');
    if (productId.isEmpty) return (false, 'productId kosong');

    try {
      await repo.addToCart(viewerId: viewerId, productId: productId);
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
      await repo.removeFromCart(viewerId: viewerId, productId: productId);
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
        viewerId: viewerId,
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
      await repo.clearCart(viewerId);
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
      await repo.deleteAllBySeller(viewerId: viewerId, sellerId: sellerId);
      return (true, 'Item seller dihapus');
    } catch (e) {
      return (false, e.toString());
    }
  }
}
