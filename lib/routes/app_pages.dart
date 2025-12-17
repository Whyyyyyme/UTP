import 'package:get/get.dart';
import 'package:prelovedly/bindings/app_binding.dart';
import 'package:prelovedly/controller/manage_product_controller.dart';
import 'package:prelovedly/pages/cart/cart_page.dart';
import 'package:prelovedly/pages/product/product_detail_page.dart';
import 'package:prelovedly/pages/profile_pages/address/address_list_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_product_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile_page.dart';
import 'package:prelovedly/pages/profile_pages/manage_product_page.dart';
import 'package:prelovedly/pages/profile_pages/setting_page.dart';
import 'package:prelovedly/pages/profile_pages/shop_profile_screen.dart';
import 'package:prelovedly/pages/profile_pages/address/add_address_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/brand_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/color_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/condition_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/kategori/category_list_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/material_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/price_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/size_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/edit_draft_page.dart';
import 'package:prelovedly/pages/sell_pages/sell_page.dart';
import 'package:prelovedly/pages/sell_pages/style_picker_page.dart';

import 'app_routes.dart';
import 'package:prelovedly/pages/login_page.dart';
import 'package:prelovedly/pages/home_page.dart';
import 'package:prelovedly/pages/profile_page.dart';

import 'package:prelovedly/pages/Register_pages/register_email.dart';
import 'package:prelovedly/pages/Register_pages/register_nama.dart';
import 'package:prelovedly/pages/Register_pages/register_username.dart';
import 'package:prelovedly/pages/Register_pages/register_password.dart';

import 'package:prelovedly/pages/admin_pages/admin_dashboard_page.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = <GetPage>[
    // Login & Register
    GetPage(name: Routes.login, page: () => LoginPage()),
    GetPage(name: Routes.adminDashboard, page: () => const AdminDashboardPage()),
    GetPage(name: Routes.registerEmail, page: () => const EmailRegisterPage()),
    GetPage(
      name: Routes.registerName,
      page: () => const NameRegisterPage(email: ''),
    ),
    GetPage(
      name: Routes.registerUsername,
      page: () => const UsernameRegisterPage(email: '', fullName: ''),
    ),
    GetPage(
      name: Routes.registerPassword,
      page: () =>
          const PasswordRegisterPage(email: '', fullName: '', username: ''),
    ),

    // Main Page
    GetPage(name: Routes.home, page: () => const HomePage()),
    GetPage(name: Routes.profile, page: () => const ProfilePage()),

    // Profile
    GetPage(name: Routes.shopProfile, page: () => ShopProfileScreen()),
    GetPage(name: Routes.settings, page: () => const SettingsPage()),
    GetPage(name: Routes.editProfile, page: () => const EditProfilePage()),
    GetPage(name: Routes.addAddress, page: () => AddAddressPage()),
    GetPage(name: Routes.address, page: () => AddressListPage()),

    // Sell
    GetPage(
      name: Routes.sellProduct,
      page: () => JualPage(),
      binding: AppBinding(),
    ),
    GetPage(
      name: Routes.editDraft,
      page: () => EditDraftPage(),
      binding: AppBinding(),
    ),
    GetPage(
      name: Routes.category,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final options = (args['options'] as List).cast<String>();
        final title = (args['title'] as String?) ?? 'Pilih Kategori';
        return CategoryListPage(options: options, title: title);
      },
    ),
    GetPage(name: Routes.size, page: () => SizePickerPage()),
    GetPage(name: Routes.brand, page: () => BrandPickerPage()),
    GetPage(name: Routes.color, page: () => ColorPickerPage()),
    GetPage(name: Routes.condition, page: () => ConditionPickerPage()),
    GetPage(name: Routes.style, page: () => StylePickerPage()),
    GetPage(name: Routes.material, page: () => MaterialPickerPage()),
    GetPage(name: Routes.price, page: () => PricePage()),

    // Product
    GetPage(
      name: Routes.manageProduct,
      page: () => const ManageProductPage(),
      binding: BindingsBuilder(() {
        Get.put(ManageProductController());
      }),
    ),
    GetPage(name: Routes.editProduct, page: () => EditProductPage()),
  ];
}
