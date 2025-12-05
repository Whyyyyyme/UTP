import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prelovedly/pages/home_page.dart';
import 'register.dart';

class PasswordRegisterPage extends StatefulWidget {
  final String email;
  final String fullName;
  final String username;

  const PasswordRegisterPage({
    super.key,
    required this.email,
    required this.fullName,
    required this.username,
  });

  @override
  State<PasswordRegisterPage> createState() => _PasswordRegisterPageState();
}

class _PasswordRegisterPageState extends State<PasswordRegisterPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  bool get _hasMinLength => _passwordController.text.length >= 6;
  bool get _hasDigit => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _isValid => _hasMinLength && _hasDigit && _hasUpper;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onFinish() async {
    if (!_isValid) return;

    final password = _passwordController.text.trim();

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: password,
      );

      final uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': widget.email,
        'nama': widget.fullName,
        'username': widget.username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';

      if (e.code == 'email-already-in-use') {
        message = 'Email sudah terdaftar';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RegisterScaffold(
      titleQuestion: 'Buat password',
      isValid: _isValid,
      onNext: _onFinish,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() => _obscure = !_obscure);
                },
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          PasswordRuleItem(
            text: 'Minimal 8 karakter',
            satisfied: _hasMinLength,
          ),
          PasswordRuleItem(text: 'Satu angka', satisfied: _hasDigit),
          PasswordRuleItem(text: 'Satu huruf besar', satisfied: _hasUpper),
        ],
      ),
    );
  }
}
