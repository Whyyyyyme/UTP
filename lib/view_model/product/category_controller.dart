import 'package:get/get.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/kategori/category_list_page.dart';

class CategoryController extends GetxController {
  final RxString query = ''.obs;
  final RxList<String> filteredCategories = <String>[].obs;

  // optional: untuk display sementara
  final categoryName = ''.obs;

  final Map<String, Map<String, List<String>>> kCategoryTree = {
    'Wanita': {
      'Footwear': [
        'Sneakers',
        'Boots',
        'Heels',
        'Flats',
        'Sandals & slides',
        'Loafers',
        'Other',
      ],
      'Tops': [
        'T-shirts',
        'Blouse',
        'Shirts',
        'Sweater',
        'Hoodie',
        'Tank top',
        'Other',
      ],
      'Bottoms': ['Jeans', 'Trousers', 'Skirts', 'Shorts', 'Leggings', 'Other'],
      'Outerwear': ['Jacket', 'Coat', 'Blazer', 'Cardigan', 'Other'],
      'Underwear': ['Bra', 'Panties', 'Lingerie set', 'Sleepwear', 'Other'],
    },
    'Pria': {
      'Footwear': [
        'Sneakers',
        'Boots',
        'Chelsea boots',
        'Sandals & slides',
        'Ankle boots',
        'Brogues',
        'Casual shoes',
        'Dress shoes',
        'Loafers',
        'Other',
      ],
      'Tops': [
        'T-shirts',
        'Shirts',
        'Polo shirts',
        'Sweaters',
        'Hoodies',
        'Other',
      ],
      'Bottoms': ['Jeans', 'Chinos', 'Shorts', 'Joggers', 'Trousers', 'Other'],
      'Outerwear': ['Jacket', 'Coat', 'Blazer', 'Cardigan', 'Other'],
      'Underwear': ['Briefs', 'Boxers', 'Singlets', 'Sleepwear', 'Other'],
    },
    'Anak': {
      'Pakaian': [
        'Bayi',
        'Balita',
        'Anak laki-laki',
        'Anak perempuan',
        'Other',
      ],
      'Footwear': ['Sneakers', 'Sandals', 'Boots', 'Other'],
    },
  };

  List<String> get filteredCategoriesList => filteredCategories;

  @override
  void onInit() {
    super.onInit();
    filteredCategories.value = kCategoryTree.keys.toList();
  }

  void onSearchChanged(String searchQuery) {
    query.value = searchQuery.toLowerCase();
    _filterCategories();
  }

  void _filterCategories() {
    if (query.value.isEmpty) {
      filteredCategories.value = kCategoryTree.keys.toList();
    } else {
      filteredCategories.value = kCategoryTree.keys
          .where((category) => category.toLowerCase().contains(query.value))
          .toList();
    }
  }

  Map<String, List<String>> getSubcategories(String gender) {
    return kCategoryTree[gender] ?? {};
  }

  /// Flow 3 tahap:
  /// 1) gender -> 2) section (Tops, Underwear, ...) -> 3) item (T-shirts, ...)
  ///
  /// Return:
  /// {
  ///   "gender": "...",
  ///   "section": "...",
  ///   "item": "...",
  ///   "full": "Gender > Section > Item"
  /// }
  Future<Map<String, String>?> pickCategory3Level() async {
    // STEP 1: pilih gender
    final gender = await Get.to<String?>(
      () => CategoryListPage(
        // kalau CategoryListPage kamu cuma punya `options`, ini aman
        options: kCategoryTree.keys.toList(),
        // title: 'Pilih gender', // kalau kamu punya param title
      ),
    );
    if (gender == null) return null;

    categoryName.value = gender;

    final sectionsMap = getSubcategories(gender);
    final sections = sectionsMap.keys.toList();
    if (sections.isEmpty) {
      // kalau tidak ada section, anggap gender saja (jarang terjadi)
      return {"gender": gender, "section": "", "item": "", "full": gender};
    }

    // STEP 2: pilih section (Tops/Underwear/...)
    final section = await Get.to<String?>(
      () => CategoryListPage(
        options: sections,
        // title: 'Pilih bagian', // opsional
      ),
    );
    if (section == null) return null;

    // STEP 3: pilih item (T-shirts/Jersey/...)
    final items = sectionsMap[section] ?? <String>[];
    if (items.isEmpty) {
      return {
        "gender": gender,
        "section": section,
        "item": "",
        "full": "$gender > $section",
      };
    }

    final item = await Get.to<String?>(
      () => CategoryListPage(
        options: items,
        // title: 'Pilih kategori', // opsional
      ),
    );
    if (item == null) return null;

    final full = "$gender > $section > $item";
    return {"gender": gender, "section": section, "item": item, "full": full};
  }
}
