import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingMethodModel {
  final String id;
  final String key;
  final String name;
  final String desc;
  final bool isEnabled;
  final Timestamp? updatedAt;

  ShippingMethodModel({
    required this.id,
    required this.key,
    required this.name,
    required this.desc,
    required this.isEnabled,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'name': name,
      'desc': desc,
      'is_enabled': isEnabled,
      'updated_at': updatedAt,
    };
  }

  factory ShippingMethodModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return ShippingMethodModel(
      id: doc.id,
      key: (d['key'] ?? '').toString(),
      name: (d['name'] ?? '').toString(),
      desc: (d['desc'] ?? '').toString(),
      isEnabled: (d['is_enabled'] == true),
      updatedAt: d['updated_at'] as Timestamp?,
    );
  }
}
