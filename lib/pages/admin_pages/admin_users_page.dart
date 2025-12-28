// lib/pages/admin_pages/admin_users_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/admin_users_controller.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  // ===== THEME =====
  static const Color _bg = Color(0xFFF5F6FA);

  late final AdminUsersController controller;
  final TextEditingController _search = TextEditingController();

  // loading untuk delete user
  final RxnString _deletingUid = RxnString();

  @override
  void initState() {
    super.initState();
    controller = Get.put(AdminUsersController());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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

  Future<bool> _confirmDeleteUser({
    required String nama,
    required String email,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus User'),
        content: Text(
          'User ini akan dihapus dari tampilan (soft delete).\n\n$nama\n$email\n\nLanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return result == true;
  }

  Future<void> _softDeleteUser(String uid) async {
    // Soft delete: biar tidak tampil lagi, tanpa hapus akun FirebaseAuth
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'deleted': true,
      'deleted_at': FieldValue.serverTimestamp(),
      'is_active': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _GradientHeader(
              title: 'Kelola User',
              subtitle: 'Aktif/nonaktif akun pengguna',
              onBack: () => Get.back(),
            ),

            // SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: _SearchField(
                controller: _search,
                hint: 'Cari user (nama/email)...',
                onChanged: (_) => setState(() {}),
              ),
            ),

            // LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                    return const Center(
                      child: Text('Belum ada user terdaftar'),
                    );
                  }

                  // ✅ filter lokal: sembunyikan user yang deleted
                  final notDeleted = users.where((doc) {
                    final data = doc.data();
                    final deleted = data['deleted'] == true;
                    return !deleted;
                  }).toList();

                  // filter search lokal
                  final filtered = notDeleted.where((doc) {
                    final data = doc.data();

                    final nama =
                        (data['nama'] ??
                                data['username'] ??
                                data['name'] ??
                                '-')
                            .toString()
                            .toLowerCase();

                    final email = (data['email'] ?? '-')
                        .toString()
                        .toLowerCase();

                    if (q.isEmpty) return true;
                    return nama.contains(q) || email.contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('User tidak ditemukan'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();

                      final uid = (data['uid'] ?? doc.id).toString();

                      final nama =
                          (data['nama'] ??
                                  data['username'] ??
                                  data['name'] ??
                                  '-')
                              .toString();

                      final email = (data['email'] ?? '-').toString();
                      final role = (data['role'] ?? '-').toString();

                      final isActive = (data['is_active'] is bool)
                          ? data['is_active'] as bool
                          : true;

                      return _UserCard(
                        uid: uid,
                        nama: nama,
                        email: email,
                        role: role,
                        isActive: isActive,
                        togglingUidRx: controller.togglingUid,
                        deletingUidRx: _deletingUid,
                        onToggle: (val) async {
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
                        onDelete: () async {
                          final ok = await _confirmDeleteUser(
                            nama: nama,
                            email: email,
                          );
                          if (!ok) return;

                          try {
                            _deletingUid.value = uid;
                            await _softDeleteUser(uid);
                            Get.snackbar(
                              'Berhasil',
                              'User dihapus dari tampilan.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Gagal',
                              'Tidak bisa hapus user: $e',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } finally {
                            _deletingUid.value = null;
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================
// HEADER (linear dashboard)
// ==========================
class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _GradientHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E2E72), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================
// SEARCH FIELD (modern)
// ==========================
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: () {
                controller.clear();
                onChanged?.call('');
              },
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, size: 18, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================
// USER CARD (modern)
// ==========================
class _UserCard extends StatelessWidget {
  final String uid;
  final String nama;
  final String email;
  final String role;
  final bool isActive;

  final RxnString togglingUidRx;
  final RxnString deletingUidRx;

  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _UserCard({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    required this.isActive,
    required this.togglingUidRx,
    required this.deletingUidRx,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isActive ? Colors.green : Colors.red;
    final statusText = isActive ? 'Aktif' : 'Nonaktif';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              nama.isNotEmpty ? nama[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Pill(text: 'Role: $role', color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    _Pill(text: statusText, color: statusColor),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // kanan: delete + switch
          Obx(() {
            final isToggling = togglingUidRx.value == uid;
            final isDeleting = deletingUidRx.value == uid;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Hapus',
                  onPressed: (isToggling || isDeleting) ? null : onDelete,
                  icon: isDeleting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, color: Colors.red),
                ),
                SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: isActive,
                        onChanged: (isToggling || isDeleting) ? null : onToggle,
                      ),
                      if (isToggling)
                        const SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
