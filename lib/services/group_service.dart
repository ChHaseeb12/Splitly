import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/comment_model.dart';
import 'comment_service.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CommentService _commentService = CommentService();

  // Create group (creator automatically admin)
  Future<String> createGroup({
    required String name,
    String? description,
    required String createdBy,
    required String creatorName,
    String currency = 'USD',
    bool simplificationEnabled = true,
    bool notificationsEnabled = true,
  }) async {
    try {
      final groupId = _firestore.collection('groups').doc().id;
      final now = DateTime.now();

      final group = GroupModel(
        groupId: groupId,
        name: name,
        description: description,
        createdBy: createdBy,
        members: [GroupMember(userId: createdBy, joinDate: now)],
        currency: currency,
        simplificationEnabled: simplificationEnabled,
        notificationsEnabled: notificationsEnabled,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('groups').doc(groupId).set(group.toJson());

      // Create activity
      final activity = ActivityFeedItem(
        id: '${groupId}_created_${now.millisecondsSinceEpoch}',
        userId: createdBy,
        userName: creatorName,
        type: ActivityType.GROUP_CREATED,
        description: 'created group "$name"',
        groupId: groupId,
        data: {'groupName': name},
        createdAt: now,
      );
      await _commentService.createActivity(activity);

      return groupId;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  // Add member to group
  Future<void> addMember(
    String groupId,
    String userId,
    String userName,
    String addedByName,
  ) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        throw Exception('Group not found');
      }

      final group = GroupModel.fromJson(groupDoc.data()!);

      // Check if user is already a member
      if (group.members.any((m) => m.userId == userId)) {
        throw Exception('User is already a member');
      }

      final now = DateTime.now();
      final updatedMembers = [
        ...group.members,
        GroupMember(userId: userId, joinDate: now),
      ];

      await _firestore.collection('groups').doc(groupId).update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'updatedAt': now,
      });

      // Create activity
      final activity = ActivityFeedItem(
        id: '${groupId}_member_added_${now.millisecondsSinceEpoch}',
        userId: group.createdBy,
        userName: addedByName,
        type: ActivityType.MEMBER_ADDED,
        description: 'added $userName to ${group.name}',
        groupId: groupId,
        data: {
          'groupName': group.name,
          'newMemberId': userId,
          'newMemberName': userName,
          'participants': [group.createdBy, userId],
        },
        createdAt: now,
      );
      await _commentService.createActivity(activity);
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  // Remove member from group
  Future<void> removeMember(
    String groupId,
    String userId,
    String userName,
    String requesterId,
    String requesterName,
  ) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        throw Exception('Group not found');
      }

      final group = GroupModel.fromJson(groupDoc.data()!);

      // Check if requester is admin
      if (group.createdBy != requesterId) {
        throw Exception('Only admin can remove members');
      }

      // Cannot remove admin
      if (userId == group.createdBy) {
        throw Exception('Cannot remove group admin');
      }

      final updatedMembers = group.members
          .where((m) => m.userId != userId)
          .toList();

      final now = DateTime.now();
      await _firestore.collection('groups').doc(groupId).update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'updatedAt': now,
      });

      // Create activity
      final activity = ActivityFeedItem(
        id: '${groupId}_member_removed_${now.millisecondsSinceEpoch}',
        userId: requesterId,
        userName: requesterName,
        type: ActivityType.MEMBER_REMOVED,
        description: 'removed $userName from ${group.name}',
        groupId: groupId,
        data: {
          'groupName': group.name,
          'removedMemberId': userId,
          'removedMemberName': userName,
          'participants': [requesterId, userId],
        },
        createdAt: now,
      );
      await _commentService.createActivity(activity);
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  // Edit group details
  Future<void> updateGroup({
    required String groupId,
    required String requesterId,
    String? name,
    String? description,
    String? currency,
    bool? simplificationEnabled,
    bool? notificationsEnabled,
  }) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        throw Exception('Group not found');
      }

      final group = GroupModel.fromJson(groupDoc.data()!);

      // Check if requester is admin
      if (group.createdBy != requesterId) {
        throw Exception('Only admin can edit group');
      }

      final updates = <String, dynamic>{'updatedAt': DateTime.now()};

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (currency != null) updates['currency'] = currency;
      if (simplificationEnabled != null) {
        updates['simplificationEnabled'] = simplificationEnabled;
      }
      if (notificationsEnabled != null) {
        updates['notificationsEnabled'] = notificationsEnabled;
      }

      await _firestore.collection('groups').doc(groupId).update(updates);
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  // Delete group (admin only, cascade cleanup)
  Future<void> deleteGroup(
    String groupId,
    String requesterId,
    String requesterName,
  ) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        throw Exception('Group not found');
      }

      final group = GroupModel.fromJson(groupDoc.data()!);

      // Check if requester is admin
      if (group.createdBy != requesterId) {
        throw Exception('Only admin can delete group');
      }

      // Delete all expenses in the group
      final expenses = await _firestore
          .collection('expenses')
          .where('groupId', isEqualTo: groupId)
          .get();

      for (var doc in expenses.docs) {
        await doc.reference.delete();
      }

      // Delete the group
      await _firestore.collection('groups').doc(groupId).delete();

      // Create activity
      final now = DateTime.now();
      final activity = ActivityFeedItem(
        id: '${groupId}_deleted_${now.millisecondsSinceEpoch}',
        userId: requesterId,
        userName: requesterName,
        type: ActivityType.GROUP_DELETED,
        description: 'deleted group "${group.name}"',
        data: {
          'groupName': group.name,
          'participants': group.members.map((m) => m.userId).toList(),
        },
        createdAt: now,
      );
      await _commentService.createActivity(activity);
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  // Leave group
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        throw Exception('Group not found');
      }

      final group = GroupModel.fromJson(groupDoc.data()!);

      // Admin cannot leave, must transfer admin rights first
      if (group.createdBy == userId) {
        throw Exception('Admin must transfer rights before leaving');
      }

      final updatedMembers = group.members
          .where((m) => m.userId != userId)
          .toList();

      await _firestore.collection('groups').doc(groupId).update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  // Transfer admin rights
  Future<void> transferAdmin(
    String groupId,
    String currentAdminId,
    String newAdminId,
  ) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        throw Exception('Group not found');
      }

      final group = GroupModel.fromJson(groupDoc.data()!);

      // Check if requester is current admin
      if (group.createdBy != currentAdminId) {
        throw Exception('Only admin can transfer rights');
      }

      // Check if new admin is a member
      if (!group.members.any((m) => m.userId == newAdminId)) {
        throw Exception('New admin must be a group member');
      }

      await _firestore.collection('groups').doc(groupId).update({
        'createdBy': newAdminId,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to transfer admin rights: $e');
    }
  }

  // Get all groups for a user
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _firestore.collection('groups').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupModel.fromJson(doc.data()))
          .where((group) => group.members.any((m) => m.userId == userId))
          .toList();
    });
  }

  // Get single group
  Future<GroupModel?> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (!doc.exists) return null;
      return GroupModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String groupId, String userId) async {
    try {
      final group = await getGroup(groupId);
      return group?.createdBy == userId;
    } catch (e) {
      return false;
    }
  }

  // Check if user is member
  Future<bool> isMember(String groupId, String userId) async {
    try {
      final group = await getGroup(groupId);
      return group?.members.any((m) => m.userId == userId) ?? false;
    } catch (e) {
      return false;
    }
  }
}
