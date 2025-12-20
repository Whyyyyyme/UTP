import 'package:prelovedly/data/services/inbox_service.dart';
import 'package:prelovedly/models/inbox_thread_model.dart';

class InboxRepository {
  InboxRepository(this._service);
  final InboxService _service;

  Stream<List<InboxThreadModel>> inboxStream(String uid, {int? limit}) {
    return _service.inboxStream(uid, limit: limit).map((snap) {
      return snap.docs.map((doc) {
        final raw = doc.data();

        // ✅ amankan offer map
        final offer = (raw['offer'] is Map)
            ? Map<String, dynamic>.from(raw['offer'] as Map)
            : <String, dynamic>{};

        final lastType = (raw['lastType'] ?? 'text').toString();
        final offerStatus = (offer['status'] ?? '').toString();

        // ✅ MVVM rule: teks inbox untuk 3 versi
        var lastMessage = (raw['lastMessage'] ?? '').toString();

        if (lastType == 'offer') {
          if (offerStatus == 'pending') {
            final buyerId = (offer['buyerId'] ?? '').toString();
            lastMessage = buyerId == uid
                ? 'Offer berjalan, tunggu respon'
                : 'Offer baru';
          } else if (offerStatus == 'accepted') {
            lastMessage = 'Offer diterima';
          } else if (offerStatus == 'rejected') {
            lastMessage = 'Offer ditolak';
          }
        }

        // ✅ patch map biar model tinggal baca bersih
        final patched = Map<String, dynamic>.from(raw);
        patched['offer'] = offer;
        patched['lastMessage'] = lastMessage;

        return InboxThreadModel.fromMap(doc.id, patched);
      }).toList();
    });
  }
}
