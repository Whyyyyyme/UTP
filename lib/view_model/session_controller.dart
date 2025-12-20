import 'package:get/get.dart';

class SessionController extends GetxController {
  static SessionController get to => Get.find<SessionController>();

  final viewerId = ''.obs;

  void setViewer(String uid) {
    viewerId.value = uid;
  }

  void clear() {
    viewerId.value = '';
  }
}
