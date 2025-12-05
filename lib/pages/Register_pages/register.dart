import 'package:flutter/material.dart';

class RegisterScaffold extends StatelessWidget {
  final String titleQuestion;
  final Widget child;
  final bool isValid;
  final VoidCallback onNext;

  const RegisterScaffold({
    super.key,
    required this.titleQuestion,
    required this.child,
    required this.isValid,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleQuestion,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: isValid ? onNext : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Lanjutkan'),
          ),
        ),
      ),
    );
  }
}

class PasswordRuleItem extends StatelessWidget {
  final String text;
  final bool satisfied;

  const PasswordRuleItem({
    super.key,
    required this.text,
    required this.satisfied,
  });

  @override
  Widget build(BuildContext context) {
    final color = satisfied ? Colors.green : Colors.red;
    final icon = satisfied ? Icons.check : Icons.close;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}
