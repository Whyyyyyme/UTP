import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:prelovedly/data/services/auth_services.dart';
import 'package:prelovedly/controller/auth_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class LoginController extends GetxController {
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

      final User? firebaseUser = await _authService.signIn(
        trimmedEmail,
        trimmedPassword,
      );

      if (firebaseUser != null) {
        final profile = await _authService.getUserProfile(firebaseUser.uid);

        _authController.user.value = profile;

        Get.offAllNamed(Routes.home);
      } else {
        errorMessage.value = 'Login gagal! Periksa email/password.';
      }
    } on FirebaseAuthException catch (e) {
      print('FIREBASE LOGIN ERROR CODE => ${e.code}');

      switch (e.code) {
        case 'user-not-found':
          errorMessage.value = 'Email belum terdaftar';
          break;
        case 'wrong-password':
          errorMessage.value = 'Password salah';
          break;
        case 'invalid-email':
          errorMessage.value = 'Format email tidak valid';
          break;
        case 'invalid-credential':
          errorMessage.value = 'Email atau password tidak cocok';
          break;
        case 'user-disabled':
          errorMessage.value = 'Akun ini telah dinonaktifkan';
          break;
        default:
          errorMessage.value = 'Terjadi kesalahan saat login (${e.code})';
          break;
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
