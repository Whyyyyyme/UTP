import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:prelovedly/models/image_model.dart';

class SellPhotoPreviewCard extends StatelessWidget {
  final SellImage image;
  final VoidCallback onRemove;

  const SellPhotoPreviewCard({
    super.key,
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 110,
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildImage(),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    // 1) URL lama (draft)
    if (image.isUrl) {
      final url = image.url ?? '';
      if (url.isEmpty) {
        return const Center(child: Icon(Icons.image_not_supported));
      }
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }

    // 2) Local file baru
    final xfile = image.local;
    if (xfile == null) {
      return const Center(child: Icon(Icons.image_not_supported));
    }

    if (kIsWeb) {
      // ✅ paling stabil di web: render dari bytes
      return FutureBuilder<Uint8List>(
        future: xfile.readAsBytes(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          return Image.memory(
            snap.data!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image)),
          );
        },
      );
    }

    // mobile/desktop
    return Image.file(
      File(xfile.path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image)),
    );
  }
}
