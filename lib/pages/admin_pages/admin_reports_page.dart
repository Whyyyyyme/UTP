import 'package:flutter/material.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: Colors.redAccent,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Halaman Laporan (MVP) - next kita hitung total user, produk, transaksi, nego, dll.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
