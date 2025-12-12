import 'package:get/get.dart';
import 'package:prelovedly/pages/profile_pages/address/address_list_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile_page.dart';
import 'package:prelovedly/pages/profile_pages/setting_page.dart';
import 'package:prelovedly/pages/profile_pages/shop_profile_screen.dart';
import 'package:prelovedly/pages/profile_pages/address/add_address_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/kategori/category_list_page.dart';
import 'package:prelovedly/pages/sell_pages/sell_page.dart';

import 'app_routes.dart';
import 'package:prelovedly/pages/login_page.dart';
import 'package:prelovedly/pages/home_page.dart';
import 'package:prelovedly/pages/profile_page.dart';

import 'package:prelovedly/pages/Register_pages/register_email.dart';
import 'package:prelovedly/pages/Register_pages/register_nama.dart';
import 'package:prelovedly/pages/Register_pages/register_username.dart';
import 'package:prelovedly/pages/Register_pages/register_password.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = <GetPage>[
    GetPage(name: Routes.login, page: () => LoginPage()),
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
    GetPage(name: Routes.home, page: () => const HomePage()),
    GetPage(name: Routes.profile, page: () => const ProfilePage()),
    GetPage(name: Routes.ShopProfile, page: () => ShopProfileScreen()),
    GetPage(name: Routes.settings, page: () => const SettingsPage()),
    GetPage(name: Routes.editProfile, page: () => const EditProfilePage()),
    GetPage(name: Routes.addAddress, page: () => AddAddressPage()),
    GetPage(name: Routes.address, page: () => AddressListPage()),
    GetPage(name: Routes.sellProduct, page: () => JualPage()),
    GetPage(
      name: Routes.Category,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final options = (args['options'] as List).cast<String>();
        final title = (args['title'] as String?) ?? 'Pilih Kategori';
        return CategoryListPage(options: options, title: title);
      },
    ),
  ];
}
