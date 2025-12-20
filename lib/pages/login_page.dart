import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/login_controller.dart';
import 'package:prelovedly/pages/email_login_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController loginController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _snack(String msg) {
    Get.snackbar(
      "Info",
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withOpacity(0.75),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    loginController = Get.find<LoginController>(); // ✅ dari binding
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight;

          final scale = (h / 760).clamp(0.85, 1.0);

          final logoWidth = 220 * scale;
          final topPad = 70 * scale;
          final midGap = 60 * scale;
          final btnH = 52 * scale;
          final gap12 = 12 * scale;
          final gap18 = 18 * scale;
          final gap22 = 22 * scale;

          return Stack(
            children: [
              // Background image
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/baground6.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Overlay gelap
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000),
                      Color(0xB3000000),
                      Color(0xE6000000),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        children: [
                          SizedBox(height: topPad),

                          // LOGO
                          Image.asset(
                            'assets/images/logoPreTransparant.png',
                            width: logoWidth,
                            fit: BoxFit.contain,
                          ),

                          SizedBox(height: 10 * scale),

                          Text(
                            "Indonesia",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16 * scale,
                            ),
                          ),

                          SizedBox(height: midGap),

                          // ===== OPTIONAL: Form Email & Password (biar tombol Login bisa jalan di halaman ini)
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12 * scale),

                          Obx(() {
                            final obscure =
                                loginController.obscurePassword.value;
                            return TextField(
                              controller: _passwordController,
                              obscureText: obscure,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: loginController.togglePassword,
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            );
                          }),

                          SizedBox(height: gap18),

                          // Tombol Login (email+password)
                          Obx(() {
                            final loading = loginController.isLoading.value;
                            return SizedBox(
                              width: double.infinity,
                              height: btnH,
                              child: ElevatedButton(
                                onPressed: loading
                                    ? null
                                    : () => loginController.login(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            );
                          }),

                          const SizedBox(height: 10),

                          Obx(() {
                            final msg = loginController.errorMessage.value;
                            return msg.isNotEmpty
                                ? Text(
                                    msg,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : const SizedBox.shrink();
                          }),

                          SizedBox(height: gap22),

                          // BUTTON Google
                          _AuthButton(
                            height: btnH,
                            background: Colors.white,
                            foreground: Colors.black,
                            icon: const _CircleIcon(
                              child: Text(
                                "G",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            text: "Masuk lewat Google",
                            onPressed: () =>
                                _snack("Google Sign-In belum diaktifkan"),
                          ),

                          SizedBox(height: gap12),

                          // BUTTON Apple
                          _AuthButton(
                            height: btnH,
                            background: Colors.white,
                            foreground: Colors.black,
                            icon: Icon(
                              Icons.apple,
                              color: Colors.black,
                              size: 24 * scale,
                            ),
                            text: "Masuk lewat Apple",
                            onPressed: () =>
                                _snack("Apple Sign-In belum diaktifkan"),
                          ),

                          SizedBox(height: gap18),

                          // atau
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10 * scale,
                                ),
                                child: Text(
                                  "atau",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14 * scale,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: gap18),

                          // Daftar email
                          _OutlineAuthButton(
                            height: btnH,
                            text: "Daftar dengan email",
                            onPressed: () => Get.toNamed(Routes.registerEmail),
                          ),

                          SizedBox(height: gap22),

                          // Sudah punya account? Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sudah punya account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14 * scale,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Get.to(() => const EmailLoginPage()),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14 * scale,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 14 * scale),

                          GestureDetector(
                            onTap: () => _snack("Guest mode belum diatur"),
                            child: Text(
                              "Register nanti",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                fontSize: 14 * scale,
                              ),
                            ),
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------- widgets ----------
class _AuthButton extends StatelessWidget {
  final double height;
  final Color background;
  final Color foreground;
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.height,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _OutlineAuthButton extends StatelessWidget {
  final double height;
  final String text;
  final VoidCallback onPressed;

  const _OutlineAuthButton({
    required this.height,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.75), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final Widget child;
  const _CircleIcon({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
