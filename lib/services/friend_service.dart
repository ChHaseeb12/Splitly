import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send friend request
  Future<void> sendFriendRequest(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      // Check if friendship already exists
      final existingFriendship = await _firestore
          .collection('friends')
          .where('userId1', whereIn: [currentUserId, targetUserId])
          .where('userId2', whereIn: [currentUserId, targetUserId])
          .get();

      if (existingFriendship.docs.isNotEmpty) {
        throw Exception('Friend request already exists');
      }

      final friendId = _firestore.collection('friends').doc().id;
      final friend = FriendModel(
        friendId: friendId,
        userId1: currentUserId,
        userId2: targetUserId,
        status: FriendStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('friends').doc(friendId).set(friend.toJson());
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String friendId) async {
    try {
      await _firestore.collection('friends').doc(friendId).update({
        'status': FriendStatus.accepted.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  // Decline friend request
  Future<void> declineFriendRequest(String friendId) async {
    try {
      await _firestore.collection('friends').doc(friendId).delete();
    } catch (e) {
      throw Exception('Failed to decline friend request: $e');
    }
  }

  // Remove friend
  Future<void> removeFriend(String friendId) async {
    try {
      await _firestore.collection('friends').doc(friendId).delete();
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  // Block user
  Future<void> blockUser(String friendId) async {
    try {
      await _firestore.collection('friends').doc(friendId).update({
        'status': FriendStatus.blocked.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Get all friends for a user
  Stream<List<FriendModel>> getFriends(String userId) {
    return _firestore
        .collection('friends')
        .where('userId1', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot1) async {
          final friends1 = snapshot1.docs
              .map((doc) => FriendModel.fromJson(doc.data()))
              .toList();

          final snapshot2 = await _firestore
              .collection('friends')
              .where('userId2', isEqualTo: userId)
              .get();

          final friends2 = snapshot2.docs
              .map((doc) => FriendModel.fromJson(doc.data()))
              .toList();

          return [...friends1, ...friends2];
        });
  }

  // Get pending friend requests (incoming)
  Stream<List<FriendModel>> getPendingRequests(String userId) {
    return _firestore
        .collection('friends')
        .where('userId2', isEqualTo: userId)
        .where(
          'status',
          isEqualTo: FriendStatus.pending.toString().split('.').last,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get sent friend requests (outgoing)
  Stream<List<FriendModel>> getSentRequests(String userId) {
    return _firestore
        .collection('friends')
        .where('userId1', isEqualTo: userId)
        .where(
          'status',
          isEqualTo: FriendStatus.pending.toString().split('.').last,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Search users by email or display name
  Future<List<UserModel>> searchUsers(
    String query,
    String currentUserId,
  ) async {
    try {
      if (query.isEmpty) return [];

      // Search by email
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('email', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .limit(10)
          .get();

      // Search by display name
      final nameQuery = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      final users = <UserModel>[];
      final seenIds = <String>{};

      for (var doc in [...emailQuery.docs, ...nameQuery.docs]) {
        final user = UserModel.fromJson(doc.data());
        if (user.uid != currentUserId && !seenIds.contains(user.uid)) {
          users.add(user);
          seenIds.add(user.uid);
        }
      }

      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get friend status between two users
  Future<FriendModel?> getFriendship(String userId1, String userId2) async {
    try {
      final query1 = await _firestore
          .collection('friends')
          .where('userId1', isEqualTo: userId1)
          .where('userId2', isEqualTo: userId2)
          .get();

      if (query1.docs.isNotEmpty) {
        return FriendModel.fromJson(query1.docs.first.data());
      }

      final query2 = await _firestore
          .collection('friends')
          .where('userId1', isEqualTo: userId2)
          .where('userId2', isEqualTo: userId1)
          .get();

      if (query2.docs.isNotEmpty) {
        return FriendModel.fromJson(query2.docs.first.data());
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get friendship: $e');
    }
  }
}
