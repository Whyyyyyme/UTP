import 'package:get/get.dart';
import 'package:prelovedly/view_model/auth_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final obscurePassword = true.obs;

  late final AuthController _authC;

  @override
  void onInit() {
    super.onInit();
    _authC = AuthController.to; // ✅ sudah dari binding (_ensureGlobals)
  }

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

      // ✅ single source of truth: AuthController
      await _authC.signIn(trimmedEmail, trimmedPassword);

      // kalau AuthController set error, ambil dan tampilkan di page
      final err = _authC.errorMessage.value;
      if (err != null && err.isNotEmpty) {
        errorMessage.value = err;
        return;
      }

      // sukses -> AuthController sudah set user + sync home viewer
      Get.offAllNamed(Routes.home);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void togglePassword() {
    obscurePassword.value = !obscurePassword.value;
  }
}
