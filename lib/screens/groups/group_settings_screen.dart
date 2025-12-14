import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../providers/group_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';

class GroupSettingsScreen extends StatefulWidget {
  final GroupModel group;

  const GroupSettingsScreen({super.key, required this.group});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedCurrency;
  late bool _simplificationEnabled;
  late bool _notificationsEnabled;
  late List<String> _currencies;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(
      text: widget.group.description ?? '',
    );

    // Initialize currencies list
    _currencies = ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD', 'AUD', 'CNY'];

    // Ensure the group's currency is in the list
    if (!_currencies.contains(widget.group.currency)) {
      _currencies.add(widget.group.currency);
    }

    _selectedCurrency = widget.group.currency;
    _simplificationEnabled = widget.group.simplificationEnabled;
    _notificationsEnabled = widget.group.notificationsEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final success = await groupProvider.updateGroup(
      groupId: widget.group.groupId,
      requesterId: authProvider.currentUser!.uid,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      currency: _selectedCurrency,
      simplificationEnabled: _simplificationEnabled,
      notificationsEnabled: _notificationsEnabled,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group updated successfully')),
      );
      Navigator.pop(context);
    } else if (groupProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(groupProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Group Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Group Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              MyTextfield(
                controller: _nameController,
                hintText: 'Group Name',
                obscureText: false,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              MyTextfield(
                controller: _descriptionController,
                hintText: 'Description (optional)',
                obscureText: false,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Currency',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Debt Simplification'),
                subtitle: const Text('Minimize number of transactions'),
                value: _simplificationEnabled,
                onChanged: (value) {
                  setState(() {
                    _simplificationEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Get notified about group activities'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              MyButton(
                onPressed: _updateGroup,
                text: 'Save Changes',
                isLoading: groupProvider.isLoading,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Transfer Admin Rights',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a member to transfer admin rights to:',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ...widget.group.members.where((m) => m.userId != currentUserId).map((
                member,
              ) {
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
                    return Card(
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
                        trailing: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Transfer Admin Rights'),
                                content: Text(
                                  'Transfer admin rights to ${user.displayName}? You will become a regular member.',
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
                                    child: const Text('Transfer'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              final success = await groupProvider.transferAdmin(
                                widget.group.groupId,
                                currentUserId,
                                member.userId,
                              );
                              if (success && context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Admin rights transferred'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Transfer'),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
