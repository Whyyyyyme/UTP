import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/register_controller.dart';
import 'register_nama.dart';
import 'register.dart';

class EmailRegisterPage extends StatelessWidget {
  const EmailRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan cuma dibuat sekali
    final controller = Get.put(RegisterController());

    return Obx(() {
      return RegisterScaffold(
        titleQuestion: 'Apa email kamu?',
        isValid: controller.isEmailValid, // sekarang bool, bukan RxBool
        onNext: () {
          if (controller.isEmailValid) {
            Get.to(() => NameRegisterPage(email: controller.email.value));
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email address',
                errorText: controller.emailError.value, // dari controller
              ),
              onChanged: controller.validateEmail,
            ),
          ],
        ),
      );
    });
  }
}
