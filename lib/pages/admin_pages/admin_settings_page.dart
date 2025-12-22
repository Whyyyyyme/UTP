import 'package:flutter/material.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan App'),
        backgroundColor: Colors.redAccent,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Halaman Pengaturan App (MVP) - next kita bikin config Firestore: app_config/main.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
