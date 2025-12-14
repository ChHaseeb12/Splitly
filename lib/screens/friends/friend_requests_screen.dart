import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/friend_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
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
        friendProvider.loadPendingRequests(authProvider.currentUser!.uid);
        friendProvider.loadSentRequests(authProvider.currentUser!.uid);
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

  @override
  Widget build(BuildContext context) {
    final friendProvider = Provider.of<FriendProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friend Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Received requests
            _buildReceivedRequests(friendProvider),
            // Sent requests
            _buildSentRequests(friendProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedRequests(FriendProvider friendProvider) {
    if (friendProvider.pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: friendProvider.pendingRequests.length,
      itemBuilder: (context, index) {
        final request = friendProvider.pendingRequests[index];

        return FutureBuilder<UserModel?>(
          future: _getUserData(request.userId1),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Loading...'),
              );
            }

            final user = snapshot.data!;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final currentUser = authProvider.currentUser!;
                        final success = await friendProvider
                            .acceptFriendRequest(
                              request.friendId,
                              currentUser.uid,
                              currentUser.displayName ?? 'User',
                              user.uid,
                              user.displayName,
                            );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Friend request accepted'),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        final success = await friendProvider
                            .declineFriendRequest(request.friendId);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Friend request declined'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSentRequests(FriendProvider friendProvider) {
    if (friendProvider.sentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No sent requests',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: friendProvider.sentRequests.length,
      itemBuilder: (context, index) {
        final request = friendProvider.sentRequests[index];

        return FutureBuilder<UserModel?>(
          future: _getUserData(request.userId2),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Loading...'),
              );
            }

            final user = snapshot.data!;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    const SizedBox(height: 4),
                    const Text(
                      'Pending',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Request'),
                        content: const Text('Cancel this friend request?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final success = await friendProvider.declineFriendRequest(
                        request.friendId,
                      );
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request cancelled')),
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
    );
  }
}
