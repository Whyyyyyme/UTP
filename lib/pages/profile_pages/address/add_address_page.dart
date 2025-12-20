import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/address_controller.dart';
import 'search_address_page.dart';

class AddAddressPage extends StatelessWidget {
  AddAddressPage({super.key});

  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // ✅ Controller wajib sudah didaftarkan dari GetPage binding
    final AddressController addressC = Get.find<AddressController>();

    return Obx(() {
      final isSaving = addressC.isSaving.value;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: const Text(
            'Alamat baru',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Label('Nama penerima'),
                  TextField(
                    controller: _nameC,
                    decoration: const InputDecoration(
                      hintText: 'Nama penerima',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const Divider(height: 1),

                  _Label('Nomor telepon'),
                  TextField(
                    controller: _phoneC,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Gunakan nomor WhatsApp yang aktif',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const Divider(height: 1),

                  InkWell(
                    onTap: () async {
                      final result = await Get.to<String>(
                        () => SearchAddressPage(
                          initialText: addressC.selectedRegion.value,
                        ),
                      );

                      if (result != null && result.trim().isNotEmpty) {
                        addressC.selectedRegion.value = result.trim();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Label('Detail wilayah'),
                                const SizedBox(height: 4),
                                Obx(() {
                                  final text = addressC.selectedRegion.value;
                                  return Text(
                                    text.isEmpty ? 'Cari alamat kamu' : text,
                                    style: TextStyle(
                                      color: text.isEmpty
                                          ? Colors.grey
                                          : Colors.black,
                                      fontSize: 15,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final res = await addressC.saveNewAddress(
                            receiverName: _nameC.text,
                            phone: _phoneC.text,
                          );

                          // ✅ res = (bool ok, String message)
                          final ok = res.$1;
                          final msg = res.$2;

                          if (ok) {
                            _nameC.clear();
                            _phoneC.clear();
                            addressC.selectedRegion.value = '';

                            Get.back();

                            Get.snackbar(
                              'Berhasil',
                              msg,
                              snackPosition: SnackPosition.TOP,
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              msg,
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
