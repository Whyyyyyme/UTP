import 'package:intl/intl.dart';

String rupiah(num v) {
  final f = NumberFormat('#,##0', 'id_ID');
  return 'Rp ${f.format(v).replaceAll(',', '.')}';
}
