class OrderItemPreview {
  final String title;
  final String imageUrl;

  OrderItemPreview({required this.title, required this.imageUrl});

  factory OrderItemPreview.fromMap(Map<String, dynamic> d) {
    return OrderItemPreview(
      title: (d['title'] ?? '').toString(),
      imageUrl: (d['image_url'] ?? '').toString(),
    );
  }
}
