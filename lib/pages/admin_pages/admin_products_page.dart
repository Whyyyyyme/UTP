import 'package:flutter/material.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Produk'),
        backgroundColor: Colors.redAccent,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Halaman Semua Produk (MVP) - next kita isi list produk dari Firestore.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
