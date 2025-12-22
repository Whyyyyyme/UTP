import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/admin_users_controller.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

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
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    nama,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '$email\nRole: $role',
                    style: const TextStyle(height: 1.4),
                  ),
                  isThreeLine: true,
                  trailing: Obx(() {
                    final isLoading = controller.togglingUid.value == uid;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: isActive,
                          onChanged: isLoading
                              ? null
                              : (val) async {
                                  await controller.toggleUserStatus(
                                    uid: uid,
                                    nextValue: val,
                                  );
                                },
                        ),
                        isLoading
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isActive ? 'Aktif' : 'Nonaktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ],
                    );
                  }),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
