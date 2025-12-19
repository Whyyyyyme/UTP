import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/pages/email_login_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND (kosong dulu - nanti kamu custom pakai image)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black12,
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      const SizedBox(height: 90),

                      const Text(
                        "PRELOVEDLY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Indonesia",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 140),

                      // Google (dummy)
                      _AuthButton(
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

                      const SizedBox(height: 12),

                      // Apple (dummy)
                      _AuthButton(
                        background: Colors.white,
                        foreground: Colors.black,
                        icon: const Icon(
                          Icons.apple,
                          color: Colors.black,
                          size: 24,
                        ),
                        text: "Masuk lewat Apple",
                        onPressed: () =>
                            _snack("Apple Sign-In belum diaktifkan"),
                      ),

                      const SizedBox(height: 18),

                      // atau
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "atau",
                              style: TextStyle(color: Colors.white70),
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

                      const SizedBox(height: 18),

                      // Daftar email -> flow register lama kamu (Routes.registerEmail)
                      _OutlineAuthButton(
                        text: "Daftar dengan email",
                        onPressed: () => Get.toNamed(Routes.registerEmail),
                      ),

                      const SizedBox(height: 22),

                      // Sudah punya account? Login -> EmailLoginPage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sudah punya account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.to(() => const EmailLoginPage()),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Register nanti (optional)
                      GestureDetector(
                        onTap: () => _snack("Guest mode belum diatur"),
                        child: const Text(
                          "Register nanti",
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- WIDGETS ----------
class _AuthButton extends StatelessWidget {
  final Color background;
  final Color foreground;
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
  final String text;
  final VoidCallback onPressed;

  const _OutlineAuthButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
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
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
