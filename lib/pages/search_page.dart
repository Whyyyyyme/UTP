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

  // ===== ruang aman untuk burger (posisi & ukuran MenuBtnRive di EntryPoint) =====
  static const double _burgerLeft = 16;
  static const double _burgerSize = 44;
  static const double _burgerGap = 12;
  static const double _safeLeft =
      _burgerLeft + _burgerSize + _burgerGap; // = 72

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['query'] != null) {
      setState(() {
        selectedBrand = args['query'];
        searchQuery = "";
        _searchController.text = args['query'];
      });
    }
  }

  void _onSearchSubmit() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      selectedBrand = "";
    });
    FocusScope.of(context).unfocus();
  }

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
        titleSpacing: 0,

        // ✅ Searchbar digeser agar tidak tabrakan burger
        title: Padding(
          padding: const EdgeInsets.only(left: _safeLeft, right: 12),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14),
              onSubmitted: (value) => _onSearchSubmit(),
              decoration: InputDecoration(
                hintText: 'Cari items, brand, atau kategori',
                hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                border: InputBorder.none,
                isCollapsed: true,
                prefixIcon: GestureDetector(
                  onTap: _onSearchSubmit,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: const Icon(
                      Icons.search_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 32,
                  maxHeight: 25,
                ),
                contentPadding: const EdgeInsets.only(top: 13),
              ),
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

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map;

                  final status = (data['status'] ?? '')
                      .toString()
                      .toLowerCase();
                  final isDraft =
                      (data['is_draft'] == true) || status == 'draft';
                  final isSold =
                      (data['is_sold'] == true) ||
                      status == 'sold' ||
                      status == 'terjual';

                  if (isDraft || isSold) return false;

                  final title = (data['title'] ?? "").toString().toLowerCase();
                  final brand = (data['brand'] ?? "").toString().toLowerCase();
                  final category = (data['category_name'] ?? "")
                      .toString()
                      .toLowerCase();
                  final description = (data['description'] ?? "")
                      .toString()
                      .toLowerCase();

                  if (selectedBrand.isNotEmpty) {
                    final filter = selectedBrand.toLowerCase();
                    return brand == filter || category.contains(filter);
                  }

                  return title.contains(searchQuery) ||
                      brand.contains(searchQuery) ||
                      description.contains(searchQuery);
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

  Widget _buildProductItem(Map<String, dynamic> data, String id) {
    String productTitle = data['title'] ?? data['brand'] ?? "No Title";
    String price = data['price']?.toString() ?? "0";
    String img = "";
    if (data['image_urls'] != null && (data['image_urls'] as List).isNotEmpty) {
      img = data['image_urls'][0];
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '/product-detail',
          arguments: {"id": id, "seller_id": data['seller_id']},
        );
      },
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
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            productTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            rp(price),
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
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
