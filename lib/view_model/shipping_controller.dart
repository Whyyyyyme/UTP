import 'package:get/get.dart';
import '../data/repository/shipping_repository.dart';
import '../models/shipping_method_model.dart';

class ShippingController extends GetxController {
  ShippingController(this._repo, {required this.sellerId});
  final ShippingRepository _repo;
  final String sellerId;

  final isLoading = false.obs;

  final selected = Rxn<ShippingMethodModel>();

  Stream<List<ShippingMethodModel>> streamAll() => _repo.streamAll(sellerId);
  Stream<List<ShippingMethodModel>> streamEnabled() =>
      _repo.streamEnabled(sellerId);

  @override
  void onInit() {
    super.onInit();
    _seed();
  }

  Future<void> _seed() async {
    try {
      isLoading.value = true;
      await _repo.seedDefaultIfEmpty(sellerId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggle({
    required ShippingMethodModel m,
    required bool enabled,
  }) async {
    await _repo.toggleEnabled(
      sellerId: sellerId,
      methodId: m.id,
      enabled: enabled,
    );
  }

  void pick(ShippingMethodModel m) {
    selected.value = m;
  }
}
