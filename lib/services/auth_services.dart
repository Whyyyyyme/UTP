import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk membuat profil pengguna
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String nama,
    String? username,
    String? bio,
    String? alamat,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'nama': nama,
      'username': username ?? '',
      'bio': bio ?? '',
      'alamat': alamat ?? '',
      'no_telp': '',
      'foto_profil_url': '',
      'tanggal_daftar': FieldValue.serverTimestamp(),
      'role': 'pembeli', // default
      'jumlah_produk_diupload': 0,
      'rating_rata': 0.0,
      'total_transaksi_berhasil': 0,
      'is_verified': false,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Register dengan membuat profil otomatis
  Future<User?> signUp(String email, String password, String nama) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Buat profil otomatis
        await createUserProfile(uid: user.uid, email: email, nama: nama);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error (signUp): ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Error lain (signUp): $e");
      return null;
    }
  }

  // Login
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error (signIn): ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Error lain (signIn): $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Dapatkan user saat ini
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
