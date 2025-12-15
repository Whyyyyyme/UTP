import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/controller/home_controller.dart';

class WelcomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const WelcomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 185,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }
}

class SellerCard extends StatelessWidget {
  final String sellerId;
  final VoidCallback? onTap;

  const SellerCard({super.key, required this.sellerId, this.onTap});

  static const double _w = 220;
  static const double _collageH = 120;
  static const double _avatarR = 22;
  static const double _gapAfterStack = 8;
  static const double _nameH = 20;
  static const double _gapNameStars = 6;
  static const double _starsH = 20;

  // total tinggi card (aman anti overflow)
  static const double cardHeight =
      (_collageH + (_avatarR * 2) / 2) + // ruang avatar overlap (setengah)
      _gapAfterStack +
      _nameH +
      _gapNameStars +
      _starsH +
      6; // padding cadangan

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();

    return SizedBox(
      width: _w,
      height: cardHeight, // ✅ FIX: kunci tinggi card
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: c.fetchUser(sellerId),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return _skeleton();
            }
            if (userSnap.hasError) {
              return _error('User error: ${userSnap.error}');
            }

            final user = userSnap.data ?? {};
            final username = (user['username'] ?? 'seller').toString();
            final fotoProfilUrl = (user['foto_profil_url'] ?? '').toString();

            final dynamic ratingRaw = user['rating'];
            final double rating = ratingRaw is num
                ? ratingRaw.toDouble()
                : double.tryParse('$ratingRaw') ?? 5.0;

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: c.sellerThumbsStream(sellerId),
              builder: (context, prodSnap) {
                if (prodSnap.connectionState == ConnectionState.waiting) {
                  return _skeleton(username: username);
                }
                if (prodSnap.hasError) {
                  return _error('Produk seller error: ${prodSnap.error}');
                }

                final thumbs = prodSnap.data ?? [];
                final img1 = thumbs.isNotEmpty ? firstImageUrl(thumbs[0]) : '';
                final img2 = thumbs.length > 1 ? firstImageUrl(thumbs[1]) : '';
                final img3 = thumbs.length > 2 ? firstImageUrl(thumbs[2]) : '';

                // ✅ avatar overlap setengah keluar dari collage (mirip contoh)
                final double avatarOverlap = _avatarR;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: _collageH + avatarOverlap,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: SizedBox(
                                height: _collageH,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(child: _imgTile(img1)),
                                          const SizedBox(height: 4),
                                          Expanded(child: _imgTile(img2)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(child: _imgTile(img3)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ✅ avatar turun setengah (tidak akan overflow karena sudah disediakan ruangnya)
                          Positioned(
                            bottom: 0,
                            child: _avatar(username, fotoProfilUrl),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: _gapAfterStack),

                    SizedBox(
                      height: _nameH,
                      child: Center(
                        child: Text(
                          username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: _gapNameStars),

                    SizedBox(
                      height: _starsH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          return Icon(
                            i < rating.round().clamp(0, 5)
                                ? Icons.star
                                : Icons.star_border,
                            size: 18,
                            color: Colors.blue,
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _avatar(String username, String fotoProfilUrl) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.12)),
        ],
      ),
      child: CircleAvatar(
        radius: _avatarR,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: fotoProfilUrl.isNotEmpty
            ? NetworkImage(fotoProfilUrl)
            : null,
        child: fotoProfilUrl.isEmpty
            ? Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'S',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              )
            : null,
      ),
    );
  }

  Widget _imgTile(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.grey.shade200,
        child: url.isEmpty
            ? const Center(child: Icon(Icons.image, size: 18))
            : Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 18),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _skeleton({String? username}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(height: _collageH, color: Colors.grey.shade200),
        ),
        const SizedBox(height: 30),
        Text(
          username ?? 'seller',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _error(String msg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        msg,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}

class HotItemCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const HotItemCard({
    super.key,
    required this.id,
    required this.data,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final img = firstImageUrl(data);

    final dynamic priceRaw = data['price'];
    final int price = priceRaw is int
        ? priceRaw
        : int.tryParse('$priceRaw') ?? 0;

    final brand = (data['brand'] ?? '').toString();
    final size = (data['size'] ?? '').toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: img.isEmpty
                      ? const Center(child: Icon(Icons.image))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            img,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: InkWell(
                    onTap: onLike,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(_rp(price), style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            brand,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          Text(
            size,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  String _rp(int value) => 'Rp $value';
}

String firstImageUrl(Map<String, dynamic> data) {
  final thumb = (data['thumbnail_url'] ?? '').toString();
  if (thumb.isNotEmpty) return thumb;

  final single = (data['image_url'] ?? '').toString();
  if (single.isNotEmpty) return single;

  final list =
      (data['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
  return list.isNotEmpty ? list.first : '';
}
