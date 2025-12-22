import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingService {
  ShippingService(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> shippingCol(String sellerId) {
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
    final snap = await shippingCol(sellerId).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final now = FieldValue.serverTimestamp();

    final defaults = [
      {
        'id': 'grab',
        'key': 'grab',
        'name': 'Grab',
        'desc': 'Hanya pick up kurir',
        'is_enabled': true,
      },
      {
        'id': 'gojek',
        'key': 'gojek',
        'name': 'Gojek',
        'desc': 'Hanya pick up kurir',
        'is_enabled': true,
      },
      {
        'id': 'jne',
        'key': 'jne',
        'name': 'JNE',
        'desc': 'Hanya pick up kurir',
        'is_enabled': true,
      },
      {
        'id': 'tiki',
        'key': 'tiki',
        'name': 'TIKI',
        'desc': 'Hanya pick up kurir',
        'is_enabled': true,
      },
      {
        'id': 'anteraja',
        'key': 'anteraja',
        'name': 'AnterAja',
        'desc': 'Pick up kurir dan drop off di gerai terdekat',
        'is_enabled': true,
      },
      {
        'id': 'jnt',
        'key': 'jnt',
        'name': 'J&T',
        'desc': 'Pick up kurir dan drop off di gerai terdekat',
        'is_enabled': true,
      },
      {
        'id': 'sicepat',
        'key': 'sicepat',
        'name': 'SiCepat',
        'desc': 'Pick up kurir dan drop off di gerai terdekat',
        'is_enabled': true,
      },
      {
        'id': 'lionparcel',
        'key': 'lionparcel',
        'name': 'Lion Parcel',
        'desc': 'Pick up kurir dan drop off di gerai terdekat',
        'is_enabled': true,
      },
    ];

    final batch = _db.batch();
    for (final m in defaults) {
      batch.set(shippingCol(sellerId).doc(m['id'] as String), {
        'key': m['key'],
        'name': m['name'],
        'desc': m['desc'],
        'is_enabled': m['is_enabled'],
        'updated_at': now,
      });
    }
    await batch.commit();
  }
}
