import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/register_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'register.dart';

class UsernameRegisterPage extends StatelessWidget {
  const UsernameRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final registerController = Get.find<RegisterController>();

    return Obx(() {
      return RegisterScaffold(
        titleQuestion: 'Pilih username',
        isValid: registerController.isUsernameValid,
        onNext: () {
          if (registerController.isUsernameValid) {
            Get.toNamed(Routes.registerPassword);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
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
