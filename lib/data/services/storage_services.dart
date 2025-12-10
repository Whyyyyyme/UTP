import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final String filename = '$uid-${DateTime.now().millisecondsSinceEpoch}.jpg';

    final response = await supabase.storage
        .from('profile_photos')
        .upload(filename, file);

    if (response.isEmpty) {
      throw Exception("Gagal upload ke Supabase");
    }

    final String publicUrl = supabase.storage
        .from('profile_photos')
        .getPublicUrl(filename);

    return publicUrl;
  }
}
