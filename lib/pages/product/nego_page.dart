import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/nego_controller.dart';

class NegoPage extends StatelessWidget {
  const NegoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NegoController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nego', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // product header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade200,
                    child: c.imageUrl.isEmpty
                        ? const Icon(Icons.image)
                        : Image.network(
                            c.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title.isEmpty ? 'Produk' : c.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${_rp(c.originalPrice)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            const Text(
              'Harga kamu',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // input harga
            TextField(
              controller: c.priceC,
              keyboardType: TextInputType.number,
              inputFormatters: [RupiahInputFormatter()], // ✅ angka + titik
              onChanged: (_) => c.validate(),
              decoration: InputDecoration(
                prefixText: 'Rp  ',
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                hintText: _rp(c.originalPrice),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade500),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Obx(() {
              final err = c.errorText.value;
              if (err.isEmpty) {
                return Text(
                  'Harga ini belum termasuk ongkir',
                  style: TextStyle(color: Colors.grey.shade600),
                );
              }
              return Text(err, style: const TextStyle(color: Colors.red));
            }),

            const Spacer(),

            // button
            Obx(() {
              final loading = c.isLoading.value;
              final enabled = c.canSendRx.value;

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: enabled ? c.send : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.black.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Kirim nego',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _rp(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return buf.toString();
  }
}
