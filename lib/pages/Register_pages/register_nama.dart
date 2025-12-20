import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/register_controller.dart';
import 'register.dart';

class NameRegisterPage extends StatelessWidget {
  const NameRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ ambil dari binding
    final registerController = Get.find<RegisterController>();

    return Obx(() {
      return RegisterScaffold(
        titleQuestion: 'Siapa nama kamu?',
        isValid: registerController.isNameValid,
        onNext: () {
          if (registerController.isNameValid) {
            Get.toNamed(
              Routes.registerUsername,
              arguments: {
                // email sudah ada di controller
              },
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
