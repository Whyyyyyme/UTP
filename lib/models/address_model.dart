import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String userId;
  final String receiverName;
  final String phone;
  final String regionDetail;
  final Timestamp createdAt;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.userId,
    required this.receiverName,
    required this.phone,
    required this.regionDetail,
    required this.createdAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'receiver_name': receiverName,
      'phone': phone,
      'region_detail': regionDetail,
      'created_at': createdAt,
      'is_default': isDefault,
    };
  }

  factory AddressModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      receiverName: data['receiver_name'] ?? '',
      phone: data['phone'] ?? '',
      regionDetail: data['region_detail'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      isDefault: data['is_default'] ?? false,
    );
  }
}
