import '../../models/address_model.dart';
import '../services/address_service.dart';

class AddressRepository {
  AddressRepository(this._service);

  final AddressService _service;

  Stream<List<AddressModel>> streamUserAddresses(String userId) {
    return _service.streamAddresses(userId).map((snap) {
      return snap.docs.map((d) => AddressModel.fromDoc(d)).toList();
    });
  }

  Future<bool> userHasAnyAddress(String userId) {
    return _service.hasAnyAddress(userId);
  }

  Future<String> createAddress(AddressModel model) async {
    await _service.saveAddress(model.userId, model.id, model.toMap());
    return model.id;
  }

  Future<void> deleteAddress(String userId, String addressId) {
    return _service.deleteAddress(userId, addressId);
  }

  String newId(String userId) => _service.newAddressId(userId);
}
