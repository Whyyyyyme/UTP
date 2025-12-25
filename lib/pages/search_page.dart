import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";
  String selectedBrand = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ 1. UPDATE: Tangkap argumen navigasi (misal dari Home)
    // Diharapkan dikirim via: Get.toNamed(Routes.search, arguments: {'query': 'Puma'})
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['query'] != null) {
      setState(() {
        selectedBrand = args['query'];
        searchQuery = "";
      });
    }
  }

  // ✅ Fungsi helper untuk format Rupiah
  String rp(dynamic value) {
    final v = value is int ? value : int.tryParse('$value') ?? 0;
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    return "Rp $buf";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: TextField(
            controller: _searchController,
            textAlignVertical: TextAlignVertical.center,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
                selectedBrand = "";
              });
            },
            decoration: const InputDecoration(
              hintText: 'Cari barang (Puma, Nike...)',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search_outlined, color: Colors.black),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Brands for you",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ['Puma', 'Nike', 'Adidas', 'New Balance', 'Converse']
                  .map((brand) {
                    bool isSelected = selectedBrand == brand;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(brand),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedBrand = selected ? brand : "";
                            searchQuery = "";
                            _searchController.clear();
                          });
                        },
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Belum ada barang di database."),
                  );
                }

                // ✅ 2. UPDATE: Logic Filtering Client-side yang lebih luas
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final brand = (data['brand'] ?? "").toString().toLowerCase();
                  final category = (data['category_name'] ?? "")
                      .toString()
                      .toLowerCase(); // Ambil category_name
                  final desc = (data['description'] ?? "")
                      .toString()
                      .toLowerCase();

                  if (selectedBrand.isNotEmpty) {
                    String filter = selectedBrand.toLowerCase();
                    // Mencocokkan dengan Brand ATAU Kategori
                    return brand == filter || category.contains(filter);
                  }
                  return brand.contains(searchQuery) ||
                      desc.contains(searchQuery) ||
                      category.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("Barang tidak ditemukan."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    final docId = filteredDocs[index].id;
                    return _buildProductItem(data, docId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ... bagian atas tetap sama ...

  Widget _buildProductItem(Map<String, dynamic> data, String id) {
    String brand = data['brand'] ?? "Unknown";
    String price = data['price']?.toString() ?? "0";
    String img = "";
    if (data['image_urls'] != null && (data['image_urls'] as List).isNotEmpty) {
      img = data['image_urls'][0];
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '/product-detail',
          arguments: {
            "id": id, // ✅ Sesuai dengan yang diharapkan ProductDetailController
            "seller_id": data['seller_id'],
          },
        );
      }, // ⬅️ PASTIKAN ADA TANDA KOMA DI SINI
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: img.isNotEmpty
                    ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            brand,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            rp(price), // ✅ Format Rupiah sudah aktif
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            data['condition'] ?? "Kondisi Baik",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
