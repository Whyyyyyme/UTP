import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/controller/address_controller.dart';
import 'package:prelovedly/pages/sell_pages/sell_page.dart';
import 'package:prelovedly/pages/profile_pages/address/address_list_page.dart';

class SellAddressIntroPage extends StatefulWidget {
  const SellAddressIntroPage({super.key});

  @override
  State<SellAddressIntroPage> createState() => _SellAddressIntroPageState();
}

class _SellAddressIntroPageState extends State<SellAddressIntroPage> {
  late final AddressController addressC;

  bool _checking = true;

  @override
  void initState() {
    super.initState();
    // pastikan controller ada
    addressC = Get.isRegistered<AddressController>()
        ? AddressController.to
        : Get.put(AddressController());
    _checkAndNavigate();
  }

  /// 🔍 Cek apakah user sudah punya minimal 1 alamat.
  /// Kalau sudah → langsung ke halaman jual.
  Future<void> _checkAndNavigate() async {
    final hasAddress = await addressC.hasAnyAddress();

    if (!mounted) return;

    if (hasAddress) {
      Get.off(() => const JualPage());
    } else {
      setState(() {
        _checking = false;
      });
    }
  }

  /// Dipanggil setelah kembali dari AddressListPage
  Future<void> _afterAddAddress() async {
    final hasAddress = await addressC.hasAnyAddress();
    if (!mounted) return;

    if (hasAddress) {
      Get.off(() => const JualPage());
    } else {
      // kalau tetap belum ada alamat, tetap di intro saja
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Judul
            const Text(
              'Tambah alamat',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subjudul
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Masukkan alamat pickup untuk estimasi ongkir '
                'dan penjemputan kurir.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 40),

            // Gambar map-pin (pastikan asset sudah didaftarkan di pubspec.yaml)
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/map_pin.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Tombol "Tambah alamat"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    // Buka list alamat → di sana user bisa tambah alamat baru
                    await Get.to(() => AddressListPage());
                    // Setelah balik dari sana, cek lagi
                    await _afterAddAddress();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Tambah alamat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Tombol "Nanti saja"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Balik ke halaman sebelumnya (misal: tab home)
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F7F7),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Nanti saja',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
