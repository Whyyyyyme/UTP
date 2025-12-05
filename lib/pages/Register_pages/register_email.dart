import 'package:flutter/material.dart';

import 'register_nama.dart';
import 'register.dart';

class EmailRegisterPage extends StatefulWidget {
  const EmailRegisterPage({super.key});

  @override
  State<EmailRegisterPage> createState() => _EmailRegisterPageState();
}

class _EmailRegisterPageState extends State<EmailRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorText;

  bool get _isValid {
    final email = _emailController.text.trim();
    if (email.isEmpty) return false;
    return email.contains('@');
  }

  void _onNext() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Email is required');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorText = 'Email tidak valid');
      return;
    }
    setState(() => _errorText = null);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NameRegisterPage(email: email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegisterScaffold(
      titleQuestion: 'Apa email kamu?',
      isValid: _isValid,
      onNext: _onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email address',
              errorText: _errorText,
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
