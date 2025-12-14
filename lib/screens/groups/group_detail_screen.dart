import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/expense_provider.dart';
import 'group_settings_screen.dart';
import 'add_member_screen.dart';
import '../expenses/add_expense_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load expenses for this specific group when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      // Clear any previous expenses and load only this group's expenses
      expenseProvider.loadExpensesByGroup(widget.group.groupId);
    });
  }

  @override
  void didUpdateWidget(GroupDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload expenses if group changes
    if (oldWidget.group.groupId != widget.group.groupId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final expenseProvider = Provider.of<ExpenseProvider>(
          context,
          listen: false,
        );
        expenseProvider.loadExpensesByGroup(widget.group.groupId);
      });
    }
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

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍔';
      case 'entertainment':
        return '🎬';
      case 'utilities':
        return '💡';
      case 'transportation':
        return '🚗';
      case 'shopping':
        return '🛍️';
      case 'travel':
        return '✈️';
      case 'personal':
        return '👤';
      case 'health':
        return '🏥';
      case 'subscription':
        return '📱';
      default:
        return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isAdmin = widget.group.createdBy == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupSettingsScreen(group: widget.group),
                  ),
                );
              },
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              if (isAdmin)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Group'),
                    ],
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Leave Group'),
                    ],
                  ),
                ),
            ],
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Group'),
                    content: const Text(
                      'Are you sure? This will delete all expenses in this group.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  final success = await groupProvider.deleteGroup(
                    widget.group.groupId,
                    currentUserId,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Group deleted')),
                    );
                  }
                }
              } else if (value == 'leave') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Leave Group'),
                    content: const Text(
                      'Are you sure you want to leave this group?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Leave',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  final success = await groupProvider.leaveGroup(
                    widget.group.groupId,
                    currentUserId,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Left group')));
                  }
                }
              }
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Group info card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.group.description != null) ...[
                      Text(
                        widget.group.description!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Icon(Icons.people, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('${widget.group.members.length} members'),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(widget.group.currency),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Members'),
                Tab(text: 'Recent Activity'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Members tab
                  _buildMembersTab(isAdmin),
                  // Activity tab
                  _buildActivityTab(expenseProvider),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddExpenseScreen(groupId: widget.group.groupId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMembersTab(bool isAdmin) {
    return Column(
      children: [
        if (isAdmin)
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person_add, color: Colors.white),
            ),
            title: const Text('Add Member'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMemberScreen(group: widget.group),
                ),
              );
            },
          ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.group.members.length,
            itemBuilder: (context, index) {
              final member = widget.group.members[index];
              final isGroupAdmin = member.userId == widget.group.createdBy;

              return FutureBuilder<UserModel?>(
                future: _getUserData(member.userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Loading...'),
                    );
                  }

                  final user = snapshot.data!;
                  return ListTile(
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
                    trailing: isGroupAdmin
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          )
                        : (isAdmin
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Remove Member'),
                                        content: Text(
                                          'Remove ${user.displayName} from the group?',
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
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true && context.mounted) {
                                      final authProvider =
                                          Provider.of<AuthProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final groupProvider =
                                          Provider.of<GroupProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final success = await groupProvider
                                          .removeMember(
                                            widget.group.groupId,
                                            member.userId,
                                            authProvider.currentUser!.uid,
                                          );
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Member removed'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                )
                              : null),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTab(ExpenseProvider expenseProvider) {
    // Filter expenses to only show those belonging to this group
    final groupExpenses = expenseProvider.expenses
        .where((expense) => expense.groupId == widget.group.groupId)
        .toList();

    if (groupExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: groupExpenses.length,
      itemBuilder: (context, index) {
        final expense = groupExpenses[index];

        return FutureBuilder<UserModel?>(
          future: _getUserData(expense.payerId),
          builder: (context, snapshot) {
            final payerName = snapshot.data?.displayName ?? 'Unknown';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Text(
                  _getCategoryIcon(expense.category),
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text(expense.description ?? 'Expense'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paid by $payerName'),
                    Text(
                      '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: Text(
                  '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
