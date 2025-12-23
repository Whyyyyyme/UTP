import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/view_model/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  // ====== THEME ======
  static const Color _primary = Color(0xFF0E2E72);
  static const Color _bg = Color(0xFFF5F6FA);

  // ======================
  // FIRESTORE COUNTERS
  // ======================
  Stream<int> _userCountStream() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((s) {
      final nonAdmin = s.docs.where((d) {
        final data = d.data();
        final role = (data['role'] ?? '').toString().toLowerCase();
        return role != 'admin';
      }).length;

      return nonAdmin;
    });
  }


  Stream<int> _publishedProductCountStream() {
    // Asumsi: products.status = "published"
    return FirebaseFirestore.instance
        .collection('products')
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((s) => s.docs.length);

    // Kalau di project kamu pakai boolean:
    // return FirebaseFirestore.instance
    //     .collection('products')
    //     .where('published', isEqualTo: true)
    //     .snapshots()
    //     .map((s) => s.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ======================
            // HEADER (GRADIENT)
            // ======================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E2E72), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Welcome Admin 👋',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Logout',
                        onPressed: () async {
                          await AuthController.to.signOut();
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: _primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ======================
            // CONTENT
            // ======================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ======================
                    // QUICK STATS (LIVE)
                    // ======================
                    Row(
                      children: [
                        StreamBuilder<int>(
                          stream: _userCountStream(),
                          builder: (context, snap) {
                            final v = snap.data;
                            return _StatCard(
                              title: 'User',
                              value: v == null ? '—' : v.toString(),
                              icon: Icons.people,
                              color: Colors.blue,
                            );
                          },
                        ),
                        StreamBuilder<int>(
                          stream: _publishedProductCountStream(),
                          builder: (context, snap) {
                            final v = snap.data;
                            return _StatCard(
                              title: 'Produk',
                              value: v == null ? '—' : v.toString(),
                              icon: Icons.shopping_bag,
                              color: Colors.green,
                            );
                          },
                        ),
                        const _StatCard(
                          title: 'Order',
                          value: '—',
                          icon: Icons.receipt_long,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ======================
                    // GRID MENU
                    // ======================
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                        children: [
                          _AdminMenuCard(
                            icon: Icons.people,
                            title: 'Kelola User',
                            subtitle: 'Aktif/nonaktif akun',
                            color: Colors.blue,
                            onTap: () => Get.toNamed(Routes.adminUsers),
                          ),
                          _AdminMenuCard(
                            icon: Icons.shopping_bag,
                            title: 'Semua Produk',
                            subtitle: 'Kelola listing barang',
                            color: Colors.green,
                            onTap: () => Get.toNamed(Routes.adminProducts),
                          ),
                          _AdminMenuCard(
                            icon: Icons.assessment,
                            title: 'Laporan',
                            subtitle: 'Ringkasan aktivitas',
                            color: Colors.orange,
                            onTap: () => Get.toNamed(Routes.adminReports),
                          ),
                          _AdminMenuCard(
                            icon: Icons.settings,
                            title: 'Pengaturan App',
                            subtitle: 'Konfigurasi sistem',
                            color: Colors.grey,
                            onTap: () => Get.toNamed(Routes.adminSettings),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// STAT CARD (Kecil di atas)
// =====================================================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// MENU CARD (Modern)
// =====================================================
class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
