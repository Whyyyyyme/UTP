import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/address_model.dart';
import 'auth_controller.dart';
import '../data/repository/address_repository.dart';

class AddressController extends GetxController {
  AddressController(this._repo);

  static AddressController get to => Get.find<AddressController>();

  final AddressRepository _repo;

  final isSaving = false.obs;
  final selectedRegion = ''.obs;
  final selectedAddress = Rxn<AddressModel>();

  String? _uid() => AuthController.to.user.value?.id;

  Stream<List<AddressModel>> userAddressesStream() {
    final uid = _uid();
    if (uid == null) return const Stream<List<AddressModel>>.empty();
    return _repo.streamUserAddresses(uid);
  }

  Future<bool> hasAnyAddress() async {
    final uid = _uid();
    if (uid == null) return false;
    return _repo.userHasAnyAddress(uid);
  }

  /// return message biar View yang snackbar (MVVM lebih bersih)
  Future<(bool ok, String message)> saveNewAddress({
    required String receiverName,
    required String phone,
  }) async {
    final uid = _uid();
    if (uid == null) return (false, 'Kamu belum login');

    if (receiverName.trim().isEmpty)
      return (false, 'Nama penerima wajib diisi');
    if (phone.trim().isEmpty) return (false, 'Nomor telepon wajib diisi');
    if (selectedRegion.value.trim().isEmpty)
      return (false, 'Detail wilayah belum dipilih');

    try {
      isSaving.value = true;

      final newId = _repo.newId(uid);

      final model = AddressModel(
        id: newId,
        userId: uid,
        receiverName: receiverName.trim(),
        phone: phone.trim(),
        regionDetail: selectedRegion.value.trim(),
        createdAt: Timestamp.now(),
        isDefault: false,
      );

      await _repo.createAddress(model);
      return (true, 'Alamat berhasil disimpan');
    } catch (_) {
      return (false, 'Gagal menyimpan alamat');
    } finally {
      isSaving.value = false;
    }
  }

  Future<(bool ok, String message)> deleteAddress(AddressModel address) async {
    final uid = _uid();
    if (uid == null) return (false, 'Kamu belum login');

    try {
      await _repo.deleteAddress(uid, address.id);
      return (true, 'Alamat dihapus');
    } catch (_) {
      return (false, 'Gagal menghapus alamat');
    }
  }

  Future<void> pickAddress(AddressModel addr) async {
    selectedAddress.value = addr;
  }

  Future<(bool ok, String message)> setDefault(AddressModel addr) async {
    final uid = _uid();
    if (uid == null) return (false, 'Kamu belum login');

    try {
      await _repo.setDefaultAddress(uid, addr.id);
      return (true, 'Default alamat diperbarui');
    } catch (_) {
      return (false, 'Gagal set default');
    }
  }
}
