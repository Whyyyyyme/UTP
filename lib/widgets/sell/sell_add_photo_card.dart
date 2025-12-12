import 'package:flutter/material.dart';

class SellAddPhotoCard extends StatelessWidget {
  final VoidCallback onTap;
  const SellAddPhotoCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        child: const Text("+ Tambah foto"),
      ),
    );
  }
}
