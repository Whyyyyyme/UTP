import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/register_controller.dart';
import 'register_password.dart';
import 'register.dart';

class UsernameRegisterPage extends StatelessWidget {
  final String email;
  final String fullName;

  const UsernameRegisterPage({
    super.key,
    required this.email,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    // RegisterController sudah di-Get.put di EmailRegisterPage
    final registerController = Get.find<RegisterController>();

    return Obx(() {
      return RegisterScaffold(
        titleQuestion: 'Pilih username',
        isValid: registerController.isUsernameValid,
        onNext: () {
          if (registerController.isUsernameValid) {
            Get.to(
              () => PasswordRegisterPage(
                email: email,
                fullName: fullName,
                username: registerController.username.value,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                errorText: registerController.usernameError.value,
              ),
              onChanged: registerController.validateUsername,
            ),
            const SizedBox(height: 8),
            const Text(
              'Hanya huruf dan angka yang diperbolehkan',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    });
  }
}
