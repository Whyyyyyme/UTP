/// 1 room untuk 1 pasangan user (buyer-seller), tidak tergantung produk.
String buildThreadId({
  required String uidA,
  required String uidB,
  String? productId, // tetap ada biar tidak merusak pemanggil lama
}) {
  final a = uidA.trim();
  final b = uidB.trim();
  final sorted = [a, b]..sort();
  return 'dm_${sorted[0]}_${sorted[1]}';
}

/// Opsional: kalau suatu saat kamu mau thread per produk lagi,
/// pakai fungsi ini (jangan dipakai sekarang).
String buildThreadIdPerProduct({
  required String uidA,
  required String uidB,
  required String productId,
}) {
  final a = uidA.trim();
  final b = uidB.trim();
  final sorted = [a, b]..sort();
  final p = productId.trim().isEmpty ? 'general' : productId.trim();
  return '${p}_${sorted[0]}_${sorted[1]}';
}
