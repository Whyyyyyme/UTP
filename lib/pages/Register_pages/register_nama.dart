import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/register_controller.dart';
import 'register_username.dart';
import 'register.dart';

class NameRegisterPage extends StatelessWidget {
  final String email;

  const NameRegisterPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    // RegisterController sudah di-Get.put di EmailRegisterPage
    final registerController = Get.find<RegisterController>();

    return Obx(() {
      return RegisterScaffold(
        titleQuestion: 'Siapa nama kamu?',
        isValid: registerController.isNameValid,
        onNext: () {
          if (registerController.isNameValid) {
            Get.to(
              () => UsernameRegisterPage(
                email: email,
                fullName: registerController.name.value,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama lengkap',
                errorText: registerController.nameError.value,
              ),
              onChanged: registerController.validateName,
            ),
          ],
        ),
      );
    });
  }
}
