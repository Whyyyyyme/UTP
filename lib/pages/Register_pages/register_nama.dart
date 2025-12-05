import 'package:flutter/material.dart';

import 'register.dart';
import 'register_username.dart';

class NameRegisterPage extends StatefulWidget {
  final String email;

  const NameRegisterPage({super.key, required this.email});

  @override
  State<NameRegisterPage> createState() => _NameRegisterPageState();
}

class _NameRegisterPageState extends State<NameRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  void _onNext() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Nama harus diisi');
      return;
    }
    setState(() => _errorText = null);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            UsernameRegisterPage(email: widget.email, fullName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegisterScaffold(
      titleQuestion: 'Siapa nama kamu?',
      isValid: _isValid,
      onNext: _onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama lengkap',
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
