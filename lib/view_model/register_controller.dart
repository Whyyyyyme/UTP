import 'package:get/get.dart';

class RegisterController extends GetxController {
  // ================= EMAIL =================
  final email = ''.obs;
  final emailError = Rxn<String>();

  bool get isEmailValid =>
      emailError.value == null && email.value.trim().isNotEmpty;

  void validateEmail(String val) {
    email.value = val;
    final trimmed = val.trim();

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (trimmed.isEmpty) {
      emailError.value = 'Email harus diisi';
    } else if (!emailRegex.hasMatch(trimmed)) {
      emailError.value = 'Email tidak valid';
    } else {
      emailError.value = null;
    }
  }

  // ================= NAME =================
  final name = ''.obs;
  final nameError = Rxn<String>();

  bool get isNameValid =>
      nameError.value == null && name.value.trim().isNotEmpty;

  void validateName(String val) {
    name.value = val.trim();
    nameError.value = name.value.isEmpty ? 'Nama harus diisi' : null;
  }

  // ================= USERNAME =================
  final username = ''.obs;
  final usernameError = Rxn<String>();

  bool get isUsernameValid =>
      usernameError.value == null && username.value.trim().isNotEmpty;

  void validateUsername(String val) {
    username.value = val.trim();

    if (username.value.isEmpty) {
      usernameError.value = 'Username harus diisi';
    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username.value)) {
      usernameError.value = 'Hanya huruf dan angka yang diperbolehkan';
    } else {
      usernameError.value = null;
    }
  }

  // ================= PASSWORD =================
  final password = ''.obs;
  final passwordError = Rxn<String>();

  bool get isPasswordValid =>
      passwordError.value == null && password.value.isNotEmpty;

  void validatePassword(String val) {
    password.value = val;

    final hasMinLength = val.length >= 6;
    final hasDigit = RegExp(r'[0-9]').hasMatch(val);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(val);

    if (hasMinLength && hasDigit && hasUpper) {
      passwordError.value = null;
    } else {
      passwordError.value =
          'Password minimal 6 karakter,\n1 angka, dan 1 huruf besar';
    }
  }

  // ================= UTIL =================
  void reset() {
    email.value = '';
    name.value = '';
    username.value = '';
    password.value = '';

    emailError.value = null;
    nameError.value = null;
    usernameError.value = null;
    passwordError.value = null;
  }
}
