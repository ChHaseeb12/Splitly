import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');

        // Get FCM token
        String? token = await _messaging.getToken();
        print('FCM Token: $token');

        // Listen to token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          print('FCM Token refreshed: $newToken');
          // Update token in Firestore
        });
      } else {
        print('User declined notification permission');
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Save FCM token to user profile
  Future<void> saveFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving FCM token: $e');
      rethrow;
    }
  }

  // Create notification
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  // Get notifications for user
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    NotificationModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Get notification preferences
  Future<NotificationPreferences> getPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('notificationPreferences')
          .doc(userId)
          .get();

      if (doc.exists) {
        return NotificationPreferences.fromJson({
          ...doc.data()!,
          'userId': userId,
        });
      } else {
        return NotificationPreferences(userId: userId);
      }
    } catch (e) {
      print('Error getting notification preferences: $e');
      return NotificationPreferences(userId: userId);
    }
  }

  // Update notification preferences
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    try {
      await _firestore
          .collection('notificationPreferences')
          .doc(preferences.userId)
          .set(preferences.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating notification preferences: $e');
      rethrow;
    }
  }

  // Send notification (would typically be done via Cloud Functions)
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: _firestore.collection('notifications').doc().id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data ?? {},
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
