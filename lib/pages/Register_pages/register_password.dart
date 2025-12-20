import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/register_controller.dart';
import 'package:prelovedly/view_model/auth_controller.dart';
import 'register.dart';

class PasswordRegisterPage extends StatefulWidget {
  const PasswordRegisterPage({super.key});

  @override
  State<PasswordRegisterPage> createState() => _PasswordRegisterPageState();
}

class _PasswordRegisterPageState extends State<PasswordRegisterPage> {
  final RegisterController registerController = Get.find<RegisterController>();
  final AuthController authController = Get.find<AuthController>();

  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pwd = registerController.password.value;

      return RegisterScaffold(
        titleQuestion: 'Buat password',
        isValid:
            registerController.isPasswordValid &&
            !authController.isLoading.value,
        onNext: () async {
          if (!registerController.isPasswordValid) return;

          await authController.signUp(
            email: registerController.email.value,
            password: pwd,
            nama: registerController.name.value,
            username: registerController.username.value,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: registerController.passwordError.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                ),
              ),
              onChanged: registerController.validatePassword,
            ),
            const SizedBox(height: 16),

            PasswordRuleItem(
              text: 'Minimal 6 karakter',
              satisfied: pwd.length >= 6,
            ),
            PasswordRuleItem(
              text: 'Satu angka',
              satisfied: RegExp(r'[0-9]').hasMatch(pwd),
            ),
            PasswordRuleItem(
              text: 'Satu huruf besar',
              satisfied: RegExp(r'[A-Z]').hasMatch(pwd),
            ),
          ],
        ),
      );
    });
  }
}
