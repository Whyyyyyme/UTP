import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prelovedly/data/services/auth_services.dart';

import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/auth_controller.dart';

class LegacyLoginController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  var obscurePassword = true.obs;

  final AuthService _authService = AuthService();
  final AuthController _authController = Get.find<AuthController>();

  Future<void> login(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      errorMessage.value = 'Email dan password harus diisi';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Proses Sign In ke Firebase Auth
      final User? firebaseUser = await _authService.signIn(
        trimmedEmail,
        trimmedPassword,
      );

      if (firebaseUser != null) {
        // 2. Ambil data profil dari Firestore berdasarkan UID
        final profile = await _authService.getUserProfile(firebaseUser.uid);

        if (profile != null) {
          // Simpan data ke AuthController untuk digunakan di halaman lain
          _authController.user.value = profile;

          // Menggunakan dynamic agar compiler tidak error saat memanggil .role
          final dynamic userData = profile;

          // Ambil nilai role dari database (sesuai gambar Firestore kamu)
          String userRole = userData.role?.toString() ?? 'pembeli';

          // 3. Logika Pengalihan Halaman
          if (userRole == 'admin') {
            print("Login sebagai Admin berhasil");
            Get.offAllNamed(Routes.adminDashboard);
          } else {
            print("Login sebagai Pembeli berhasil");
            Get.offAllNamed(Routes.home);
          }
        } else {
          errorMessage.value = 'Data profil tidak ditemukan di database';
        }
      } else {
        errorMessage.value = 'Login gagal! Periksa email/password.';
      }
    } on FirebaseAuthException catch (e) {
      // Error handling bawaan Firebase
      if (e.code == 'user-not-found') {
        errorMessage.value = 'Email belum terdaftar';
      } else if (e.code == 'wrong-password') {
        errorMessage.value = 'Password salah';
      } else {
        errorMessage.value = 'Kesalahan: ${e.message}';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
