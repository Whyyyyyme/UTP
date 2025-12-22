import 'package:flutter/material.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        backgroundColor: Colors.redAccent,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Halaman Kelola User (MVP) - next kita isi list user dari Firestore.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
