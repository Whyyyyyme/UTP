abstract class Routes {
  Routes._();

  // Login & Register
  static const login = '/login';
  static const emailLogin = '/email-login';
  static const registerEmail = '/register-email';
  static const registerName = '/register-name';
  static const registerUsername = '/register-username';
  static const registerPassword = '/register-password';

  // Main Page
  static const home = '/home';
  static const profile = '/profile';
  static const inbox = '/inbox';

  // Profile
  static const shopProfile = '/shop-profile';
  static const settings = '/settings';
  static const editProfile = '/edit-profile';
  static const address = '/address';
  static const addAddress = '/add-address';
  static const addressList = '/address-list';
  static const editBio = '/edit-bio';
  static const editName = '/edit-name';
  static const editUsername = '/edit-username';

  // Sell
  static const sellAddressIntro = '/sell-address-intro';
  static const sellProduct = '/sell-product';
  static const editDraft = '/edit-draft';
  static const category = '/category';
  static const size = '/size';
  static const brand = '/brand';
  static const condition = '/condition';
  static const color = '/color';
  static const style = '/style';
  static const material = '/material';
  static const price = '/price';

  static const manageProduct = '/manage-product';
  static const editProduct = '/edit-product';
  static const productDetail = '/product-detail';

  static const cart = '/cart';
  static const followersFollowing = '/followers-following';
  static const nego = '/nego';
  static const chat = '/chat';

  static const checkout = '/checkout';
  static const sellerShipping = '/seller-shipping';
  static const selectShipping = '/select-shipping';

  // Admin
  static const adminDashboard = '/admin-dashboard';
  static const adminUsers = '/admin-users';
  static const adminProducts = '/admin-products';
  static const adminProductDetail = '/admin-product-detail';
  static const adminReports = '/admin-reports';
  static const adminSettings = '/admin-settings';
}
