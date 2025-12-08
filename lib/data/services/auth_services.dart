import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prelovedly/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String nama,
    String? username,
    String? bio,
    String? alamat,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'nama': nama,
      'username': username ?? '',
      'bio': bio ?? '',
      'alamat': alamat ?? '',
      'no_telp': '',
      'foto_profil_url': '',
      'tanggal_daftar': FieldValue.serverTimestamp(),
      'role': 'pembeli',
      'jumlah_produk_diupload': 0,
      'rating_rata': 0.0,
      'total_transaksi_berhasil': 0,
      'is_verified': false,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// REGISTER + auto buat profil
  Future<User?> signUp({
    required String email,
    required String password,
    required String nama,
    String? username,
    String? bio,
    String? alamat,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;

      if (user != null) {
        await createUserProfile(
          uid: user.uid,
          email: email,
          nama: nama,
          username: username,
          bio: bio,
          alamat: alamat,
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('AuthService signUp error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('AuthService signUp other error: $e');
      rethrow;
    }
  }

  /// LOGIN
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('AuthService signIn error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('AuthService signIn other error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<UserModel?> getUserProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;

    return UserModel.fromMap(snap.data() as Map<String, dynamic>);
  }
}
