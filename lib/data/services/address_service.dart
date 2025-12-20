import 'package:cloud_firestore/cloud_firestore.dart';

class AddressService {
  AddressService(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> userAddressCol(String userId) {
    return _db.collection('users').doc(userId).collection('addresses');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAddresses(String userId) {
    return userAddressCol(
      userId,
    ).orderBy('created_at', descending: false).snapshots();
  }

  Future<bool> hasAnyAddress(String userId) async {
    final snap = await userAddressCol(userId).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  Future<void> saveAddress(
    String userId,
    String addressId,
    Map<String, dynamic> data,
  ) {
    return userAddressCol(userId).doc(addressId).set(data);
  }

  Future<void> deleteAddress(String userId, String addressId) {
    return userAddressCol(userId).doc(addressId).delete();
  }

  String newAddressId(String userId) {
    return userAddressCol(userId).doc().id;
  }
}
