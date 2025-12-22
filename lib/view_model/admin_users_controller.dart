import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:prelovedly/data/services/admin_user_service.dart';

class AdminUsersController extends GetxController {
  final AdminUserService _service = AdminUserService();

  // loading per user saat toggle
  final RxnString togglingUid = RxnString();

  // ✅ INI YANG DIPANGGIL DI PAGE
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUsers() {
    return _service.streamUsers();
  }

  Future<void> toggleUserStatus({
    required String uid,
    required bool nextValue,
  }) async {
    try {
      togglingUid.value = uid;
      await _service.setUserActive(uid: uid, isActive: nextValue);
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak bisa mengubah status user: $e');
    } finally {
      togglingUid.value = null;
    }
  }
}
