import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';
import '../services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<FriendModel> _friends = [];
  List<FriendModel> _pendingRequests = [];
  List<FriendModel> _sentRequests = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FriendModel> get friends => _friends;
  List<FriendModel> get pendingRequests => _pendingRequests;
  List<FriendModel> get sentRequests => _sentRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Send friend request
  Future<bool> sendFriendRequest(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _friendService.sendFriendRequest(currentUserId, targetUserId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String friendId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _friendService.acceptFriendRequest(friendId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Decline friend request
  Future<bool> declineFriendRequest(String friendId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _friendService.declineFriendRequest(friendId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Remove friend
  Future<bool> removeFriend(String friendId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _friendService.removeFriend(friendId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Block user
  Future<bool> blockUser(String friendId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _friendService.blockUser(friendId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load friends
  void loadFriends(String userId) {
    _friendService.getFriends(userId).listen((friends) {
      _friends = friends
          .where((f) => f.status == FriendStatus.accepted)
          .toList();
      notifyListeners();
    });
  }

  // Load pending requests
  void loadPendingRequests(String userId) {
    _friendService.getPendingRequests(userId).listen((requests) {
      _pendingRequests = requests;
      notifyListeners();
    });
  }

  // Load sent requests
  void loadSentRequests(String userId) {
    _friendService.getSentRequests(userId).listen((requests) {
      _sentRequests = requests;
      notifyListeners();
    });
  }

  // Search users
  Future<void> searchUsers(String query, String currentUserId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _searchResults = await _friendService.searchUsers(query, currentUserId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get friendship status
  Future<FriendModel?> getFriendship(String userId1, String userId2) async {
    try {
      return await _friendService.getFriendship(userId1, userId2);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
