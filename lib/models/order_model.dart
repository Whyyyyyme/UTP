// lib/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final List<String> sellerUids;
  final String status;

  final int subtotal;
  final int shippingFee;
  final int total;

  // ✅ fee admin support
  final int adminFeeRatePercent; // contoh: 3
  final Map<String, int> sellerAmounts; // subtotal per seller
  final Map<String, int> adminFeeAmounts; // fee per seller
  final Map<String, int> sellerNetAmounts; // net per seller
  final int adminFeeTotal;

  // withdraw
  final bool isWithdrawn;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerUids,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    this.adminFeeRatePercent = 0,
    this.sellerAmounts = const {},
    this.adminFeeAmounts = const {},
    this.sellerNetAmounts = const {},
    this.adminFeeTotal = 0,
    this.isWithdrawn = false,
    this.createdAt,
    this.updatedAt,
  });

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  /// admin_fee_rate bisa disimpan sebagai:
  /// - 3 (int) -> 3%
  /// - 0.03 (double/num/string) -> 3%
  static int _toRatePercent(dynamic v) {
    if (v == null) return 0;

    if (v is int) return v;

    if (v is double) {
      // kalau 0.03 -> 3
      if (v > 0 && v < 1) return (v * 100).round();
      return v.round();
    }

    if (v is num) {
      final d = v.toDouble();
      if (d > 0 && d < 1) return (d * 100).round();
      return d.round();
    }

    final s = v.toString().trim();
    final asInt = int.tryParse(s);
    if (asInt != null) return asInt;

    final asDouble = double.tryParse(s);
    if (asDouble != null) {
      if (asDouble > 0 && asDouble < 1) return (asDouble * 100).round();
      return asDouble.round();
    }

    return 0;
  }

  static Map<String, int> _toIntMap(dynamic v) {
    if (v is Map) {
      final out = <String, int>{};
      v.forEach((k, val) => out[k.toString()] = _toInt(val));
      return out;
    }
    return {};
  }

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};

    final sellers = (d['seller_uids'] is List)
        ? (d['seller_uids'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final subtotal = _toInt(d['subtotal']);
    final shippingFee = _toInt(d['shipping_fee']);
    final total = _toInt(d['total']);

    // ===== fee fields (bisa kosong di order lama) =====
    int ratePercent = _toRatePercent(d['admin_fee_rate']);
    // default: kalau belum ada, anggap 3%
    if (ratePercent <= 0) ratePercent = 3;

    final parsedSellerAmounts = _toIntMap(d['seller_amounts']);
    final parsedAdminFeeAmounts = _toIntMap(d['admin_fee_amounts']);
    final parsedSellerNetAmounts = _toIntMap(d['seller_net_amounts']);
    final parsedAdminFeeTotal = _toInt(d['admin_fee_total']);

    // ===== AUTO FALLBACK (ORDER LAMA) =====
    // Kalau maps fee belum ada, kita bikin otomatis supaya:
    // - wallet seller bisa tampil net (potong 3%)
    // - admin income bisa kebaca (admin_fee_total)
    Map<String, int> sellerAmounts = parsedSellerAmounts;
    Map<String, int> adminFeeAmounts = parsedAdminFeeAmounts;
    Map<String, int> sellerNetAmounts = parsedSellerNetAmounts;
    int adminFeeTotal = parsedAdminFeeTotal;

    final hasAnyFeeData =
        parsedAdminFeeTotal > 0 ||
        parsedAdminFeeAmounts.isNotEmpty ||
        parsedSellerNetAmounts.isNotEmpty;

    if (!hasAnyFeeData && sellers.isNotEmpty) {
      // Saat ini app kamu mayoritas 1 order = 1 seller (dari cart item).
      // Jadi fallback paling aman: anggap subtotal milik seller pertama.
      final sellerUid = sellers.first;

      final sellerGross = subtotal;
      final fee = (sellerGross * ratePercent) ~/ 100; // floor
      final net = sellerGross - fee;

      sellerAmounts = {sellerUid: sellerGross};
      adminFeeAmounts = {sellerUid: fee};
      sellerNetAmounts = {sellerUid: net};
      adminFeeTotal = fee;
    }

    return OrderModel(
      id: (d['order_id'] ?? doc.id).toString(),
      buyerId: (d['buyer_id'] ?? '').toString(),
      sellerUids: sellers,
      status: (d['status'] ?? '').toString(),
      subtotal: subtotal,
      shippingFee: shippingFee,
      total: total,
      adminFeeRatePercent: ratePercent,
      sellerAmounts: sellerAmounts,
      adminFeeAmounts: adminFeeAmounts,
      sellerNetAmounts: sellerNetAmounts,
      adminFeeTotal: adminFeeTotal,
      isWithdrawn: (d['is_withdrawn'] ?? false) == true,
      createdAt: d['created_at'] as Timestamp?,
      updatedAt: d['updated_at'] as Timestamp?,
    );
  }

  // ✅ helper untuk wallet seller
  int netForSeller(String sellerUid) {
    // kalau data baru: ambil net map
    final net = sellerNetAmounts[sellerUid];
    if (net != null) return net;

    // fallback data lama:
    // kalau ternyata ada seller_amounts tapi belum ada net map → hitung manual
    final gross = sellerAmounts[sellerUid];
    if (gross != null && adminFeeRatePercent > 0) {
      final fee = (gross * adminFeeRatePercent) ~/ 100;
      return gross - fee;
    }

    // fallback terakhir: anggap net = subtotal (single seller)
    return subtotal;
  }

  OrderModel copyWith({String? status}) {
    return OrderModel(
      id: id,
      buyerId: buyerId,
      sellerUids: sellerUids,
      status: status ?? this.status,
      subtotal: subtotal,
      shippingFee: shippingFee,
      total: total,
      adminFeeRatePercent: adminFeeRatePercent,
      sellerAmounts: sellerAmounts,
      adminFeeAmounts: adminFeeAmounts,
      sellerNetAmounts: sellerNetAmounts,
      adminFeeTotal: adminFeeTotal,
      isWithdrawn: isWithdrawn,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
