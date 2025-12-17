import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/login_controller.dart';
import 'Register_pages/register_email.dart';



class LoginPage extends StatelessWidget {

  
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());

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
                keyboardType: TextInputType.emailAddress,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Masukkan email'
                    : null,
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
                      onPressed: () {
                        loginController.obscurePassword.value =
                            !loginController.obscurePassword.value;
                      },
                    ),
                  ),
                  validator: (val) => (val == null || val.length < 6)
                      ? 'Password minimal 6 karakter'
                      : null,
                );
              }),

              const SizedBox(height: 25),

              Obx(() {
                final isLoading = loginController.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            // Cukup panggil fungsi ini saja
                            // Controller sudah punya logic Get.offAllNamed di dalamnya
                            await loginController.login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                );
              }),

              const SizedBox(height: 15),

              Obx(() {
                final isLoading = loginController.isLoading.value;
                return TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Get.to(() => const EmailRegisterPage());
                        },
                  child: const Text('Belum punya akun? Daftar di sini'),
                );
              }),

              const SizedBox(height: 8),

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
