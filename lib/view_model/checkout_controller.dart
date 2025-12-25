import 'package:get/get.dart';
import '../data/repository/checkout_repository.dart';
import '../models/checkout_item_model.dart';
import '../models/payment_method_model.dart';

class CheckoutController extends GetxController {
  CheckoutController(this._repo);

  final CheckoutRepository _repo;

  // state
  final isLoading = false.obs;
  final error = RxnString();

  final items = <CheckoutItemModel>[].obs;

  final address = <String, dynamic>{}.obs;
  final shipping = <String, dynamic>{
    'method': '',
    'fee': 0,
    'fee_original': 0,
    'promo_discount': 0,
    'eta': '',
    'method_id': '',
    'method_key': '',
    'seller_id': '',
  }.obs;

  final selectedPayment = Rxn<PaymentMethodModel>();

  final shippingBySeller = <String, Map<String, dynamic>>{}.obs;
  final paymentDeadline = Rxn<DateTime>();

  Map<String, dynamic> shippingFor(String sellerId) {
    return shippingBySeller[sellerId] ??
        {
          'method': '',
          'fee': 0,
          'fee_original': 0,
          'promo_discount': 0,
          'eta': '',
          'method_id': '',
          'method_key': '',
          'seller_id': sellerId,
        };
  }

  void setShippingForSeller({
    required String sellerId,
    required String method,
    required int fee,
    required String eta,
    String methodId = '',
    String methodKey = '',
  }) {
    final promo = promoShippingDiscount(sellerId);
    final discount = promo > fee ? fee : promo;
    final finalFee = fee - discount;

    shippingBySeller[sellerId] = {
      'method': method,
      'fee': finalFee,
      'fee_original': fee,
      'promo_discount': discount,
      'eta': eta,
      'method_id': methodId,
      'method_key': methodKey,
      'seller_id': sellerId,
    };
    shippingBySeller.refresh();

    // ✅ supaya Checkout UI (yang masih single seller) ikut berubah
    final currentSeller = (shipping['seller_id'] ?? '').toString();
    if (currentSeller.isEmpty || currentSeller == sellerId) {
      shipping.assignAll(shippingBySeller[sellerId]!);
    }
  }

  int get subtotal => items.fold<int>(0, (s, it) => s + it.priceFinal);
  int get shippingFee => (shipping['fee'] is int)
      ? shipping['fee'] as int
      : int.tryParse('${shipping['fee']}') ?? 0;

  int get total => subtotal + shippingFee;

  bool get canPay =>
      items.isNotEmpty &&
      (address.isNotEmpty) &&
      (shipping['method'] ?? '').toString().isNotEmpty &&
      selectedPayment.value != null;

  Future<void> load(String buyerId) async {
    if (buyerId.isEmpty) return;

    try {
      isLoading.value = true;
      error.value = null;
      await _repo.backfillPromoToCart(buyerId);

      final cart = await _repo.getCartItems(buyerId);
      items.assignAll(cart);

      final addr = await _repo.getDefaultAddress(buyerId);
      address.assignAll(addr);

      if ((shipping['method'] ?? '').toString().isEmpty) {
        shipping.assignAll({
          'method': '',
          'fee': 0,
          'fee_original': 0,
          'promo_discount': 0,
          'eta': '',
          'method_id': '',
          'method_key': '',
          'seller_id': '',
        });
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setShipping({
    required String method,
    required int fee,
    required String eta,
    String methodId = '',
    String methodKey = '',
    String sellerId = '',
  }) {
    final promo = promoShippingDiscount(sellerId);
    final discount = promo > fee ? fee : promo;
    final finalFee = fee - discount;

    shipping.assignAll({
      'method': method,
      'fee': finalFee,
      'fee_original': fee,
      'promo_discount': discount,
      'eta': eta,
      'method_id': methodId,
      'method_key': methodKey,
      'seller_id': sellerId,
    });

    shipping.refresh();
  }

  void setPayment(PaymentMethodModel m) {
    selectedPayment.value = m;
  }

  // /mnt/data/checkout_controller.dart

  Future<void> payNow(String buyerId, {bool popAfter = true}) async {
    if (!canPay) {
      error.value = 'Lengkapi alamat, pengiriman, dan pembayaran.';
      return;
    }

    // optional: cek deadline
    final dl = paymentDeadline.value;
    if (dl != null && DateTime.now().isAfter(dl)) {
      error.value = 'Waktu pembayaran habis. Silakan checkout ulang.';
      return;
    }

    try {
      isLoading.value = true;
      error.value = null;

      await _repo.createOrder(
        buyerId: buyerId,
        items: items,
        address: address,
        shipping: shipping,
        payment: {
          'method_id': selectedPayment.value!.id,
          'method_title': selectedPayment.value!.title,
          'status': selectedPayment.value!.id == 'pay'
              ? 'pay'
              : 'waiting_payment',
        },
      );

      Get.snackbar('Sukses', 'Order berhasil dibuat');

      if (popAfter) {
        Get.back();
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Gagal', error.value ?? 'unknown error');
    } finally {
      isLoading.value = false;
    }
  }

  int promoShippingDiscount(String sellerId) {
    int maxPromo = 0;
    for (final it in items) {
      // kalau sellerId dikirim, promo hanya dari item seller tsb
      if (sellerId.trim().isNotEmpty && it.sellerId != sellerId) continue;

      if (!it.promoShippingActive) continue;
      if (it.promoShippingAmount > maxPromo) maxPromo = it.promoShippingAmount;
    }
    return maxPromo;
  }

  void startPaymentDeadline() {
    paymentDeadline.value = DateTime.now().add(const Duration(hours: 1));
  }
}
