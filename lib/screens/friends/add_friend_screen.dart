import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/friend_model.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      setState(() => _isSearching = true);
      friendProvider.searchUsers(query, authProvider.currentUser!.uid).then((
        _,
      ) {
        setState(() => _isSearching = false);
      });
    }
  }

  Future<FriendModel?> _checkFriendship(String targetUserId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      return await friendProvider.getFriendship(
        authProvider.currentUser!.uid,
        targetUserId,
      );
    }
    return null;
  }

  Widget _buildFriendshipStatus(FriendModel? friendship, String currentUserId) {
    if (friendship == null) {
      return const Text('Not friends', style: TextStyle(color: Colors.grey));
    }

    if (friendship.status == FriendStatus.accepted) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text('Friends', style: TextStyle(color: Colors.green)),
        ],
      );
    }

    if (friendship.status == FriendStatus.pending) {
      if (friendship.userId1 == currentUserId) {
        return const Text(
          'Request sent',
          style: TextStyle(color: Colors.orange),
        );
      } else {
        return const Text(
          'Pending request',
          style: TextStyle(color: Colors.orange),
        );
      }
    }

    if (friendship.status == FriendStatus.blocked) {
      return const Text('Blocked', style: TextStyle(color: Colors.red));
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final friendProvider = Provider.of<FriendProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Friend')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by email or name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          friendProvider.clearSearchResults();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          if (friendProvider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                friendProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: friendProvider.searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Search for friends',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter email or name to find users',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: friendProvider.searchResults.length,
                    itemBuilder: (context, index) {
                      final user = friendProvider.searchResults[index];

                      return FutureBuilder<FriendModel?>(
                        future: _checkFriendship(user.uid),
                        builder: (context, snapshot) {
                          final friendship = snapshot.data;
                          final canSendRequest =
                              friendship == null ||
                              friendship.status == FriendStatus.blocked;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(user.displayName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email),
                                  const SizedBox(height: 4),
                                  _buildFriendshipStatus(
                                    friendship,
                                    currentUserId,
                                  ),
                                ],
                              ),
                              trailing: canSendRequest
                                  ? IconButton(
                                      icon: const Icon(Icons.person_add),
                                      onPressed: () async {
                                        final success = await friendProvider
                                            .sendFriendRequest(
                                              currentUserId,
                                              user.uid,
                                            );

                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Friend request sent',
                                              ),
                                            ),
                                          );
                                          setState(
                                            () {},
                                          ); // Refresh to show new status
                                        } else if (context.mounted &&
                                            friendProvider.errorMessage !=
                                                null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                friendProvider.errorMessage!,
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
