import 'package:flutter/material.dart';
import '../models/saved_split_model.dart';
import '../services/saved_split_service.dart';

class SavedSplitProvider with ChangeNotifier {
  final SavedSplitService _savedSplitService = SavedSplitService();

  bool _isLoading = false;
  String? _errorMessage;
  List<SavedSplitModel> _savedSplits = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SavedSplitModel> get savedSplits => _savedSplits;

  // Create saved split
  Future<void> createSavedSplit(SavedSplitModel savedSplit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _savedSplitService.createSavedSplit(savedSplit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update saved split
  Future<void> updateSavedSplit(SavedSplitModel savedSplit) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _savedSplitService.updateSavedSplit(savedSplit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete saved split
  Future<void> deleteSavedSplit(String savedSplitId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _savedSplitService.deleteSavedSplit(savedSplitId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user saved splits
  void loadUserSavedSplits(String userId) {
    _savedSplitService.getUserSavedSplits(userId).listen((splits) {
      _savedSplits = splits;
      notifyListeners();
    });
  }

  // Load saved splits by type
  void loadSavedSplitsByType(String userId, String splitType) {
    _savedSplitService.getSavedSplitsByType(userId, splitType).listen((splits) {
      _savedSplits = splits;
      notifyListeners();
    });
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
