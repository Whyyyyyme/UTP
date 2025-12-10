import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prelovedly/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final supa.SupabaseClient _supabase = supa.Supabase.instance.client;

  Future<fb.User?> signUp({
    required String email,
    required String password,
    required String nama,
    String? username,
    String? bio,
    String? alamat,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final fb.User? user = result.user;

    if (user != null) {
      await createUserProfile(
        uid: user.uid,
        email: email,
        nama: nama,
        username: username,
        bio: bio,
        alamat: alamat,
      );

      try {
        await _supabase.from('users').insert({
          'uid': user.uid,
          'email': email,
          'nama': nama,
          'username': username ?? '',
          'bio': bio ?? '',
          'alamat': alamat ?? '',
          'no_telp': '',
          'foto_profil_url': '',
          'role': 'pembeli',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print("Supabase insert gagal: $e");
      }
    }

    return user;
  }

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
      'role': 'pembeli',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<fb.User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return result.user;
  }

  Future<void> signOut() async => _auth.signOut();

  Future<UserModel?> getUserProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return UserModel.fromMap(snap.data()!);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update({
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    });

    final supaData = Map<String, dynamic>.from(data);
    supaData.removeWhere((key, value) => value is FieldValue);

    try {
      await _supabase.from('users').update(supaData).eq('uid', uid);
    } catch (e) {
      print('Supabase updateProfile gagal: $e');
    }
  }

  Future<String> uploadProfilePhoto(String uid, XFile picked) async {
    try {
      final fileName = "$uid-${DateTime.now().millisecondsSinceEpoch}.jpg";

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();

        await _supabase.storage
            .from('profile_photos')
            .uploadBinary(fileName, bytes);
      } else {
        final file = await picked.readAsBytes();
        await _supabase.storage
            .from('profile_photos')
            .uploadBinary(fileName, file);
      }

      final publicUrl = _supabase.storage
          .from('profile_photos')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print("uploadProfilePhoto ERROR: $e");
      rethrow;
    }
  }
}
