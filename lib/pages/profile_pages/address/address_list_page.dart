import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:prelovedly/controller/address_controller.dart';
import 'package:prelovedly/models/address_model.dart';
import 'add_address_page.dart';

class AddressListPage extends StatelessWidget {
  AddressListPage({super.key});

  final AddressController addressC = Get.isRegistered<AddressController>()
      ? Get.find<AddressController>()
      : Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
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
          'Alamat',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Pastikan alamatmu selalu terbaru dan lengkap.\n'
              'Untuk pesanan yang sudah diproses, alamat tidak bisa diubah. '
              'Alamat baru hanya akan berlaku untuk pesanan berikutnya.',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<AddressModel>>(
              stream: addressC.userAddressesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat alamat: ${snapshot.error}'),
                  );
                }

                final addresses = snapshot.data ?? [];

                if (addresses.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada alamat.\nTambahkan alamat baru.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];

                    final region = addr.regionDetail;
                    final firstPart = region.split(',').first.trim();

                    return Slidable(
                      key: ValueKey(addr.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              final confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  title: const Text('Hapus alamat'),
                                  content: const Text(
                                    'Yakin ingin menghapus alamat ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await addressC.deleteAddress(addr);
                              }
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Hapus',
                          ),
                        ],
                      ),
                      child: _AddressCard(address: addr, firstPart: firstPart),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                onPressed: () async {
                  await Get.to(() => AddAddressPage());
                },
                child: const Text(
                  '+ Tambah',
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
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final String firstPart;

  const _AddressCard({required this.address, required this.firstPart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address.receiverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('· '),
                    Flexible(
                      child: Text(
                        firstPart,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  address.regionDetail,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),

                Text(
                  address.phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
