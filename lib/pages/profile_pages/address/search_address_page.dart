import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchAddressPage extends StatefulWidget {
  final String initialText;

  const SearchAddressPage({super.key, this.initialText = ''});

  @override
  State<SearchAddressPage> createState() => _SearchAddressPageState();
}

class _SearchAddressPageState extends State<SearchAddressPage> {
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  void _useCurrentText() {
    final text = _searchC.text.trim();
    if (text.isEmpty) return;
    Get.back(result: text);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _searchC.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Cari alamat',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchC,
                      decoration: const InputDecoration(
                        hintText: 'Cari jalan, gedung atau perumahan',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _useCurrentText(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (!hasText) ...[
            const Spacer(),
            const Icon(
              Icons.location_on_rounded,
              size: 80,
              color: Colors.pinkAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Mulai cari alamat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketik nama jalan, gedung, atau area untuk\nmenemukan alamatmu',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const Spacer(),
          ] else ...[
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(_searchC.text.trim()),
                    subtitle: const Text('Gunakan alamat ini'),
                    onTap: _useCurrentText,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
