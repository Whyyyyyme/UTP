import 'package:flutter/material.dart';

import 'register_password.dart';
import 'register.dart';

class UsernameRegisterPage extends StatefulWidget {
  final String email;
  final String fullName;

  const UsernameRegisterPage({
    super.key,
    required this.email,
    required this.fullName,
  });

  @override
  State<UsernameRegisterPage> createState() => _UsernameRegisterPageState();
}

class _UsernameRegisterPageState extends State<UsernameRegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  String? _errorText;

  bool get _isValid {
    final u = _usernameController.text.trim();
    if (u.isEmpty) return false;
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(u);
  }

  void _onNext() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _errorText = 'Username harus diisi');
      return;
    }
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regex.hasMatch(username)) {
      setState(() => _errorText = 'Hanya huruf dan angka yang diperbolehkan');
      return;
    }
    setState(() => _errorText = null);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasswordRegisterPage(
          email: widget.email,
          fullName: widget.fullName,
          username: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegisterScaffold(
      titleQuestion: 'Pilih username',
      isValid: _isValid,
      onNext: _onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(errorText: _errorText),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Hanya huruf dan angka yang diperbolehkan',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
