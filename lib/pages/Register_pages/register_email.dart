import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/register_controller.dart';
import 'register_nama.dart';
import 'register.dart';

class EmailRegisterPage extends StatelessWidget {
  const EmailRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

    return Obx(() {
      return RegisterScaffold(
        titleQuestion: 'Apa email kamu?',
        isValid: controller.isEmailValid,
        onNext: () {
          if (controller.isEmailValid) {
            Get.to(() => const NameRegisterPage());
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email address',
                errorText: controller.emailError.value,
              ),
              onChanged: controller.validateEmail,
            ),
          ],
        ),
      );
    });
  }
}
