String buildThreadId({
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
