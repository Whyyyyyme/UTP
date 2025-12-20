import 'package:get/get.dart';
import 'package:prelovedly/data/repository/inbox_repository.dart';
import 'package:prelovedly/models/inbox_thread_model.dart';
import 'package:prelovedly/view_model/session_controller.dart';

class InboxController extends GetxController {
  InboxController(this._repo);

  final InboxRepository _repo;
  final session = SessionController.to;

  Stream<List<InboxThreadModel>> threadsStream({int? limit}) {
    final uid = session.viewerId.value;
    if (uid.isEmpty) return const Stream.empty();
    return _repo.inboxStream(uid, limit: limit);
  }

  String formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}';
  }
}
