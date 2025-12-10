import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prelovedly/controller/sell_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class JualPage extends StatelessWidget {
  const JualPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SellController c = Get.put(SellController());

    final priceFormatter = NumberFormat.decimalPattern('id');

    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // ⬇️ LOGIC CLOSE
              // Kalau masih bisa back, pop biasa
              if (Get.key.currentState?.canPop() ?? false) {
                Get.back();
              } else {
                // Kalau tidak ada route sebelumnya,
                // paksa balik ke halaman utama / bottom-nav
                // GANTI Routes.main sesuai nama route utama kamu
                Get.offAllNamed(Routes.home);
              }
            },
          ),
          centerTitle: true,
          title: const Text(
            'Jual',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.content_copy_outlined),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.save_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====== AREA FOTO ======
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: c.images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _AddPhotoCard(onTap: c.pickImage);
                          }

                          final img = c.images[index - 1];
                          return _PhotoPreviewCard(
                            file: img,
                            onRemove: () => c.removeImageAt(index - 1),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Baca tips menjual',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),

                    // ====== JUDUL ======
                    const SizedBox(height: 12),
                    const _Label('Judul'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: c.titleC,
                        decoration: const InputDecoration(
                          hintText: 'cth. Levi\'s 578 baggy jeans hitam',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Divider(height: 1),

                    // ====== DESKRIPSI ======
                    const SizedBox(height: 12),
                    const _Label('Deskripsi'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: c.descC,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'cth. Jarang dipakai, size M, bahan katun adem, '
                              'ada sedikit noda di bagian bawah',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Divider(height: 1),

                    // ====== KATEGORI ======
                    ListTile(
                      title: const Text('Kategori'),
                      trailing: const Icon(Icons.chevron_right),
                      subtitle: Obx(() {
                        final text = c.categoryName.value;
                        return Text(
                          text.isEmpty ? 'Pilih kategori' : text,
                          style: TextStyle(
                            color: text.isEmpty
                                ? Colors.grey[500]
                                : Colors.black,
                          ),
                        );
                      }),
                      onTap: c.pickCategory,
                    ),
                    const Divider(height: 1),

                    // ====== HARGA ======
                    ListTile(
                      title: const Text('Harga'),
                      trailing: const Icon(Icons.chevron_right),
                      subtitle: TextField(
                        controller: c.priceC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan harga',
                          border: InputBorder.none,
                          prefixText: 'Rp ',
                        ),
                        onChanged: (val) {
                          final nums = val.replaceAll(RegExp(r'[^0-9]'), '');
                          if (nums.isEmpty) return;
                          final formatted = priceFormatter.format(
                            int.parse(nums),
                          );
                          c.priceC.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ====== BOTTOM BUTTONS ======
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: c.isSaving.value ? null : () => c.saveDraft(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: c.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save draft',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: c.isSaving.value
                          ? null
                          : () => c.uploadProduct(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: c.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AddPhotoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('+ Tambah foto'),
      ),
    );
  }
}

class _PhotoPreviewCard extends StatelessWidget {
  final dynamic file; // biasanya XFile
  final VoidCallback onRemove;

  const _PhotoPreviewCard({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    // asumsi file adalah XFile / punya .path
    final String path = file.path;

    // pilih ImageProvider sesuai platform
    ImageProvider imageProvider;
    if (kIsWeb) {
      // di web: path biasanya "blob:..." → pakai NetworkImage
      imageProvider = NetworkImage(path);
    } else {
      // di Android/iOS: pakai FileImage
      imageProvider = FileImage(File(path));
    }

    return Stack(
      children: [
        Container(
          width: 110,
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
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
