import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SellPhotoPreviewCard extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const SellPhotoPreviewCard({
    super.key,
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final String path = file.path;

    final ImageProvider provider = kIsWeb
        ? NetworkImage(
            path,
          ) // catatan: web kadang perlu bytes, tapi ini ikut struktur kamu dulu
        : FileImage(File(path));

    return Stack(
      children: [
        Container(
          width: 110,
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
            image: DecorationImage(image: provider, fit: BoxFit.cover),
          ),
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
}
