import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

class GroupProvider with ChangeNotifier {
  final GroupService _groupService = GroupService();

  List<GroupModel> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GroupModel> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create group
  Future<String?> createGroup({
    required String name,
    String? description,
    required String createdBy,
    required String creatorName,
    String currency = 'USD',
    bool simplificationEnabled = true,
    bool notificationsEnabled = true,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final groupId = await _groupService.createGroup(
        name: name,
        description: description,
        createdBy: createdBy,
        creatorName: creatorName,
        currency: currency,
        simplificationEnabled: simplificationEnabled,
        notificationsEnabled: notificationsEnabled,
      );

      _isLoading = false;
      notifyListeners();
      return groupId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Add member to group
  Future<bool> addMember(
    String groupId,
    String userId,
    String userName,
    String addedByName,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _groupService.addMember(groupId, userId, userName, addedByName);

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

  // Remove member from group
  Future<bool> removeMember(
    String groupId,
    String userId,
    String requesterId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _groupService.removeMember(groupId, userId, requesterId);

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

  // Update group
  Future<bool> updateGroup({
    required String groupId,
    required String requesterId,
    String? name,
    String? description,
    String? currency,
    bool? simplificationEnabled,
    bool? notificationsEnabled,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _groupService.updateGroup(
        groupId: groupId,
        requesterId: requesterId,
        name: name,
        description: description,
        currency: currency,
        simplificationEnabled: simplificationEnabled,
        notificationsEnabled: notificationsEnabled,
      );

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

  // Delete group
  Future<bool> deleteGroup(String groupId, String requesterId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _groupService.deleteGroup(groupId, requesterId);

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

  // Leave group
  Future<bool> leaveGroup(String groupId, String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _groupService.leaveGroup(groupId, userId);

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

  // Transfer admin rights
  Future<bool> transferAdmin(
    String groupId,
    String currentAdminId,
    String newAdminId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _groupService.transferAdmin(groupId, currentAdminId, newAdminId);

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

  // Load user groups
  void loadUserGroups(String userId) {
    _groupService.getUserGroups(userId).listen((groups) {
      _groups = groups;
      notifyListeners();
    });
  }

  // Get single group
  Future<GroupModel?> getGroup(String groupId) async {
    try {
      return await _groupService.getGroup(groupId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String groupId, String userId) async {
    return await _groupService.isAdmin(groupId, userId);
  }

  // Check if user is member
  Future<bool> isMember(String groupId, String userId) async {
    return await _groupService.isMember(groupId, userId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
