import 'package:prelovedly/models/order_model.dart';
import '../services/orders_service.dart';

class OrdersRepository {
  OrdersRepository({OrdersService? service})
    : _service = service ?? OrdersService();

  final OrdersService _service;

  // ===== BOUGHT =====
  Stream<List<OrderModel>> streamBought(String buyerAuthUid) {
    return _service
        .boughtOrdersSnap(buyerAuthUid)
        .map((snap) => snap.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  // ===== SOLD =====
  Stream<List<OrderModel>> streamSold(String sellerAuthUid) {
    return _service
        .soldOrdersSnap(sellerAuthUid)
        .map((snap) => snap.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }
}
