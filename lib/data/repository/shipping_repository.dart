import '../../models/shipping_method_model.dart';
import '../services/shipping_service.dart';

class ShippingRepository {
  ShippingRepository(this._service);
  final ShippingService _service;

  Stream<List<ShippingMethodModel>> streamAll(String sellerId) {
    return _service.streamAll(sellerId).map((snap) {
      return snap.docs.map((d) => ShippingMethodModel.fromDoc(d)).toList();
    });
  }

  Stream<List<ShippingMethodModel>> streamEnabled(String sellerId) {
    return _service.streamEnabled(sellerId).map((snap) {
      final list = snap.docs
          .map((d) => ShippingMethodModel.fromDoc(d))
          .toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  Future<void> seedDefaultIfEmpty(String sellerId) =>
      _service.seedDefaultIfEmpty(sellerId);

  Future<void> toggleEnabled({
    required String sellerId,
    required String methodId,
    required bool enabled,
  }) => _service.toggleEnabled(
    sellerId: sellerId,
    methodId: methodId,
    enabled: enabled,
  );
}
