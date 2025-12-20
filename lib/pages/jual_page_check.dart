import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/address_controller.dart';

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

    // controller HARUS dari binding
    addressC = Get.find<AddressController>();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    final hasAddress = await addressC.hasAnyAddress();
    if (!mounted) return;

    if (hasAddress) {
      Get.offNamed(Routes.sellAddressIntro);
    } else {
      setState(() => _checking = false);
    }
  }

  Future<void> _afterAddAddress() async {
    final hasAddress = await addressC.hasAnyAddress();
    if (!mounted) return;

    if (hasAddress) {
      Get.offNamed(Routes.sellProduct);
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
            const Text(
              'Tambah alamat',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Masukkan alamat pickup untuk estimasi ongkir '
                'dan penjemputan kurir.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 40),

            Expanded(
              child: Center(
                child: Image.asset('assets/images/map_pin.png', height: 220),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await Get.toNamed(Routes.addressList);
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
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
