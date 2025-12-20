import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // ✅ AMBIL dari binding
    final loginController = Get.find<LoginController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              Obx(() {
                return TextFormField(
                  controller: _passwordController,
                  obscureText: loginController.obscurePassword.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginController.obscurePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: loginController.togglePassword,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 25),

              Obx(() {
                return ElevatedButton(
                  onPressed: loginController.isLoading.value
                      ? null
                      : () => loginController.login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        ),
                  child: loginController.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                );
              }),

              TextButton(
                onPressed: () => Get.toNamed(Routes.registerEmail),
                child: const Text('Belum punya akun? Daftar'),
              ),

              Obx(() {
                final msg = loginController.errorMessage.value;
                return msg.isNotEmpty
                    ? Text(msg, style: const TextStyle(color: Colors.red))
                    : const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
