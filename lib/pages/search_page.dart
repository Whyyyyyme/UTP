import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prelovedly/view_model/main_nav_controller.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import 'package:prelovedly/view_model/like_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/homepage_widget.dart'; // Pastikan HotItemCard ada di sini

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";
  String selectedBrand = "";
  final TextEditingController _searchController = TextEditingController();

  static const double _safeLeft = 72;

  // Fungsi pemformat Rupiah
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

  void _onSearchSubmit() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      selectedBrand = "";
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller agar tidak error saat dipanggil di body
    final likeC = Get.find<LikeController>();
    final session = SessionController.to;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                actions: [const SizedBox(width: 16)], 
                title: Padding(
                  padding: const EdgeInsets.only(left: _safeLeft, right: 0), 
                  child: Hero(
                    tag: 'search_bar_anim',
                    child: Material(
                      type: MaterialType.transparency,
                      child: _buildSearchBar(),
                    ),
                  ),
                ),
              ),
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                elevation: 0,
                backgroundColor: Colors.white,
                toolbarHeight: 90,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text("Brands for you", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      _buildBrandList(),
                    ],
                  ),
                ),
              ),
            ];
          },
          // Masukkan controller ke dalam fungsi grid
          body: _buildProductGrid(likeC, session),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14),
        onSubmitted: (value) => _onSearchSubmit(),
        decoration: InputDecoration(
          hintText: 'Cari items...',
          prefixIcon: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Get.find<MainNavController>().changeTab(0),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildBrandList() {
    final List<String> brands = ['Puma', 'Nike', 'Adidas', 'New Balance', 'Zara', 'H&M', 'Uniqlo', 'Levis', 'Gucci', 'Prada'];
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: brands.map((brand) {
          bool isSelected = selectedBrand == brand;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(brand),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedBrand = selected ? brand : "";
                  searchQuery = selected ? brand.toLowerCase() : "";
                  _searchController.clear();
                });
              },
              selectedColor: Colors.black,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(LikeController likeC, SessionController session) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada barang di database."));
        }

        final docs = snapshot.data!.docs;
        var filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] ?? '').toString().toLowerCase();
          if (status == 'draft' || status == 'sold' || status == 'terjual') return false;

          final title = (data['title'] ?? "").toString().toLowerCase();
          final brand = (data['brand'] ?? "").toString().toLowerCase();
          
          if (selectedBrand.isNotEmpty) return brand == selectedBrand.toLowerCase();
          return title.contains(searchQuery) || brand.contains(searchQuery);
        }).toList();

        return Obx(() {
          final viewerId = session.viewerId.value;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: filteredDocs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.76,
            ),
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return StreamBuilder<bool>(
                stream: viewerId.isEmpty 
                    ? Stream.value(false) 
                    : likeC.isLikedStream(viewerId: viewerId, productId: doc.id),
                builder: (context, likeSnap) {
                  return HotItemCard(
                    id: doc.id,
                    data: data,
                    isLiked: likeSnap.data ?? false,
                    onTap: () => Get.toNamed(Routes.productDetail, arguments: {
                      "id": doc.id,
                      "seller_id": data['seller_id'],
                    }),
                    onLike: () => likeC.toggleLike(
                      viewerId: viewerId,
                      productId: doc.id,
                      sellerId: data['seller_id'],
                      currentlyLiked: likeSnap.data ?? false,
                    ),
                  );
                },
              );
            },
          );
        });
      },
    );
  }
}