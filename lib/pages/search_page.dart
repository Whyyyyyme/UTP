import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:prelovedly/view_model/main_nav_controller.dart';
import 'package:prelovedly/view_model/session_controller.dart';
import 'package:prelovedly/view_model/like_controller.dart';
import 'package:prelovedly/routes/app_routes.dart';
import 'package:prelovedly/widgets/homepage_widget.dart';
import 'package:prelovedly/widgets/profile/likes_tab.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";
  String selectedBrand = "";
  bool isShowingLikesTab = false;
  final TextEditingController _searchController = TextEditingController();

  static const double _safeLeft = 72;

  void _updateSearch(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
      _searchController.text = value;
      selectedBrand = "";
      isShowingLikesTab = false;
    });
  }

  void _onSearchSubmit() {
    _updateSearch(_searchController.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
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
                title: Padding(
                  padding: const EdgeInsets.only(left: _safeLeft, right: 12),
                  child: Hero(
                    tag: 'search_bar_anim',
                    child: Material(
                      type: MaterialType.transparency,
                      child: _buildSearchBar(),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: isShowingLikesTab
              ? _buildLikesTabContainer(session.viewerId.value, likeC)
              : _buildMainContent(likeC, session),
        ),
      ),
    );
  }

  // --- TAMPILAN UTAMA ---
  Widget _buildMainContent(LikeController likeC, SessionController session) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildSimpleTile(
            Icons.auto_awesome_outlined,
            "Explore item terbaru",
            onTap: () => _updateSearch(""),
          ),
          _buildSimpleTile(
            Icons.favorite_border,
            "Lihat item favoritmu",
            onTap: () {
              setState(() => isShowingLikesTab = true);
            },
          ),

          const SizedBox(height: 24),
          _buildSectionTitle("Trending"),
          _buildTrendingChips(),

          const SizedBox(height: 24),
          _buildSectionTitle("Kategori"),
          _buildCategoryGrid(),

          const SizedBox(height: 24),
          _buildSectionTitle("Brands for you", showArrow: true),
          _buildBrandFromProducts(), // ✅ Brand dinamis dari koleksi products

          const SizedBox(height: 24),
          if (searchQuery.isNotEmpty || selectedBrand.isNotEmpty)
            _buildSectionTitle("Hasil Pencarian"),

          _buildProductGrid(likeC, session),
        ],
      ),
    );
  }

  Widget _buildLikesTabContainer(String viewerId, LikeController likeC) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: const Text(
            "Item Terpopuler (Liked)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => setState(() => isShowingLikesTab = false),
        ),
        Expanded(
          child: LikesTab(viewerId: viewerId, likeC: likeC),
        ),
      ],
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
        textAlignVertical: TextAlignVertical.center,
        onSubmitted: (value) => _onSearchSubmit(),
        decoration: InputDecoration(
          hintText: 'Cari disini yuk!!!...',
          prefixIcon: const Icon(Icons.search, color: Colors.black, size: 20),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  // --- LOGIKA BRAND DINAMIS DARI PRODUCTS ---
  Widget _buildBrandFromProducts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading brands");
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SizedBox();

        final docs = snapshot.data?.docs ?? [];
        final Set<String> brandSet = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final brand = data['brand']?.toString().trim();
          if (brand != null && brand.isNotEmpty) brandSet.add(brand);
        }

        final uniqueBrands = brandSet.toList()..sort();
        if (uniqueBrands.isEmpty) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: uniqueBrands.map((brandName) {
              final isSelected = selectedBrand == brandName;
              return ActionChip(
                key: ValueKey('brand_$brandName'),
                label: Text(brandName),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12,
                ),
                backgroundColor: isSelected
                    ? Colors.black
                    : Colors.grey.shade200,
                onPressed: () {
                  setState(() {
                    selectedBrand = isSelected ? "" : brandName;
                    searchQuery = isSelected ? "" : brandName.toLowerCase();
                    _searchController.text = isSelected ? "" : brandName;
                    isShowingLikesTab = false;
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTrendingChips() {
    final trending = ["Sepatu", "Tas", "Cardigan", "Kaos"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: trending
            .map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  label: Text("$t ↗"),
                  onPressed: () => _updateSearch(t),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

 Widget _buildCategoryGrid() {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.8,
    children: [
      _categoryCard("Wanita", "https://images.unsplash.com/photo-1542272604-787c3835535d?q=80&w=200"),
      _categoryCard("Pria", "https://images.unsplash.com/photo-1490367532201-b9bc1dc483f6?q=80&w=200"),
      // ✅ Diubah menjadi "Anak" saja
      _categoryCard("Anak", "https://images.unsplash.com/photo-1513151233558-d860c5398176?q=80&w=200"),
      // ✅ Menampilkan label "Pria & Wanita" tapi input pencariannya berbeda
      _categoryCard("Pria & Wanita", "https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?q=80&w=200"),
    ],
  );
}

Widget _categoryCard(String title, String imageUrl) {
  return InkWell(
    onTap: () {
      // ✅ Logika khusus: Jika pilih Pria & Wanita, kita kirim keyword gabungan
      if (title == "Pria & Wanita") {
        _updateSearch("Pria Wanita"); 
      } else {
        _updateSearch(title);
      }
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      alignment: Alignment.center,
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}

  Widget _buildSimpleTile(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showArrow = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (showArrow) const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  // --- LOGIKA FILTER PRODUK (Perubahan pada bagian category_id) ---
 Widget _buildProductGrid(LikeController likeC, SessionController session) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('products').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox();
      final docs = snapshot.data!.docs;
      
      var filteredDocs = docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? "").toString().toLowerCase();
        final brand = (data['brand'] ?? "").toString().toLowerCase();
        final status = (data['status'] ?? "").toString().toLowerCase();
        final categoryId = (data['category_id'] ?? "").toString().toLowerCase();

        if (status == 'sold' || status == 'draft') return false;

        if (selectedBrand.isNotEmpty) return brand == selectedBrand.toLowerCase();

        if (searchQuery.isNotEmpty) {
          // ✅ Logika "OR": Jika cari "Pria Wanita", maka produk dengan category_id 
          // 'pria' AKAN muncul, dan 'wanita' juga AKAN muncul.
          bool matchCategory = false;
          List<String> keywords = searchQuery.split(" "); // memecah "pria wanita" jadi ["pria", "wanita"]
          
          for (var word in keywords) {
            if (categoryId.contains(word) || title.contains(word) || brand.contains(word)) {
              matchCategory = true;
              break; 
            }
          }
          return matchCategory;
        }
        
        return true; 
      }).take(10).toList();

      return Obx(() {
        final vId = session.viewerId.value;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.76,
          ),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            return StreamBuilder<bool>(
              stream: vId.isEmpty ? Stream.value(false) : likeC.isLikedStream(viewerId: vId, productId: doc.id),
              builder: (context, likeSnap) {
                return HotItemCard(
                  id: doc.id,
                  data: data,
                  isLiked: likeSnap.data ?? false,
                  onTap: () => Get.toNamed(Routes.productDetail, arguments: {"id": doc.id, "seller_id": data['seller_id'], "viewer_id": vId}),
                  onLike: () => likeC.toggleLike(viewerId: vId, productId: doc.id, sellerId: data['seller_id'], currentlyLiked: likeSnap.data ?? false),
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