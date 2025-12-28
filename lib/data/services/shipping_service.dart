import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingService {
  ShippingService(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> shippingCol(String sellerId) {
    if (sellerId.trim().isEmpty) {
      throw Exception('sellerId kosong (shippingCol)');
    }
    return _db.collection('users').doc(sellerId).collection('shipping_methods');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAll(String sellerId) {
    return shippingCol(sellerId).orderBy('name').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamEnabled(String sellerId) {
    return shippingCol(
      sellerId,
    ).where('is_enabled', isEqualTo: true).snapshots();
  }

  Future<void> setMethod({
    required String sellerId,
    required String methodId,
    required Map<String, dynamic> data,
  }) {
    return shippingCol(
      sellerId,
    ).doc(methodId).set(data, SetOptions(merge: true));
  }

  Future<void> toggleEnabled({
    required String sellerId,
    required String methodId,
    required bool enabled,
  }) {
    return shippingCol(sellerId).doc(methodId).set({
      'is_enabled': enabled,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> seedDefaultIfEmpty(String sellerId) async {
    final col = shippingCol(sellerId);
    final now = FieldValue.serverTimestamp();

    final defaults = [
      {
        'id': 'grab',
        'key': 'grab',
        'name': 'Grab',
        'desc': 'Hanya pick up kurir',
        'is_enabled': true,
        'fee': 30000,
        'eta': '4-5 hari',
      },
      {
        'id': 'gojek',
        'key': 'gojek',
        'name': 'Gojek',
        'desc': 'Hanya pick up kurir',
        'is_enabled': true,
        'fee': 35000,
        'eta': '5-6 hari',
      },
      {
        'id': 'jne',
        'key': 'jne',
        'name': 'JNE',
        'desc': 'Hanya pick up kurir',
        'is_enabled': true,
        'fee': 100000,
        'eta': '2-3 hari',
      },
      {
        'id': 'anteraja',
        'key': 'anteraja',
        'name': 'AnterAja',
        'desc': 'Pick up kurir dan drop off di gerai terdekat',
        'is_enabled': true,
        'fee': 96000,
        'eta': '3-4 hari',
      },
      {
        'id': 'jnt',
        'key': 'jnt',
        'name': 'J&T',
        'desc': 'Pick up kurir dan drop off di gerai terdekat',
        'is_enabled': true,
        'fee': 120000,
        'eta': '1-2 hari',
      },
      {
        'id': 'sicepat',
        'key': 'sicepat',
        'name': 'SiCepat',
        'desc': 'Pick up kurir dan drop off di gerai terdekat',
        'is_enabled': true,
        'fee': 50000,
        'eta': '3-4 hari',
      },
      {
        'id': 'lionparcel',
        'key': 'lionparcel',
        'name': 'Lion Parcel',
        'desc': 'Pick up kurir dan drop off di gerai terdekat',
        'is_enabled': true,
        'fee': 130000,
        'eta': 'Next Day',
      },
    ];

    // ambil semua dokumen yang sudah ada
    final allSnap = await col.get();

    // ========= CASE 1: kosong -> seed normal =========
    if (allSnap.docs.isEmpty) {
      final batch = _db.batch();
      for (final m in defaults) {
        batch.set(col.doc(m['id'] as String), {
          'key': m['key'],
          'name': m['name'],
          'desc': m['desc'],
          'is_enabled': m['is_enabled'],
          'fee': m['fee'],
          'eta': m['eta'],
          'updated_at': now,
        }, SetOptions(merge: true));
      }
      await batch.commit();
      return;
    }

    // ========= CASE 2: sudah ada -> BACKFILL fee/eta =========
    final defById = <String, Map<String, dynamic>>{
      for (final m in defaults) (m['id'] as String): m,
    };
    final defByKey = <String, Map<String, dynamic>>{
      for (final m in defaults) (m['key'] as String): m,
    };

    final batch = _db.batch();
    var updates = 0;

    for (final doc in allSnap.docs) {
      final d = doc.data();
      final hasFee = d.containsKey('fee');
      final hasEta = d.containsKey('eta');

      if (hasFee && hasEta) continue;

      final key = (d['key'] ?? '').toString();
      final def = defById[doc.id] ?? defByKey[key];
      if (def == null) continue;

      batch.set(doc.reference, {
        if (!hasFee) 'fee': def['fee'],
        if (!hasEta) 'eta': def['eta'],
        'updated_at': now,
      }, SetOptions(merge: true));
      updates++;
    }

    if (updates > 0) {
      await batch.commit();
    }
  }
}
