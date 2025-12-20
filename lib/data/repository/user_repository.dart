import '../../models/user_model.dart';
import '../services/auth_services.dart';

class UserRepository {
  UserRepository(this._authService);
  final AuthService _authService;

  Future<UserModel?> getUserByUid(String uid) {
    return _authService.getUserProfile(uid);
  }
}
