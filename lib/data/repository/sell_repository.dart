import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prelovedly/models/image_model.dart';
import '../services/sell_service.dart';

class SellRepository {
  SellRepository(this._service);
  final SellService _service;

  Future<DocumentReference<Map<String, dynamic>>> resolveDocRef({
    required bool isEditing,
    required String? editingProductId,
  }) async {
    if (isEditing && editingProductId != null && editingProductId.isNotEmpty) {
      return _service.productDoc(editingProductId);
    }
    return _service.newProductDoc();
  }

  Future<Map<String, dynamic>?> getOldDataIfEditing({
    required bool isEditing,
    required DocumentReference<Map<String, dynamic>> docRef,
  }) async {
    if (!isEditing) return null;
    final oldDoc = await docRef.get();
    return oldDoc.data();
  }

  Future<List<String>> uploadImagesAndMerge({
    required String sellerId,
    required String productId,
    required List<SellImage> images,
    required Map<String, dynamic>? oldData,
  }) async {
    // upload hanya image lokal; url lama keep
    final urls = <String>[];

    for (final img in images) {
      if (img.isUrl) {
        urls.add(img.url!);
        continue;
      }
      final XFile xf = img.local!;
      final u = await _service.uploadProductPhoto(
        sellerId: sellerId,
        productId: productId,
        file: xf,
      );
      urls.add(u);
    }

    // kalau edit tapi user gak bawa image sama sekali: pakai lama
    if (urls.isEmpty) {
      final old =
          (oldData?['image_urls'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];
      return old;
    }

    return urls;
  }

  Future<void> saveProduct({
    required DocumentReference<Map<String, dynamic>> docRef,
    required Map<String, dynamic> data,
  }) async {
    await _service.setProduct(docRef, data);
  }

  Future<void> moveToDraft(String productId) async {
    await _service.updateProductFields(productId, {
      'status': 'draft',
      'updated_at': Timestamp.now(),
    });
  }

  Future<void> deleteDraft(String productId) {
    return _service.deleteProductDoc(productId);
  }
}
