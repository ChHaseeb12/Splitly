import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/friend_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/friend_model.dart';
import '../../models/user_model.dart';
import 'add_friend_screen.dart';
import 'friend_requests_screen.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
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
        friendProvider.loadPendingRequests(authProvider.currentUser!.uid);
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final friendProvider = Provider.of<FriendProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          // Pending requests badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FriendRequestsScreen(),
                    ),
                  );
                },
              ),
              if (friendProvider.pendingRequests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${friendProvider.pendingRequests.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: friendProvider.friends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No friends yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add friends to start splitting expenses',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: friendProvider.friends.length,
              itemBuilder: (context, index) {
                final friend = friendProvider.friends[index];
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
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.person_remove, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Remove Friend'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'remove') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove Friend'),
                                  content: Text(
                                    'Are you sure you want to remove ${user.displayName} from your friends?',
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
                                      child: const Text(
                                        'Remove',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                );
                                final success = await friendProvider
                                    .removeFriend(
                                      friend.friendId,
                                      authProvider.currentUser!.uid,
                                      authProvider.currentUser!.displayName ??
                                          'Unknown',
                                      user.uid,
                                      user.displayName,
                                    );
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Friend removed'),
                                    ),
                                  );
                                }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFriendScreen()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
