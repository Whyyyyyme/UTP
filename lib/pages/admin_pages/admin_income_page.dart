// lib/pages/admin_pages/admin_income_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../view_model/admin_income_controller.dart';

class AdminIncomePage extends StatelessWidget {
  const AdminIncomePage({super.key});

  static const Color _bg = Color(0xFFF5F6FA);

  String _rupiah(num value) {
    final f = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ tidak mengubah logic controller, hanya memastikan controller ada
    final c = Get.put(AdminIncomeController());

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final isDesktop = w >= 1000;
            final isTablet = w >= 700 && w < 1000;

            final pad = EdgeInsets.fromLTRB(
              isDesktop ? 24 : 14,
              14,
              isDesktop ? 24 : 14,
              isDesktop ? 24 : 14,
            );

            final contentMaxW = isDesktop
                ? 1100.0
                : isTablet
                ? 900.0
                : double.infinity;

            final gridCols = isDesktop
                ? 3
                : isTablet
                ? 2
                : 1;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxW),
                child: Padding(
                  padding: pad,
                  child: Column(
                    children: [
                      _HeaderCard(
                        title: 'Penghasilan Admin',
                        subtitle: 'Ringkasan fee admin 3% dari order received',
                        onBack: () => Get.back(),
                      ),
                      const SizedBox(height: 14),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionTitle(
                                title: 'Ringkasan',
                                subtitle: 'Statistik cepat pendapatan platform',
                              ),
                              const SizedBox(height: 10),

                              // ===== BIG TOTAL CARD =====
                              Obx(() {
                                final loading = c.isLoading.value;
                                final err = c.error.value;
                                final total = c.totalFeeReceived.value;

                                return _BigMetricCard(
                                  icon: Icons.payments_rounded,
                                  title: 'Total Fee Admin',
                                  subtitle:
                                      'Akumulasi fee dari semua order berstatus received',
                                  value: _rupiah(total),
                                  accent: const Color(0xFF1B3C9E),
                                  loading: loading,
                                  errorText: err,
                                );
                              }),

                              const SizedBox(height: 12),

                              // ===== SMALL METRICS GRID (tanpa nambah field controller) =====
                              _ResponsiveGrid(
                                columns: gridCols,
                                gap: 12,
                                children: [
                                  Obx(() {
                                    final err = c.error.value;
                                    return _MetricCard(
                                      icon: Icons.check_circle_outline_rounded,
                                      title: 'Status Data',
                                      value: err == null ? 'OK' : 'Error',
                                      subtitle: err == null
                                          ? 'Stream realtime aktif'
                                          : 'Lihat detail error di card utama',
                                      tint: err == null
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                    );
                                  }),
                                  _MetricCard(
                                    icon: Icons.percent_rounded,
                                    title: 'Fee Admin',
                                    value: '3%',
                                    subtitle: 'Dipungut dari transaksi selesai',
                                    tint: const Color(0xFF8B5CF6),
                                  ),
                                  _MetricCard(
                                    icon: Icons.info_outline_rounded,
                                    title: 'Sumber Field',
                                    value: 'platform_fee_total',
                                    subtitle:
                                        'Diambil dari dokumen order (orders)',
                                    tint: const Color(0xFFF59E0B),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              _InfoCard(
                                title: 'Catatan Implementasi',
                                bullets: const [
                                  'Total dihitung dari semua order dengan status = received.',
                                  'Nilai fee diambil dari field platform_fee_total pada dokumen order.',
                                  'Jika total masih 0, pastikan order received sudah memiliki platform_fee_total (terisi).',
                                ],
                              ),

                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ==============================
/// HEADER (vibe admin dashboard)
/// ==============================
class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onBack,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// ==============================
/// SECTION TITLE
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
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
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
/// BIG METRIC CARD
/// ==============================
class _BigMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color accent;
  final bool loading;
  final String? errorText;

  const _BigMetricCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.loading,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = (errorText != null && errorText!.isNotEmpty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (loading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (hasError) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      errorText!,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ==============================
/// SMALL METRIC CARD
/// ==============================
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color tint;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
/// INFO CARD
/// ==============================
class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _InfoCard({required this.title, required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF0E2E72),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 12.8,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ==============================
/// SIMPLE RESPONSIVE GRID
/// ==============================
class _ResponsiveGrid extends StatelessWidget {
  final int columns;
  final double gap;
  final List<Widget> children;

  const _ResponsiveGrid({
    required this.columns,
    required this.gap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: children.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        mainAxisExtent: 110,
      ),
      itemBuilder: (context, i) => children[i],
    );
  }
}
