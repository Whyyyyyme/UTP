import 'package:get/get.dart';
import 'package:prelovedly/controller/sell_controller.dart';
import 'package:prelovedly/controller/product/category_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellController>(() => SellController(), fenix: true);
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
  }
}
