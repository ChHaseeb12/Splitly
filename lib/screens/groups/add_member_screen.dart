import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../providers/friend_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/friend_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AddMemberScreen extends StatefulWidget {
  final GroupModel group;

  const AddMemberScreen({super.key, required this.group});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final friendProvider = Provider.of<FriendProvider>(
        context,
        listen: false,
      );
      if (authProvider.currentUser != null) {
        friendProvider.loadFriends(authProvider.currentUser!.uid);
      }
    });
  }

  Future<UserModel?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
    return null;
  }

  String _getOtherUserId(FriendModel friend, String currentUserId) {
    return friend.userId1 == currentUserId ? friend.userId2 : friend.userId1;
  }

  bool _isAlreadyMember(String userId) {
    return widget.group.members.any((m) => m.userId == userId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final friendProvider = Provider.of<FriendProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    // Filter friends who are not already members
    final availableFriends = friendProvider.friends.where((friend) {
      final otherUserId = _getOtherUserId(friend, currentUserId);
      return !_isAlreadyMember(otherUserId);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Member')),
      body: availableFriends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No friends available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All your friends are already in this group',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: availableFriends.length,
              itemBuilder: (context, index) {
                final friend = availableFriends[index];
                final otherUserId = _getOtherUserId(friend, currentUserId);

                return FutureBuilder<UserModel?>(
                  future: _getUserData(otherUserId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
                        leading: CircleAvatar(child: Icon(Icons.person)),
                        title: Text('Loading...'),
                      );
                    }

                    final user = snapshot.data!;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Add Member'),
                                content: Text(
                                  'Add ${user.displayName} to ${widget.group.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              final currentUser = authProvider.currentUser!;
                              final success = await groupProvider.addMember(
                                widget.group.groupId,
                                user.uid,
                                user.displayName,
                                currentUser.displayName ?? 'User',
                              );

                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${user.displayName} added to group',
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                              } else if (context.mounted &&
                                  groupProvider.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(groupProvider.errorMessage!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
