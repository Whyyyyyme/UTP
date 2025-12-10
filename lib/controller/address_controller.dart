import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get to => Get.find<AddressController>();

  final _db = FirebaseFirestore.instance;

  final isSaving = false.obs;
  final selectedRegion = ''.obs;

  /// Koleksi alamat di bawah user:
  /// users/{userId}/addresses
  CollectionReference<Map<String, dynamic>>? _userAddressCollection() {
    final auth = AuthController.to;
    final currentUser = auth.user.value;
    if (currentUser == null) return null;

    return _db.collection('users').doc(currentUser.id).collection('addresses');
  }

  /// Stream daftar alamat user (dipakai di AddressListPage)
  Stream<List<AddressModel>> userAddressesStream() {
    final col = _userAddressCollection();
    if (col == null) {
      return const Stream<List<AddressModel>>.empty();
    }

    return col
        .orderBy('created_at', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => AddressModel.fromDoc(doc)).toList(),
        );
  }

  /// Cek apakah user sudah punya minimal 1 alamat
  Future<bool> hasAnyAddress() async {
    try {
      final col = _userAddressCollection();
      if (col == null) return false;

      final snap = await col.limit(1).get();
      final has = snap.docs.isNotEmpty;
      print('hasAnyAddress => $has');
      return has;
    } catch (e) {
      print('hasAnyAddress ERROR: $e');
      return false;
    }
  }

  /// Simpan alamat baru ke users/{uid}/addresses
  Future<bool> saveNewAddress({
    required String receiverName,
    required String phone,
  }) async {
    final auth = AuthController.to;
    final currentUser = auth.user.value;

    if (currentUser == null) {
      Get.snackbar('Error', 'Kamu belum login');
      return false;
    }

    if (receiverName.trim().isEmpty) {
      Get.snackbar('Error', 'Nama penerima wajib diisi');
      return false;
    }
    if (phone.trim().isEmpty) {
      Get.snackbar('Error', 'Nomor telepon wajib diisi');
      return false;
    }
    if (selectedRegion.value.trim().isEmpty) {
      Get.snackbar('Error', 'Detail wilayah belum dipilih');
      return false;
    }

    try {
      isSaving.value = true;

      final col = _userAddressCollection();
      if (col == null) {
        Get.snackbar('Error', 'User tidak ditemukan');
        return false;
      }

      final docRef = col.doc();

      final model = AddressModel(
        id: docRef.id,
        userId: currentUser.id,
        receiverName: receiverName.trim(),
        phone: phone.trim(),
        regionDetail: selectedRegion.value.trim(),
        createdAt: Timestamp.now(),
        isDefault: false,
      );

      print('saveNewAddress => will write to ${docRef.path}');
      print('data: ${model.toMap()}');

      await docRef.set(model.toMap());

      print('saveNewAddress => success');
      return true;
    } catch (e) {
      print('saveNewAddress ERROR: $e');
      Get.snackbar('Error', 'Gagal menyimpan alamat: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Hapus alamat (dipanggil dari Dismissible di AddressListPage)
  Future<void> deleteAddress(AddressModel address) async {
    try {
      final col = _userAddressCollection();
      if (col == null) {
        Get.snackbar('Error', 'User tidak ditemukan');
        return;
      }

      await col.doc(address.id).delete();
      Get.snackbar(
        'Berhasil',
        'Alamat dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('deleteAddress ERROR: $e');
      Get.snackbar(
        'Error',
        'Gagal menghapus alamat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
