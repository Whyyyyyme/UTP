import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class WithdrawController extends GetxController {
  final selectedBank = RxnString();
  final accountNumber = ''.obs;
  final secretPassword = ''.obs;

  final isSubmitting = false.obs;
  final error = RxnString();

  Future<void> submit({required int amount}) async {
    error.value = null;

    if (amount <= 0) {
      error.value = 'Saldo tidak mencukupi.';
      return;
    }
    if ((selectedBank.value ?? '').isEmpty ||
        accountNumber.value.trim().isEmpty ||
        secretPassword.value.trim().isEmpty) {
      error.value = 'Semua field wajib diisi.';
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null || email.isEmpty) {
      error.value = 'Akun tidak valid / belum login.';
      return;
    }

    try {
      isSubmitting.value = true;

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: secretPassword.value,
        ),
      );

      Get.snackbar(
        'Claim Payout',
        'Password valid. Request payout dibuat (dummy).',
      );
    } on FirebaseAuthException catch (e) {
      error.value = e.code == 'wrong-password'
          ? 'Password salah.'
          : (e.message ?? e.code);
    } finally {
      isSubmitting.value = false;
    }
  }
}
