import 'package:flutter/foundation.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _commentService = CommentService();

  List<CommentModel> _comments = [];
  List<ActivityFeedItem> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<CommentModel> get comments => _comments;
  List<ActivityFeedItem> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load comments for expense
  void loadComments(String expenseId) {
    _commentService
        .getComments(expenseId)
        .listen(
          (comments) {
            _comments = comments;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  // Add comment
  Future<void> addComment(CommentModel comment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _commentService.addComment(comment);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update comment
  Future<void> updateComment(String commentId, String text) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _commentService.updateComment(commentId, text);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _commentService.deleteComment(commentId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get comment count
  Future<int> getCommentCount(String expenseId) async {
    try {
      return await _commentService.getCommentCount(expenseId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  // Load group activity
  Future<void> loadGroupActivity(String groupId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _activities = await _commentService.getGroupActivity(groupId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user activity
  Future<void> loadUserActivity(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _activities = await _commentService.getUserActivity(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear session activities
  Future<void> clearSessionActivities() async {
    try {
      await _commentService.clearSessionActivities();
      _activities = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Create activity
  Future<void> createActivity(ActivityFeedItem activity) async {
    try {
      await _commentService.createActivity(activity);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear comments
  void clearComments() {
    _comments = [];
    notifyListeners();
  }

  // Clear activities
  void clearActivities() {
    _activities = [];
    notifyListeners();
  }
}
