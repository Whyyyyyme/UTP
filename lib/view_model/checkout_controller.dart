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
    'eta': '',
    'method_id': '',
    'method_key': '',
  }.obs;

  final selectedPayment = Rxn<PaymentMethodModel>();

  final shippingBySeller = <String, Map<String, dynamic>>{}.obs;

  Map<String, dynamic> shippingFor(String sellerId) {
    return shippingBySeller[sellerId] ?? {'method': '', 'fee': 0, 'eta': ''};
  }

  void setShippingForSeller({
    required String sellerId,
    required String method,
    required int fee,
    required String eta,
  }) {
    shippingBySeller[sellerId] = {'method': method, 'fee': fee, 'eta': eta};
    shippingBySeller.refresh();
  }

  // payment methods list
  final paymentMethods = const <PaymentMethodModel>[
    PaymentMethodModel(
      id: 'cod',
      title: 'COD (Bayar di tempat)',
      subtitle: 'Bayar saat barang sampai',
      iconKey: 'cod',
    ),
    PaymentMethodModel(
      id: 'bank_transfer',
      title: 'Transfer Bank',
      subtitle: 'Virtual account / manual transfer',
      iconKey: 'bank',
    ),
    PaymentMethodModel(
      id: 'ewallet',
      title: 'E-Wallet',
      subtitle: 'OVO / DANA / GoPay (dummy)',
      iconKey: 'wallet',
    ),
  ];

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

      final cart = await _repo.getCartItems(buyerId);
      items.assignAll(cart);

      final addr = await _repo.getDefaultAddress(buyerId);
      address.assignAll(addr);

      if ((shipping['method'] ?? '').toString().isEmpty) {
        shipping.assignAll({
          'method': '',
          'fee': 0,
          'eta': '',
          'method_id': '',
          'method_key': '',
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
  }) {
    shipping.assignAll({
      'method': method,
      'fee': fee,
      'eta': eta,
      'method_id': methodId,
      'method_key': methodKey,
    });
  }

  void setPayment(PaymentMethodModel m) {
    selectedPayment.value = m;
  }

  Future<void> payNow(String buyerId) async {
    if (!canPay) {
      error.value = 'Lengkapi alamat, pengiriman, dan pembayaran.';
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
          'status': selectedPayment.value!.id == 'cod'
              ? 'cod'
              : 'waiting_payment',
        },
      );

      Get.snackbar('Sukses', 'Order berhasil dibuat');
      Get.back(); // keluar dari checkout (atau arahkan ke order detail page)
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Gagal', error.value ?? 'unknown error');
    } finally {
      isLoading.value = false;
    }
  }
}
