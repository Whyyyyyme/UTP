import 'package:get/get.dart';

class SessionController extends GetxController {
  static SessionController get to => Get.find<SessionController>();

  final RxString viewerId = ''.obs;

  void setViewer(String uid) {
    final next = uid.trim();
    if (viewerId.value == next) return; // 🔐 guard
    viewerId.value = next;
  }

  void clear() {
    if (viewerId.value.isEmpty) return;
    viewerId.value = '';
  }
}
