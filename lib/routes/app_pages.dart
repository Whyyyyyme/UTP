import 'package:get/get.dart';
import 'package:prelovedly/pages/profile_pages/setting_page.dart';

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
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(), // 👈 ROUTES SETTINGS
    ),
  ];
}
