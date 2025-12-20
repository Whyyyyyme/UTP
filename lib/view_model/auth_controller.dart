import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:prelovedly/models/user_model.dart';
import 'package:prelovedly/data/services/auth_services.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'session_controller.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  AuthController(this._authService, this._firebaseAuth);

  final AuthService _authService;
  final FirebaseAuth _firebaseAuth;

  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();

  void _syncSessionViewer() {
    final uid = _firebaseAuth.currentUser?.uid ?? user.value?.id ?? '';
    SessionController.to.setViewer(uid);
  }

  @override
  void onReady() async {
    super.onReady();

    final currentFirebaseUser = _firebaseAuth.currentUser;
    if (currentFirebaseUser != null) {
      try {
        final profile = await _authService.getUserProfile(
          currentFirebaseUser.uid,
        );
        user.value = profile;
      } catch (_) {}
    } else {
      user.value = null;
    }

    // ✅ sinkron session viewerId (home akan ikut via worker)
    _syncSessionViewer();
  }

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
        _syncSessionViewer();
        Get.offAllNamed(Routes.home);
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
        _syncSessionViewer();
        Get.offAllNamed(Routes.home);
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
    try {
      isLoading.value = true;
      await _authService.signOut();

      user.value = null;
      errorMessage.value = null;

      // ✅ reset session viewerId (home akan stop listener via worker)
      SessionController.to.clear();

      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout, coba lagi!');
    } finally {
      isLoading.value = false;
    }
  }

  UserModel? getCurrentUser() => user.value;

  Future<void> updateProfile({
    String? username,
    String? nama,
    String? bio,
    String? alamat,
    String? noTelp,
  }) async {
    final current = user.value;
    if (current == null) return;

    final Map<String, dynamic> data = {};
    if (username != null) data['username'] = username;
    if (nama != null) data['nama'] = nama;
    if (bio != null) data['bio'] = bio;
    if (alamat != null) data['alamat'] = alamat;
    if (noTelp != null) data['no_telp'] = noTelp;

    if (data.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final uid = _firebaseAuth.currentUser?.uid ?? current.id;
      await _authService.updateUserProfile(uid, data);

      final updated = await _authService.getUserProfile(uid);
      user.value = updated;

      _syncSessionViewer();
    } catch (e) {
      errorMessage.value = 'Gagal mengubah profil';
      Get.snackbar('Error', errorMessage.value!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfilePhoto(XFile picked) async {
    final current = user.value;
    if (current == null) {
      errorMessage.value = 'User tidak ditemukan di controller';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final uid = _firebaseAuth.currentUser?.uid ?? current.id;

      final url = await _authService.uploadProfilePhoto(uid, picked);
      await _authService.updateUserProfile(uid, {'foto_profil_url': url});

      final updated = await _authService.getUserProfile(uid);
      user.value = updated;

      _syncSessionViewer();
      return true;
    } catch (e) {
      errorMessage.value = 'Gagal mengubah foto profil: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<bool> pickAndUpdateProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return false;

      return await updateProfilePhoto(picked);
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
