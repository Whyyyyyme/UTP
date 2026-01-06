import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpDeskPage extends StatelessWidget {
  const HelpDeskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helpdesk', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cara belanja di Prelovedly',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Placeholder untuk Video Player
            
            const SizedBox(height: 24),
            _buildStep(
              number: "1",
              title: "Temukan produk favoritmu",
              desc: "Jelajahi puluhan ribu produk unik dari berbagai merek. Pilih yang kamu suka dan nikmati pengalaman belanja online yang seru.",
            ),
            _buildStep(
              number: "2",
              title: "Klik Beli Sekarang",
              desc: "Punya pertanyaan tentang produk? Tanyakan langsung ke penjual sebelum klik \"Beli Sekarang\". Lakukan pembayaran dengan aman.",
            ),
            _buildStep(
              number: "3",
              title: "Produk diterima!",
              desc: "Cek status pengiriman langsung di aplikasi Prelovedly. Jangan lupa berikan ulasan setelah barang diterima!",
            ),
            _buildStep(
              number: "4",
              title: "Belanja dengan tenang dan aman",
              desc: "Prelovedly menjaga keamanan transaksi dengan biaya Perlindungan Pembeli 3% yang sudah termasuk dalam harga total.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required String number, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$number. ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}