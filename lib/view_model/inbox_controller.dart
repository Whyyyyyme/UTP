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

    return _repo.inboxStream(uid, limit: limit).map((list) {
      // ✅ dedupe berdasarkan peerId (1 buyer/seller = 1 thread tampil)
      final byPeer = <String, InboxThreadModel>{};

      for (final t in list) {
        final peer = t.peerId.trim();
        if (peer.isEmpty) continue;

        final prev = byPeer[peer];
        if (prev == null) {
          byPeer[peer] = t;
          continue;
        }

        final prevTime = prev.lastTime;
        final curTime = t.lastTime;

        // kalau salah satu null → pilih yg ada waktunya
        if (prevTime == null && curTime != null) {
          byPeer[peer] = t;
          continue;
        }
        if (prevTime != null && curTime == null) {
          continue;
        }

        // dua-duanya ada → pilih yang paling baru
        if (prevTime != null && curTime != null && curTime.isAfter(prevTime)) {
          byPeer[peer] = t;
        }
      }

      // ✅ sort terbaru di atas
      final out = byPeer.values.toList()
        ..sort((a, b) {
          final ta = a.lastTime;
          final tb = b.lastTime;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

      // ✅ limit diterapkan setelah dedupe
      if (limit != null && limit > 0 && out.length > limit) {
        return out.take(limit).toList();
      }

      return out;
    });
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
