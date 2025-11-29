import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload receipt image
  Future<String> uploadReceiptImage(File imageFile, String expenseId) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child('receipts/$expenseId/$fileName');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload receipt image: $e');
    }
  }

  // Upload multiple receipt images
  Future<List<String>> uploadMultipleReceipts(
    List<File> imageFiles,
    String expenseId,
  ) async {
    try {
      final List<String> urls = [];

      for (var imageFile in imageFiles) {
        final url = await uploadReceiptImage(imageFile, expenseId);
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw Exception('Failed to upload multiple receipts: $e');
    }
  }

  // Delete receipt image
  Future<void> deleteReceiptImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete receipt image: $e');
    }
  }

  // Delete multiple receipt images
  Future<void> deleteMultipleReceipts(List<String> imageUrls) async {
    try {
      for (var url in imageUrls) {
        await deleteReceiptImage(url);
      }
    } catch (e) {
      throw Exception('Failed to delete multiple receipts: $e');
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child('profiles/$fileName');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }
}
