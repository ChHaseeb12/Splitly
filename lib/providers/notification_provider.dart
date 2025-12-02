import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  NotificationPreferences? _preferences;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  NotificationPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Initialize notifications
  Future<void> initialize(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _notificationService.initialize();
      await loadPreferences(userId);
      await loadUnreadCount(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load notifications
  void loadNotifications(String userId) {
    _notificationService
        .getNotifications(userId)
        .listen(
          (notifications) {
            _notifications = notifications;
            _unreadCount = notifications.where((n) => !n.isRead).length;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  // Load preferences
  Future<void> loadPreferences(String userId) async {
    try {
      _preferences = await _notificationService.getPreferences(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update preferences
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _notificationService.updatePreferences(preferences);
      _preferences = preferences;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);

      // Update local state
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load unread count
  Future<void> loadUnreadCount(String userId) async {
    try {
      _unreadCount = await _notificationService.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendNotification(
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
      );
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
}
