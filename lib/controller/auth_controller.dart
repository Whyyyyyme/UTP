import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prelovedly/models/user_model.dart';
import 'package:prelovedly/data/services/auth_services.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();

  Future<void> signUp({
    required String email,
    required String password,
    required String nama,
    required String username,
    String? bio,
    String? alamat,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final firebaseUser = await _authService.signUp(
        email: email,
        password: password,
        nama: nama,
        username: username,
        bio: bio,
        alamat: alamat,
      );

      if (firebaseUser != null) {
        user.value = await _authService.getUserProfile(firebaseUser.uid);
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _firebaseErrorMapper(e.code);
      Get.snackbar('Gagal Membuat Akun', errorMessage.value!);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan, coba lagi!';
      Get.snackbar('Error', errorMessage.value!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final firebaseUser = await _authService.signIn(email, password);

      if (firebaseUser != null) {
        user.value = await _authService.getUserProfile(firebaseUser.uid);
        Get.offAllNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _firebaseErrorMapper(e.code);
      Get.snackbar('Login Gagal', errorMessage.value!);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan, coba lagi!';
      Get.snackbar('Error', errorMessage.value!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    user.value = null;
    Get.offAllNamed('/login');
  }

  UserModel? getCurrentUser() => user.value;

  String _firebaseErrorMapper(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'user-not-found':
        return 'Email tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password tidak cocok';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      default:
        return 'Terjadi kesalahan, coba lagi ($code)';
    }
  }
}
