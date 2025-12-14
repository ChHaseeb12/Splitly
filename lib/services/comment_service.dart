import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _activitiesBoxName = 'session_activities';

  // Add comment to expense
  Future<void> addComment(CommentModel comment) async {
    try {
      await _firestore
          .collection('comments')
          .doc(comment.id)
          .set(comment.toJson());
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Update comment
  Future<void> updateComment(String commentId, String text) async {
    try {
      await _firestore.collection('comments').doc(commentId).update({
        'text': text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating comment: $e');
      rethrow;
    }
  }

  // Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  // Get comments for expense
  Stream<List<CommentModel>> getComments(String expenseId) {
    return _firestore
        .collection('comments')
        .where('expenseId', isEqualTo: expenseId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CommentModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get comment count for expense
  Future<int> getCommentCount(String expenseId) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('expenseId', isEqualTo: expenseId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting comment count: $e');
      return 0;
    }
  }

  // Create activity feed item (session-based, stored locally)
  Future<void> createActivity(ActivityFeedItem activity) async {
    try {
      // Store in local Hive box for session-based activities
      final box = await Hive.openBox(_activitiesBoxName);
      await box.put(activity.id, activity.toJson());
    } catch (e) {
      print('Error creating activity: $e');
      rethrow;
    }
  }

  // Clear all session activities (called on app close)
  Future<void> clearSessionActivities() async {
    try {
      final box = await Hive.openBox(_activitiesBoxName);
      await box.clear();
    } catch (e) {
      print('Error clearing session activities: $e');
    }
  }

  // Get activity feed for group (from local storage)
  Future<List<ActivityFeedItem>> getGroupActivity(String groupId) async {
    try {
      final box = await Hive.openBox(_activitiesBoxName);
      final activities = <ActivityFeedItem>[];

      for (var key in box.keys) {
        final data = box.get(key) as Map<dynamic, dynamic>;
        final activity = ActivityFeedItem.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (activity.groupId == groupId) {
          activities.add(activity);
        }
      }

      // Sort by createdAt descending
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return activities;
    } catch (e) {
      print('Error getting group activity: $e');
      return [];
    }
  }

  // Get activity feed for user (from local storage)
  Future<List<ActivityFeedItem>> getUserActivity(String userId) async {
    try {
      final box = await Hive.openBox(_activitiesBoxName);
      final activities = <ActivityFeedItem>[];

      for (var key in box.keys) {
        final data = box.get(key) as Map<dynamic, dynamic>;
        final activity = ActivityFeedItem.fromJson(
          Map<String, dynamic>.from(data),
        );

        // Include activities where user is involved
        if (activity.userId == userId ||
            (activity.data['participants'] as List?)?.contains(userId) ==
                true ||
            activity.data['targetUserId'] == userId) {
          activities.add(activity);
        }
      }

      // Sort by createdAt descending
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return activities.take(50).toList();
    } catch (e) {
      print('Error getting user activity: $e');
      return [];
    }
  }
}
