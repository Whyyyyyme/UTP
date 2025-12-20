import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class SellService {
  SellService({
    required FirebaseFirestore db,
    required supa.SupabaseClient supabase,
  }) : _db = db,
       _supabase = supabase;

  final FirebaseFirestore _db;
  final supa.SupabaseClient _supabase;

  FirebaseFirestore get db => _db;

  DocumentReference<Map<String, dynamic>> productDoc(String productId) =>
      _db.collection('products').doc(productId);

  DocumentReference<Map<String, dynamic>> newProductDoc() =>
      _db.collection('products').doc();

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct(String id) =>
      productDoc(id).get();

  Future<void> setProduct(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) => ref.set(data, SetOptions(merge: true));

  Future<void> updateProductFields(
    String productId,
    Map<String, dynamic> data,
  ) {
    return productDoc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) {
    return productDoc(productId).delete();
  }

  /// upload 1 file → return public url
  Future<String> uploadProductPhoto({
    required String sellerId,
    required String productId,
    required XFile file,
  }) async {
    final fileName =
        '$sellerId/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      final resp = await _supabase.storage
          .from('product_photos')
          .uploadBinary(fileName, bytes);

      if (resp.isEmpty) throw Exception('Upload gagal (web)');
    } else {
      final f = File(file.path);
      final resp = await _supabase.storage
          .from('product_photos')
          .upload(fileName, f);

      if (resp.isEmpty) throw Exception('Upload gagal (mobile)');
    }

    return _supabase.storage.from('product_photos').getPublicUrl(fileName);
  }

  CollectionReference<Map<String, dynamic>> productsRef() =>
      _db.collection('products');

  Future<void> deleteProductDoc(String productId) {
    return productsRef().doc(productId).delete();
  }
}
