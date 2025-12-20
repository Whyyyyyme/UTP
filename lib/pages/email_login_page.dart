import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/login_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';

class EmailLoginPage extends StatelessWidget {
  const EmailLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    final emailC = TextEditingController();
    final passC = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3FA),
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                const Text(
                  "Masuk dengan Email",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),

                TextFormField(
                  controller: emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Obx(() {
                  return TextFormField(
                    controller: passC,
                    obscureText: controller.obscurePassword.value,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => controller.obscurePassword.value =
                            !controller.obscurePassword.value,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                Obx(() {
                  final msg = controller.errorMessage.value;
                  if (msg.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(msg, style: const TextStyle(color: Colors.red)),
                  );
                }),

                Obx(() {
                  final loading = controller.isLoading.value;
                  return SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              await controller.login(emailC.text, passC.text);
                              // NOTE: redirect ke home/admin sudah dilakukan di LoginController
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Login"),
                    ),
                  );
                }),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Get.toNamed(Routes.registerEmail),
                  child: const Text("Belum punya akun? Daftar dengan email"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
