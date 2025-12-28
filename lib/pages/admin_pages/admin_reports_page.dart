import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  static const Color _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: const [
            _Header(),
            Expanded(child: _ReportsBody()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laporan Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Riwayat order (buyer & seller)',
                  style: TextStyle(
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

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  Query<Map<String, dynamic>> _baseQuery() {
    return FirebaseFirestore.instance
        .collection('orders')
        .orderBy('updated_at', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    final q = _baseQuery();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Gagal memuat transaksi:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('Belum ada transaksi'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final orderDoc = docs[i];
            return _OrderCard(orderId: orderDoc.id, orderData: orderDoc.data());
          },
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const _OrderCard({required this.orderId, required this.orderData});

  // cache nama user biar hemat reads (static)
  static final Map<String, Future<String>> _userNameCache = {};

  Future<String> _fetchName(String uid) {
    if (uid.trim().isEmpty || uid == '-') {
      return Future.value('Tidak diketahui');
    }

    return _userNameCache.putIfAbsent(uid, () async {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (!snap.exists) return 'Tidak diketahui';

        final data = snap.data() as Map<String, dynamic>;
        final name =
            (data['username'] ??
                    data['nama'] ??
                    data['name'] ??
                    data['full_name'] ??
                    data['fullName'] ??
                    data['displayName'] ??
                    data['email'] ??
                    '')
                .toString()
                .trim();

        return name.isEmpty ? 'Tidak diketahui' : name;
      } catch (_) {
        return 'Tidak diketahui';
      }
    });
  }

  num _pickNum(
    Map<String, dynamic> data,
    List<String> keys, {
    num fallback = 0,
  }) {
    for (final k in keys) {
      final v = data[k];
      if (v is int) return v.toDouble();
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = num.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  num _pickOrderTotal(Map<String, dynamic> data) {
    return _pickNum(data, [
      'total',
      'total_price',
      'grand_total',
      'grandTotal',
      'amount',
      'totalAmount',
      'subtotal',
    ], fallback: 0);
  }

  String _formatDate(dynamic ts) {
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }
    return '-';
  }

  Color _statusColor(String s) {
    final v = s.toLowerCase();
    if (v == 'received' || v == 'completed' || v == 'done') return Colors.green;
    if (v == 'paid' || v == 'success') return Colors.blue;
    if (v == 'cancelled' || v == 'failed') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final buyerId = (orderData['buyer_id'] ?? '-').toString();
    final status = (orderData['status'] ?? '-').toString();

    final updatedAt = orderData['updated_at'];
    final receivedAt = orderData['received_at'];

    final color = _statusColor(status);
    final orderTotal = _pickOrderTotal(orderData);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(text: status, color: color),
              const Spacer(),
              Text(
                _formatDate(receivedAt is Timestamp ? receivedAt : updatedAt),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Order ID: $orderId',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),

          // Buyer name
          FutureBuilder<String>(
            future: _fetchName(buyerId),
            builder: (context, snapName) {
              final buyerName = snapName.data ?? 'Memuat...';
              return Text(
                'Buyer: $buyerName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          if (orderTotal > 0)
            Text(
              'Total Order: Rp ${orderTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),

          const SizedBox(height: 12),

          // Items
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .doc(orderId)
                .collection('items')
                .snapshots(),
            builder: (context, snapItems) {
              if (snapItems.hasError) {
                return Text(
                  'Gagal memuat item: ${snapItems.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }
              if (!snapItems.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                );
              }

              final items = snapItems.data!.docs;
              if (items.isEmpty) {
                return const Text(
                  'Tidak ada item dalam order ini.',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return Column(
                children: items.map((d) {
                  final it = d.data();
                  final title = (it['product_title'] ?? it['title'] ?? '-')
                      .toString();
                  final sellerId = (it['seller_id'] ?? '-').toString();

                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_rounded,
                          color: Color(0xFF0E2E72),
                        ),
                        const SizedBox(width: 10),
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
                                ),
                              ),
                              const SizedBox(height: 6),
                              FutureBuilder<String>(
                                future: _fetchName(sellerId),
                                builder: (context, snapSeller) {
                                  final sellerName =
                                      snapSeller.data ?? 'Memuat...';
                                  return Text(
                                    'Seller: $sellerName',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
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
