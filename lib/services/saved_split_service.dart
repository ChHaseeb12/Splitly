import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saved_split_model.dart';

class SavedSplitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create saved split
  Future<void> createSavedSplit(SavedSplitModel savedSplit) async {
    try {
      await _firestore
          .collection('savedSplits')
          .doc(savedSplit.savedSplitId)
          .set(savedSplit.toJson());
    } catch (e) {
      throw Exception('Failed to create saved split: $e');
    }
  }

  // Update saved split
  Future<void> updateSavedSplit(SavedSplitModel savedSplit) async {
    try {
      await _firestore
          .collection('savedSplits')
          .doc(savedSplit.savedSplitId)
          .update(savedSplit.toJson());
    } catch (e) {
      throw Exception('Failed to update saved split: $e');
    }
  }

  // Delete saved split
  Future<void> deleteSavedSplit(String savedSplitId) async {
    try {
      await _firestore.collection('savedSplits').doc(savedSplitId).delete();
    } catch (e) {
      throw Exception('Failed to delete saved split: $e');
    }
  }

  // Get saved split by ID
  Future<SavedSplitModel?> getSavedSplit(String savedSplitId) async {
    try {
      final doc = await _firestore
          .collection('savedSplits')
          .doc(savedSplitId)
          .get();
      if (doc.exists) {
        return SavedSplitModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get saved split: $e');
    }
  }

  // Get all saved splits for a user
  Stream<List<SavedSplitModel>> getUserSavedSplits(String userId) {
    return _firestore
        .collection('savedSplits')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavedSplitModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get saved splits by split type
  Stream<List<SavedSplitModel>> getSavedSplitsByType(
    String userId,
    String splitType,
  ) {
    return _firestore
        .collection('savedSplits')
        .where('userId', isEqualTo: userId)
        .where('splitType', isEqualTo: splitType)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavedSplitModel.fromJson(doc.data()))
              .toList(),
        );
  }
}
