import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final int price;
  final List<String> imageUrls;
  final String status;
  final String size;
  final String brand;
  final String condition;
  final String color;
  final String style;
  final String material;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.imageUrls,
    required this.status,
    required this.size,
    required this.brand,
    required this.condition,
    required this.color,
    required this.style,
    required this.material,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 🔁 Firestore → Model
  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    return ProductModel(
      id: doc.id, // ✅ SELALU pakai doc.id
      sellerId: data['seller_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['category_id'] ?? '',
      categoryName: data['category_name'] ?? '',
      price: (data['price'] is int)
          ? data['price'] as int
          : int.tryParse('${data['price']}') ?? 0,
      imageUrls:
          (data['image_urls'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      status: data['status'] ?? 'draft',
      size: data['size'] ?? '',
      brand: data['brand'] ?? '',
      condition: data['condition'] ?? '',
      color: data['color'] ?? '',
      style: data['style'] ?? '',
      material: data['material'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
    );
  }

  /// 🔁 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'seller_id': sellerId,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'price': price,
      'image_urls': imageUrls,
      'status': status,
      'size': size,
      'brand': brand,
      'condition': condition,
      'color': color,
      'style': style,
      'material': material,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
