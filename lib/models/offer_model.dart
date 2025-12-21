class OfferModel {
  final String buyerId;
  final String sellerId;

  final int originalPrice;
  final int offerPrice;

  final String status; // pending/accepted/rejected

  const OfferModel({
    required this.buyerId,
    required this.sellerId,
    required this.originalPrice,
    required this.offerPrice,
    required this.status,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    return OfferModel(
      buyerId: (map['buyerId'] ?? '').toString(),
      sellerId: (map['sellerId'] ?? '').toString(),
      originalPrice: _toInt(map['originalPrice']),
      offerPrice: _toInt(map['offerPrice']),
      status: (map['status'] ?? 'pending').toString().toLowerCase().trim(),
    );
  }

  Map<String, dynamic> toMap() => {
    'buyerId': buyerId,
    'sellerId': sellerId,
    'originalPrice': originalPrice,
    'offerPrice': offerPrice,
    'status': status,
  };
}
