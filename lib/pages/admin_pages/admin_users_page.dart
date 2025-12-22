import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/admin_users_controller.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  Future<bool> _confirmToggle({
    required bool nextValue,
    required String nama,
    required String email,
  }) async {
    final actionText = nextValue ? 'mengaktifkan' : 'menonaktifkan';

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(
          'Apakah Anda yakin ingin $actionText user ini?\n\n$nama\n$email',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya'),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminUsersController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data user: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('Belum ada user terdaftar'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data();

              final uid = (data['uid'] ?? doc.id).toString();
              final nama = (data['nama'] ?? '-').toString();
              final email = (data['email'] ?? '-').toString();
              final role = (data['role'] ?? '-').toString();

              final isActive = (data['is_active'] is bool)
                  ? data['is_active'] as bool
                  : true;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // kiri: info user
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(email),
                          const SizedBox(height: 2),
                          Text('Role: $role'),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // kanan: switch + status (tidak overflow)
                    Obx(() {
                      final isLoading = controller.togglingUid.value == uid;

                      return SizedBox(
                        width: 96, // sedikit lebih lebar biar stabil di web
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // bikin switch ikut center
                            Center(
                              child: Switch(
                                value: isActive,
                                onChanged: isLoading
                                    ? null
                                    : (val) async {
                                        final ok = await _confirmToggle(
                                          nextValue: val,
                                          nama: nama,
                                          email: email,
                                        );
                                        if (!ok) return;

                                        await controller.toggleUserStatus(
                                          uid: uid,
                                          nextValue: val,
                                        );
                                      },
                              ),
                            ),
                            const SizedBox(height: 4),

                            // status juga center
                            if (isLoading)
                              const SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Text(
                                isActive ? 'Aktif' : 'Nonaktif',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
