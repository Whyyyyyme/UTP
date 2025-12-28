// lib/pages/admin_pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const Color _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;

            final bool isDesktop = w >= 1000;
            final bool isTablet = w >= 700 && w < 1000;

            if (isDesktop) {
              return Row(
                children: [
                  _DesktopSidebar(
                    selectedIndex: 0,
                    onSelect: (i) {
                      if (i == 0) return;
                      if (i == 1) Get.toNamed(Routes.adminUsers);
                      if (i == 2) Get.toNamed(Routes.adminProducts);
                      if (i == 3) Get.toNamed(Routes.adminReports);
                      if (i == 4) Get.toNamed(Routes.adminSettings);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          child: const _DashboardContent(
                            statsColumns: 4,
                            menuColumns: 3,
                            headerCompact: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (isTablet) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: const _DashboardContent(
                      statsColumns: 3,
                      menuColumns: 2,
                      headerCompact: false,
                    ),
                  ),
                ),
              );
            }

            return const Padding(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: _DashboardContent(
                statsColumns: 2,
                menuColumns: 2,
                headerCompact: true,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ==============================
/// MAIN CONTENT
/// ==============================
class _DashboardContent extends StatelessWidget {
  final int statsColumns;
  final int menuColumns;
  final bool headerCompact;

  const _DashboardContent({
    required this.statsColumns,
    required this.menuColumns,
    required this.headerCompact,
  });

  @override
  Widget build(BuildContext context) {
    const stats = <Widget>[
      _StatCard(
        icon: Icons.group,
        label: 'User',
        value: '12',
        tint: Color(0xFF3B82F6),
      ),
      _StatCard(
        icon: Icons.shopping_bag,
        label: 'Produk',
        value: '13',
        tint: Color(0xFF22C55E),
      ),
      _StatCard(
        icon: Icons.receipt_long,
        label: 'Order',
        value: '-',
        tint: Color(0xFFF59E0B),
      ),
      _StatCard(
        icon: Icons.handshake,
        label: 'Nego',
        value: '-',
        tint: Color(0xFF8B5CF6),
      ),
    ];

    final menus = <Widget>[
      _MenuCard(
        icon: Icons.people_alt_rounded,
        title: 'Kelola User',
        subtitle: 'Aktif/nonaktif akun',
        color: const Color(0xFF3B82F6),
        onTap: () => Get.toNamed(Routes.adminUsers),
      ),
      _MenuCard(
        icon: Icons.shopping_bag_rounded,
        title: 'Semua Produk',
        subtitle: 'Kelola listing barang',
        color: const Color(0xFF22C55E),
        onTap: () => Get.toNamed(Routes.adminProducts),
      ),
      _MenuCard(
        icon: Icons.bar_chart_rounded,
        title: 'Laporan',
        subtitle: 'Ringkasan aktivitas',
        color: const Color(0xFFF59E0B),
        onTap: () => Get.toNamed(Routes.adminReports),
      ),
      _MenuCard(
        icon: Icons.settings_rounded,
        title: 'Pengaturan App',
        subtitle: 'Konfigurasi sistem',
        color: const Color(0xFF64748B),
        onTap: () => Get.toNamed(Routes.adminSettings),
      ),
    ];

    // Tinggi item menu berbeda per ukuran (biar aman)
    final double menuExtent = menuColumns >= 3 ? 110 : 126;

    return Column(
      children: [
        _Header(compact: headerCompact),
        const SizedBox(height: 16),
        const _SectionTitle(
          title: 'Ringkasan',
          subtitle: 'Statistik aplikasi secara cepat',
        ),
        const SizedBox(height: 10),

        // ✅ STATS: fixed height (anti overflow)
        GridView.builder(
          itemCount: stats.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: statsColumns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 86,
          ),
          itemBuilder: (context, i) => stats[i],
        ),

        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'Menu Admin',
          subtitle: 'Kelola modul utama aplikasi',
        ),
        const SizedBox(height: 10),

        // ✅ MENU: fixed height (anti overflow)
        Expanded(
          child: GridView.builder(
            itemCount: menus.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: menuColumns,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: menuExtent,
            ),
            itemBuilder: (context, i) => menus[i],
          ),
        ),
      ],
    );
  }
}

/// ==============================
/// HEADER
/// ==============================
class _Header extends StatelessWidget {
  final bool compact;
  const _Header({required this.compact});

  Future<void> _logout() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun admin?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout'),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (ok != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      // ✅ PENTING: hapus semua halaman sebelumnya supaya tidak bisa back ke admin
      Get.offAllNamed(Routes.login); // <-- ganti kalau route login kamu beda
    } catch (e) {
      Get.snackbar(
        'Logout gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        compact ? 14 : 18,
        18,
        compact ? 16 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E2E72), Color(0xFF1B3C9E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 18 : 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Welcome Admin 👋',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: compact ? 12.5 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: compact ? 18 : 20,
            backgroundColor: Colors.white.withOpacity(0.22),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// ==============================
/// DESKTOP SIDEBAR
/// ==============================
class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelect;

  const _DesktopSidebar({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE6E8F0))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PRELOVEDLY',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                fontSize: 16,
                color: Color(0xFF0E2E72),
              ),
            ),
            const SizedBox(height: 18),
            _SideItem(
              icon: Icons.dashboard_rounded,
              title: 'Dashboard',
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            _SideItem(
              icon: Icons.people_alt_rounded,
              title: 'Users',
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
            _SideItem(
              icon: Icons.shopping_bag_rounded,
              title: 'Products',
              selected: selectedIndex == 2,
              onTap: () => onSelect(2),
            ),
            _SideItem(
              icon: Icons.bar_chart_rounded,
              title: 'Reports',
              selected: selectedIndex == 3,
              onTap: () => onSelect(3),
            ),
            _SideItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              selected: selectedIndex == 4,
              onTap: () => onSelect(4),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Admin',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

class _SideItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SideItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF0E2E72)
                  : const Color(0xFF667085),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? const Color(0xFF0E2E72)
                      : const Color(0xFF344054),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==============================
/// TITLES
/// ==============================
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ==============================
/// STAT CARD
/// ==============================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
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

/// ==============================
/// MENU CARD
/// ==============================
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12.5,
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
