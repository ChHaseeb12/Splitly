import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Create activity feed item
  Future<void> createActivity(ActivityFeedItem activity) async {
    try {
      await _firestore
          .collection('activities')
          .doc(activity.id)
          .set(activity.toJson());
    } catch (e) {
      print('Error creating activity: $e');
      rethrow;
    }
  }

  // Get activity feed for group
  Stream<List<ActivityFeedItem>> getGroupActivity(String groupId) {
    return _firestore
        .collection('activities')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ActivityFeedItem.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get activity feed for user
  Stream<List<ActivityFeedItem>> getUserActivity(String userId) {
    return _firestore
        .collection('activities')
        .where('data.participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ActivityFeedItem.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }
}
