import 'package:get/get.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    if (index == 2) return;
    currentIndex.value = index;
  }
}
