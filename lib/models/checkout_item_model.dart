class CheckoutItemModel {
  final String productId;
  final String sellerId;
  final String sellerUid;

  final String title;
  final String size;
  final String imageUrl;

  final int priceFinal;
  final int priceOriginal;
  final String offerStatus;
  final int offerPrice;
  final bool promoShippingActive;
  final int promoShippingAmount;

  CheckoutItemModel({
    required this.productId,
    required this.sellerId,
    required this.sellerUid,
    required this.title,
    required this.size,
    required this.imageUrl,
    required this.priceFinal,
    required this.priceOriginal,
    required this.offerStatus,
    required this.offerPrice,
    required this.promoShippingActive,
    required this.promoShippingAmount,
  });

  factory CheckoutItemModel.fromMap(Map<String, dynamic> d, String docId) {
    int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    final offerStatus = (d['offer_status'] ?? '')
        .toString()
        .toLowerCase()
        .trim();
    final offerPrice = _toInt(d['offer_price']);

    final priceDb = _toInt(d['price']);
    final priceOriginal = _toInt(d['price_original']);

    final priceFinal = (offerStatus == 'accepted' && offerPrice > 0)
        ? offerPrice
        : priceDb;

    final thumb = (d['thumbnail_url'] ?? '').toString();
    final imgUrl = (d['image_url'] ?? '').toString();
    final urls = (d['image_urls'] is List)
        ? (d['image_urls'] as List).map((e) => '$e').toList()
        : <String>[];

    final image = imgUrl.isNotEmpty
        ? imgUrl
        : (thumb.isNotEmpty ? thumb : (urls.isNotEmpty ? urls.first : ''));
    final promoActive = (d['promo_shipping_active'] ?? false) == true;
    final promoAmount = _toInt(d['promo_shipping_amount']);

    return CheckoutItemModel(
      productId: (d['product_id'] ?? docId).toString(),
      sellerId: (d['seller_id'] ?? '').toString(),
      sellerUid: (d['seller_uid'] ?? '').toString(),
      title: (d['title'] ?? '').toString(),
      size: (d['size'] ?? '').toString(),
      imageUrl: image,
      priceFinal: priceFinal,
      priceOriginal: priceOriginal > 0 ? priceOriginal : priceFinal,
      offerStatus: offerStatus,
      offerPrice: offerPrice,
      promoShippingActive: promoActive,
      promoShippingAmount: promoAmount,
    );
  }
}
