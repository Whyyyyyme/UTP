import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prelovedly/data/repository/cart_repository.dart';
import 'package:prelovedly/data/repository/chat_repository.dart';
import 'package:prelovedly/data/repository/follow_repository.dart';
import 'package:prelovedly/data/repository/inbox_repository.dart';
import 'package:prelovedly/data/repository/like_repository.dart';
import 'package:prelovedly/data/repository/manage_product_repository.dart';
import 'package:prelovedly/data/repository/nego_repository.dart';
import 'package:prelovedly/data/repository/product_repository.dart';
import 'package:prelovedly/data/repository/sell_repository.dart';
import 'package:prelovedly/data/repository/shop_profile_repository.dart';
import 'package:prelovedly/data/repository/user_repository.dart';
import 'package:prelovedly/data/services/cart_service.dart';
import 'package:prelovedly/data/services/chat_service.dart';
import 'package:prelovedly/data/services/follow_service.dart';
import 'package:prelovedly/data/services/inbox_service.dart';
import 'package:prelovedly/data/services/like_service.dart';
import 'package:prelovedly/data/services/manage_product_service.dart';
import 'package:prelovedly/data/services/nego_service.dart';
import 'package:prelovedly/data/services/product_service.dart';
import 'package:prelovedly/data/services/sell_service.dart';
import 'package:prelovedly/data/services/shop_profile.dart';
import 'package:prelovedly/pages/chat/chat_page.dart';
import 'package:prelovedly/pages/inbox_page.dart';
import 'package:prelovedly/pages/product/nego_page.dart';
import 'package:prelovedly/pages/email_login_page.dart';

import 'package:prelovedly/pages/product/product_detail_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_product_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile/edit_bio_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile/edit_nama_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile/edit_username_page.dart';
import 'package:prelovedly/pages/profile_pages/edit_profile_page.dart';
import 'package:prelovedly/pages/profile_pages/followers_page.dart';
import 'package:prelovedly/pages/profile_pages/manage_product_page.dart';
import 'package:prelovedly/pages/profile_pages/setting_page.dart';
import 'package:prelovedly/pages/profile_pages/shop_profile_screen.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/brand_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/color_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/condition_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/material_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/price_page.dart';
import 'package:prelovedly/pages/sell_pages/atribut_produk/size_picker_page.dart';
import 'package:prelovedly/pages/sell_pages/edit_draft_page.dart';
import 'package:prelovedly/pages/sell_pages/sell_page.dart';
import 'package:prelovedly/pages/sell_pages/style_picker_page.dart';
import 'package:prelovedly/view_model/cart_controller.dart';
import 'package:prelovedly/view_model/chat_controller.dart';
import 'package:prelovedly/view_model/follow_controller.dart';
import 'package:prelovedly/view_model/inbox_controller.dart';
import 'package:prelovedly/view_model/login_controller.dart';
import 'package:prelovedly/view_model/manage_product_controller.dart';
import 'package:prelovedly/view_model/nego_controller.dart';
import 'package:prelovedly/view_model/product/brand_controller.dart';
import 'package:prelovedly/view_model/product/color_picker_controller.dart';
import 'package:prelovedly/view_model/product/condition_picker_controller.dart';
import 'package:prelovedly/view_model/product/material_picker_controller.dart';
import 'package:prelovedly/view_model/product_detail_controller.dart';
import 'package:prelovedly/view_model/register_controller.dart';
import 'package:prelovedly/view_model/shop_profile_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'app_routes.dart';

// services + repo
import 'package:prelovedly/data/services/auth_services.dart';
import 'package:prelovedly/data/services/home_service.dart';
import 'package:prelovedly/data/repository/home_repository.dart';

import 'package:prelovedly/data/services/address_service.dart';
import 'package:prelovedly/data/repository/address_repository.dart';

// controllers
import 'package:prelovedly/view_model/session_controller.dart';
import 'package:prelovedly/view_model/auth_controller.dart';
import 'package:prelovedly/view_model/home_controller.dart';
import 'package:prelovedly/view_model/main_nav_controller.dart';
import 'package:prelovedly/view_model/like_controller.dart';

import 'package:prelovedly/view_model/address_controller.dart';
import 'package:prelovedly/view_model/sell_controller.dart';
import 'package:prelovedly/view_model/product/category_controller.dart';

// pages (sesuaikan)
import 'package:prelovedly/pages/login_page.dart';
import 'package:prelovedly/pages/home_page.dart';
import 'package:prelovedly/pages/profile_page.dart';
import 'package:prelovedly/pages/jual_page_check.dart';
import 'package:prelovedly/pages/profile_pages/address/add_address_page.dart';
import 'package:prelovedly/pages/profile_pages/address/address_list_page.dart';
import 'package:prelovedly/pages/cart/cart_page.dart';

import 'package:prelovedly/pages/Register_pages/register_email.dart';
import 'package:prelovedly/pages/Register_pages/register_nama.dart';
import 'package:prelovedly/pages/Register_pages/register_username.dart';
import 'package:prelovedly/pages/Register_pages/register_password.dart';

import 'package:prelovedly/pages/admin_pages/admin_dashboard_page.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  // ===== GLOBAL (dipakai banyak halaman) =====
  static void ensureGlobals() {
    if (!Get.isRegistered<SessionController>()) {
      Get.put(SessionController(), permanent: true);
    }

    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    }
    if (!Get.isRegistered<FirebaseAuth>()) {
      Get.lazyPut<FirebaseAuth>(() => FirebaseAuth.instance, fenix: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(Get.find<AuthService>(), Get.find<FirebaseAuth>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<MainNavController>()) {
      Get.put(MainNavController(), permanent: true);
    }

    if (!Get.isRegistered<HomeService>()) {
      Get.lazyPut<HomeService>(() => HomeService(), fenix: true);
    }
    if (!Get.isRegistered<HomeRepository>()) {
      Get.lazyPut<HomeRepository>(
        () => HomeRepository(Get.find<HomeService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(
        HomeController(Get.find<HomeRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<LikeService>()) {
      Get.lazyPut<LikeService>(
        () => LikeService(FirebaseFirestore.instance),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LikeRepository>()) {
      Get.lazyPut<LikeRepository>(
        () => LikeRepository(Get.find<LikeService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<LikeController>()) {
      Get.put<LikeController>(
        LikeController(Get.find<LikeRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CartService>()) {
      Get.lazyPut<CartService>(
        () => CartService(FirebaseFirestore.instance),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CartRepository>()) {
      Get.lazyPut<CartRepository>(
        () => CartRepository(Get.find<CartService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CartController>()) {
      Get.put<CartController>(
        CartController(Get.find<CartRepository>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<InboxService>()) {
      Get.lazyPut<InboxService>(
        () => InboxService(FirebaseFirestore.instance),
        fenix: true,
      );
    }

    if (!Get.isRegistered<InboxRepository>()) {
      Get.lazyPut<InboxRepository>(
        () => InboxRepository(Get.find<InboxService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<InboxController>()) {
      Get.put<InboxController>(
        InboxController(Get.find<InboxRepository>()),
        permanent: true,
      );
    }
  }

  static void _ensureFollow() {
    ensureGlobals();

    if (!Get.isRegistered<FollowService>()) {
      Get.lazyPut(() => FollowService(FirebaseFirestore.instance), fenix: true);
    }

    if (!Get.isRegistered<FollowRepository>()) {
      Get.lazyPut(
        () => FollowRepository(Get.find<FollowService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut(() => UserRepository(Get.find<AuthService>()), fenix: true);
    }

    if (!Get.isRegistered<FollowController>()) {
      Get.put(
        FollowController(
          repo: Get.find<FollowRepository>(),
          userRepo: Get.find<UserRepository>(),
        ),
        permanent: true,
      );
    }
  }

  // ===== ADDRESS FEATURE =====
  static void _ensureAddress() {
    ensureGlobals(); // kalau AddressController butuh AuthController userId

    if (!Get.isRegistered<AddressService>()) {
      Get.lazyPut<AddressService>(
        () => AddressService(FirebaseFirestore.instance),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AddressRepository>()) {
      Get.lazyPut<AddressRepository>(
        () => AddressRepository(Get.find<AddressService>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AddressController>()) {
      Get.put<AddressController>(
        AddressController(Get.find<AddressRepository>()),
        permanent: true,
      );
    }
  }

  // ===== SELL FEATURE =====
  static void _ensureSell() {
    ensureGlobals();

    if (!Get.isRegistered<BrandController>()) {
      Get.put(BrandController(), permanent: true);
    }

    if (!Get.isRegistered<SellService>()) {
      Get.lazyPut<SellService>(
        () => SellService(
          db: FirebaseFirestore.instance,
          supabase: supa.Supabase.instance.client,
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SellRepository>()) {
      Get.lazyPut<SellRepository>(
        () => SellRepository(Get.find<SellService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<SellController>()) {
      Get.put<SellController>(
        SellController(
          repo: Get.find<SellRepository>(),
          brandController: Get.find<BrandController>(),
          authController: Get.find<AuthController>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<CategoryController>()) {
      Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    }
  }

  static void _ensureProductDetail() {
    ensureGlobals(); // ini wajib: LikeController, CartController, HomeController, dll sudah ada

    if (!Get.isRegistered<ProductService>()) {
      Get.lazyPut<ProductService>(
        () => ProductService(db: FirebaseFirestore.instance),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepository(service: Get.find<ProductService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProductDetailController>()) {
      Get.lazyPut<ProductDetailController>(
        () => ProductDetailController(repo: Get.find<ProductRepository>()),
        fenix: true,
      );
    }
  }

  static void _ensureShopProfile() {
    ensureGlobals(); // Auth, Follow, Like, dll
    _ensureSell(); // supaya draft bisa loadDraft/editDraft tanpa error
    _ensureFollow();

    if (!Get.isRegistered<ShopProfileService>()) {
      Get.lazyPut<ShopProfileService>(
        () => ShopProfileService(db: FirebaseFirestore.instance),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ShopProfileRepository>()) {
      Get.lazyPut<ShopProfileRepository>(
        () => ShopProfileRepository(service: Get.find<ShopProfileService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ShopProfileController>()) {
      Get.lazyPut<ShopProfileController>(
        () => ShopProfileController(repo: Get.find<ShopProfileRepository>()),
        fenix: true,
      );
    }
  }

  static void _ensureRegister() {
    ensureGlobals();

    if (!Get.isRegistered<RegisterController>()) {
      Get.lazyPut<RegisterController>(() => RegisterController(), fenix: true);
    }
  }

  static void _ensureAuth() {
    // FirebaseAuth
    if (!Get.isRegistered<FirebaseAuth>()) {
      Get.lazyPut<FirebaseAuth>(() => FirebaseAuth.instance, fenix: true);
    }

    // AuthService
    if (!Get.isRegistered<AuthService>()) {
      Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    }

    // AuthController
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(Get.find<AuthService>(), Get.find<FirebaseAuth>()),
        permanent: true,
      );
    }
  }

  static void _ensureChat() {
    Get.lazyPut<ChatService>(
      () => ChatService(FirebaseFirestore.instance),
      fenix: true,
    );
    Get.lazyPut<ChatRepository>(
      () => ChatRepository(Get.find<ChatService>()),
      fenix: true,
    );
    Get.create<ChatController>(
      () => ChatController(Get.find<ChatRepository>()),
    );
  }

  static final routes = <GetPage>[
    // ======================
    // AUTH
    // ======================
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(), // landing fixed
      binding: BindingsBuilder(() {
        ensureGlobals();
      }),
    ),

    GetPage(
      name: Routes.emailLogin,
      page: () => const EmailLoginPage(),
      binding: BindingsBuilder(() {
        ensureGlobals();
        if (!Get.isRegistered<LoginController>()) {
          Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
        }
      }),
    ),

    GetPage(
      name: Routes.registerEmail,
      page: () => const EmailRegisterPage(),
      binding: BindingsBuilder(() {
        _ensureRegister();
      }),
    ),

    GetPage(
      name: Routes.registerName,
      page: () => const NameRegisterPage(),
      binding: BindingsBuilder(() {
        _ensureRegister();
      }),
    ),
    GetPage(
      name: Routes.registerUsername,
      page: () => const UsernameRegisterPage(),
      binding: BindingsBuilder(() {
        _ensureRegister();
      }),
    ),
    GetPage(
      name: Routes.registerPassword,
      page: () => const PasswordRegisterPage(),
      binding: BindingsBuilder(() {
        _ensureRegister();
      }),
    ),

    // ======================
    // HOME
    // ======================
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        ensureGlobals();
      }),
    ),

    GetPage(
      name: Routes.profile,
      page: () => const ProfilePage(),
      binding: BindingsBuilder(() {
        ensureGlobals();
      }),
    ),

    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfilePage(),
      binding: BindingsBuilder(() {
        _ensureAuth();
      }),
    ),

    GetPage(
      name: Routes.editBio,
      page: () => const EditBioPage(),
      binding: BindingsBuilder(() {
        _ensureAuth();
      }),
    ),

    GetPage(
      name: Routes.editName,
      page: () => const EditNamePage(),
      binding: BindingsBuilder(() {
        _ensureAuth();
      }),
    ),

    GetPage(
      name: Routes.editUsername,
      page: () => const EditUsernamePage(initialUsername: ''),
      binding: BindingsBuilder(() {
        _ensureAuth();
      }),
    ),

    GetPage(
      name: Routes.editDraft,
      page: () => const EditDraftPage(),
      binding: BindingsBuilder(() {
        _ensureAuth();
      }),
    ),

    GetPage(
      name: Routes.editProduct,
      page: () => const EditProductPage(),
      binding: BindingsBuilder(() {
        _ensureAuth();
        _ensureSell();
      }),
    ),
    // ======================
    // CART
    // ======================
    GetPage(
      name: Routes.cart,
      page: () => const CartPage(),
      binding: BindingsBuilder(() {
        ensureGlobals(); // Cart sudah ada di globals kamu
      }),
    ),

    // ======================
    // ADDRESS
    // ======================
    GetPage(
      name: Routes.addAddress,
      page: () => AddAddressPage(),
      binding: BindingsBuilder(() {
        _ensureAddress();
      }),
    ),
    GetPage(
      name: Routes.addressList,
      page: () => AddressListPage(),
      binding: BindingsBuilder(() {
        _ensureAddress();
      }),
    ),

    // ======================
    // SELL
    // ======================
    GetPage(
      name: Routes.sellAddressIntro,
      page: () => const SellAddressIntroPage(),
      binding: BindingsBuilder(() {
        ensureGlobals();
        _ensureAddress();
        _ensureSell();
      }),
    ),

    // Pastikan Routes.jualPage ada di app_routes.dart
    GetPage(
      name: Routes.sellProduct,
      page: () => const JualPage(),
      binding: BindingsBuilder(() {
        _ensureSell();
        _ensureAddress();
      }),
    ),

    GetPage(
      name: Routes.manageProduct,
      page: () => const ManageProductPage(),
      binding: BindingsBuilder(() {
        ensureGlobals();

        if (!Get.isRegistered<ManageProductService>()) {
          Get.lazyPut<ManageProductService>(
            () => ManageProductService(FirebaseFirestore.instance),
            fenix: true,
          );
        }

        if (!Get.isRegistered<ManageProductRepository>()) {
          Get.lazyPut<ManageProductRepository>(
            () => ManageProductRepository(Get.find<ManageProductService>()),
            fenix: true,
          );
        }

        if (!Get.isRegistered<ManageProductController>()) {
          Get.put<ManageProductController>(
            ManageProductController(Get.find<ManageProductRepository>()),
          );
        }
      }),
    ),

    GetPage(
      name: Routes.productDetail, // pastikan ini ada di app_routes.dart
      page: () => ProductDetailPage(),
      binding: BindingsBuilder(() {
        _ensureProductDetail();
      }),
    ),

    GetPage(
      name: Routes.nego,
      page: () => const NegoPage(),
      binding: BindingsBuilder(() {
        ensureGlobals();
        _ensureChat();

        if (!Get.isRegistered<NegoService>()) {
          Get.lazyPut<NegoService>(
            () => NegoService(FirebaseFirestore.instance),
            fenix: true,
          );
        }

        if (!Get.isRegistered<NegoRepository>()) {
          Get.lazyPut<NegoRepository>(
            () => NegoRepository(Get.find<NegoService>()),
            fenix: true,
          );
        }

        if (!Get.isRegistered<NegoController>()) {
          Get.put<NegoController>(NegoController(Get.find<NegoRepository>()));
        }
      }),
    ),

    GetPage(
      name: Routes.shopProfile,
      page: () => ShopProfileScreen(),
      binding: BindingsBuilder(() {
        _ensureShopProfile();
        _ensureChat();
      }),
    ),

    GetPage(
      name: Routes.followersFollowing,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;

        return FollowersFollowingPage(
          userId: args?['userId'] ?? '',
          initialIndex: args?['initialIndex'] ?? 0,
        );
      },
      binding: BindingsBuilder(() {
        _ensureFollow();
      }),
    ),

    GetPage(
      name: Routes.brand,
      page: () => const BrandPickerPage(),
      binding: BindingsBuilder(() {
        _ensureSell();
      }),
    ),

    GetPage(
      name: Routes.color,
      page: () => const ColorPickerPage(),
      binding: BindingsBuilder(() {
        _ensureSell();
        if (!Get.isRegistered<ColorPickerController>()) {
          Get.put(ColorPickerController(), permanent: true);
        }
      }),
    ),

    GetPage(
      name: Routes.condition,
      page: () => const ConditionPickerPage(),
      binding: BindingsBuilder(() {
        _ensureSell();
        if (!Get.isRegistered<ConditionPickerController>()) {
          Get.put(ConditionPickerController(), permanent: true);
        }
      }),
    ),

    GetPage(
      name: Routes.material,
      page: () => const MaterialPickerPage(),
      binding: BindingsBuilder(() {
        _ensureSell();
        if (!Get.isRegistered<MaterialPickerController>()) {
          Get.put(MaterialPickerController(), permanent: true);
        }
      }),
    ),

    GetPage(
      name: Routes.price,
      page: () => const PricePage(),
      binding: BindingsBuilder(() {
        _ensureSell();
      }),
    ),

    GetPage(
      name: Routes.style,
      page: () => const StylePickerPage(),
      binding: BindingsBuilder(() {
        _ensureSell();
      }),
    ),

    GetPage(
      name: Routes.size,
      page: () => const SizePickerPage(),
      binding: BindingsBuilder(() {
        _ensureSell();
      }),
    ),

    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(() {
        ensureGlobals();
      }),
    ),

    GetPage(
      name: Routes.inbox,
      page: () => InboxPage(),
      binding: BindingsBuilder(() {
        ensureGlobals();
      }),
    ),

    GetPage(
      name: Routes.chat,
      page: () => const ChatPage(),
      binding: BindingsBuilder(() {
        ensureGlobals();
        _ensureChat();
      }),
    ),

    // ===============
    //      ADMIN
    // ===============
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboardPage(),
      binding: BindingsBuilder(() {
        _ensureAuth();
      }),
    ),
    // ... route lain lanjutkan
  ];
}
