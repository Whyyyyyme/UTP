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
          child: _buildImage(context),
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

  Widget _buildImage(BuildContext context) {
    // 1) URL (draft / existing)
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }

    // 2) Local XFile
    final xfile = image.local;
    if (xfile == null) {
      return const Center(child: Icon(Icons.image_not_supported));
    }

    // WEB: render dari bytes (stabil)
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: xfile.readAsBytes(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          if (!snap.hasData || snap.data == null) {
            return const Center(child: Icon(Icons.broken_image));
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

    // MOBILE/DESKTOP:
    // Tanpa dart:io kita pakai Image.memory juga, jadi aman & konsisten.
    return FutureBuilder<Uint8List>(
      future: xfile.readAsBytes(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (!snap.hasData || snap.data == null) {
          return const Center(child: Icon(Icons.broken_image));
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
}
