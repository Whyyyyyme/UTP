import 'package:get/get.dart';

class RegisterController extends GetxController {
  final email = ''.obs;
  final emailError = Rxn<String>();

  bool get isEmailValid =>
      emailError.value == null && email.value.trim().isNotEmpty;

  void validateEmail(String val) {
    email.value = val;
    final trimmed = val.trim();

    if (trimmed.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!trimmed.contains('@')) {
      emailError.value = 'Email tidak valid';
    } else {
      emailError.value = null;
    }
  }

  final name = ''.obs;
  final nameError = Rxn<String>();

  bool get isNameValid =>
      nameError.value == null && name.value.trim().isNotEmpty;

  void validateName(String val) {
    name.value = val;
    final trimmed = val.trim();

    if (trimmed.isEmpty) {
      nameError.value = 'Nama harus diisi';
    } else {
      nameError.value = null;
    }
  }

  final username = ''.obs;
  final usernameError = Rxn<String>();

  bool get isUsernameValid =>
      usernameError.value == null && username.value.trim().isNotEmpty;

  void validateUsername(String val) {
    username.value = val;
    final trimmed = val.trim();

    if (trimmed.isEmpty) {
      usernameError.value = 'Username harus diisi';
    } else {
      final regex = RegExp(r'^[a-zA-Z0-9]+$');
      if (!regex.hasMatch(trimmed)) {
        usernameError.value = 'Hanya huruf dan angka yang diperbolehkan';
      } else {
        usernameError.value = null;
      }
    }
  }

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
          'Password harus minimal 8 karakter,\n1 angka, dan 1 huruf besar';
    }
  }

  bool get canProceed =>
      isEmailValid && isNameValid && isUsernameValid && isPasswordValid;
}
