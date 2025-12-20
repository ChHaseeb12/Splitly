import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/expense_model.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../models/currency_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';
import '../../widgets/currency_selector.dart';
import '../../data/currencies.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;

  const AddExpenseScreen({super.key, required this.groupId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'FOOD';
  String _selectedCurrency = 'USD';
  SplitType _selectedSplitType = SplitType.equal;
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _participants = [];
  GroupModel? _group;
  Map<String, UserModel> _groupMembers = {};

  @override
  void initState() {
    super.initState();
    // Initialize with user's default currency
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _selectedCurrency = authProvider.userProfile?.currency ?? 'USD';
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = await groupProvider.getGroup(widget.groupId);

    if (group != null) {
      setState(() {
        _group = group;
      });

      // Load member details
      for (var member in group.members) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(member.userId)
            .get();
        if (userDoc.exists) {
          _groupMembers[member.userId] = UserModel.fromJson(userDoc.data()!);
        }
      }
      setState(() {});
    }
  }

  final List<String> _categories = [
    'FOOD',
    'ENTERTAINMENT',
    'UTILITIES',
    'TRANSPORTATION',
    'SHOPPING',
    'TRAVEL',
    'PERSONAL',
    'HEALTH',
    'SUBSCRIPTION',
    'OTHER',
  ];

  // Helper method to get currency symbol
  String _getCurrencySymbol(String currencyCode) {
    final currencyData = CurrencyData.currencies.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => CurrencyModel(
        code: currencyCode,
        name: currencyCode,
        symbol: currencyCode,
        flag: '',
      ),
    );
    return currencyData.symbol;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showParticipantPicker() {
    if (_group == null || _groupMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members available in this group')),
      );
      return;
    }

    // Get members not already added
    final availableMembers = _group!.members.where((member) {
      return !_participants.any((p) => p['userId'] == member.userId);
    }).toList();

    if (availableMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All members already added')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Participant'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableMembers.length,
            itemBuilder: (context, index) {
              final member = availableMembers[index];
              final user = _groupMembers[member.userId];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    user?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                  ),
                ),
                title: Text(user?.displayName ?? 'Unknown User'),
                subtitle: Text(user?.email ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  _addParticipant(member.userId);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addParticipant(String userId) {
    setState(() {
      _participants.add({'userId': userId, 'amount': 0.0, 'percentage': 0.0});
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSplitPreview() {
    if (_amountController.text.isEmpty || _participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter amount and add participants'),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    final splitAmount = amount / _participants.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split Preview'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount: $_selectedCurrency ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Split Type: ${_selectedSplitType.toString().split('.').last.toUpperCase()}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Each person pays:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._participants.map((p) {
                final user = _groupMembers[p['userId']];
                final userName = user?.displayName ?? 'Unknown User';

                // Calculate amount based on split type
                double userAmount;
                if (_selectedSplitType == SplitType.equal) {
                  userAmount = splitAmount;
                } else if (_selectedSplitType == SplitType.unequal) {
                  userAmount = p['amount'] ?? splitAmount;
                } else if (_selectedSplitType == SplitType.percentage) {
                  final percentage =
                      p['percentage'] ?? (100.0 / _participants.length);
                  userAmount = amount * (percentage / 100);
                } else {
                  userAmount = splitAmount;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(
                          userName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '$_selectedCurrency ${userAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSplitDetailsDialog() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount first')),
      );
      return;
    }

    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add participants first')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;

    if (_selectedSplitType == SplitType.unequal) {
      _showUnequalSplitDialog(amount);
    } else if (_selectedSplitType == SplitType.percentage) {
      _showPercentageSplitDialog(amount);
    }
  }

  void _showUnequalSplitDialog(double totalAmount) {
    final controllers = _participants.map((p) {
      return TextEditingController(text: p['amount'].toString());
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Custom Amounts'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total: ${_getCurrencySymbol(_selectedCurrency)}${totalAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 16),
                ...List.generate(_participants.length, (index) {
                  final user = _groupMembers[_participants[index]['userId']];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: controllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: user?.displayName ?? 'Unknown',
                        border: const OutlineInputBorder(),
                        prefixText: '${_getCurrencySymbol(_selectedCurrency)} ',
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              double sum = 0;
              for (int i = 0; i < controllers.length; i++) {
                final amount = double.tryParse(controllers[i].text) ?? 0;
                _participants[i]['amount'] = amount;
                sum += amount;
              }

              if ((sum - totalAmount).abs() > 0.01) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Amounts must sum to ${_getCurrencySymbol(_selectedCurrency)}${totalAmount.toStringAsFixed(2)}. Current sum: ${_getCurrencySymbol(_selectedCurrency)}${sum.toStringAsFixed(2)}',
                    ),
                  ),
                );
              } else {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPercentageSplitDialog(double totalAmount) {
    final controllers = _participants.map((p) {
      return TextEditingController(text: p['percentage'].toString());
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Percentages'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total: ${_getCurrencySymbol(_selectedCurrency)}${totalAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 16),
                ...List.generate(_participants.length, (index) {
                  final user = _groupMembers[_participants[index]['userId']];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: controllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: user?.displayName ?? 'Unknown',
                        border: const OutlineInputBorder(),
                        suffixText: '%',
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              double sum = 0;
              for (int i = 0; i < controllers.length; i++) {
                final percentage = double.tryParse(controllers[i].text) ?? 0;
                _participants[i]['percentage'] = percentage;
                sum += percentage;
              }

              if ((sum - 100).abs() > 0.01) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Percentages must sum to 100%. Current sum: ${sum.toStringAsFixed(1)}%',
                    ),
                  ),
                );
              } else {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one participant')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    final amount = double.parse(_amountController.text);

    final expenseId = await expenseProvider.addExpense(
      groupId: widget.groupId,
      payerId: authProvider.currentUser!.uid,
      payerName: authProvider.currentUser!.displayName ?? 'Unknown',
      amount: amount,
      currency: _selectedCurrency,
      category: _selectedCategory,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      date: _selectedDate,
      participants: _participants,
      splitType: _selectedSplitType,
    );

    if (expenseId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            expenseProvider.errorMessage ?? 'Failed to add expense',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.grey[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              MyTextfield(
                controller: _amountController,
                hintText: 'Amount',
                obscureText: false,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              MyTextfield(
                controller: _descriptionController,
                hintText: 'Description (optional)',
                obscureText: false,
              ),
              const SizedBox(height: 16),

              // Category
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Currency
              const Text(
                'Currency',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CurrencySelector(
                selectedCurrency: _selectedCurrency,
                onCurrencySelected: (currency) {
                  setState(() {
                    _selectedCurrency = currency;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Split Type
              const Text(
                'Split Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SplitType>(
                value: _selectedSplitType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: SplitType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSplitType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date
              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Participants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Participants',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showParticipantPicker,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_participants.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No participants added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ..._participants.asMap().entries.map((entry) {
                final index = entry.key;
                final participant = entry.value;
                final user = _groupMembers[participant['userId']];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        user?.displayName.substring(0, 1).toUpperCase() ?? 'U',
                      ),
                    ),
                    title: Text(user?.displayName ?? 'Unknown User'),
                    subtitle: Text(user?.email ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeParticipant(index),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Configure Split Button (for unequal and percentage)
              if (_selectedSplitType != SplitType.equal)
                MyButton(
                  onPressed: _showSplitDetailsDialog,
                  text: _selectedSplitType == SplitType.unequal
                      ? 'Set Custom Amounts'
                      : 'Set Percentages',
                  backgroundColor: Colors.grey[300]!,
                  textColor: Colors.black,
                ),
              if (_selectedSplitType != SplitType.equal)
                const SizedBox(height: 16),

              // Preview Button
              MyButton(
                onPressed: _showSplitPreview,
                text: 'Preview Split',
                backgroundColor: Colors.grey[300]!,
                textColor: Colors.black,
              ),
              const SizedBox(height: 16),

              // Submit Button
              MyButton(
                onPressed: expenseProvider.isLoading ? () {} : _submitExpense,
                text: expenseProvider.isLoading ? 'Adding...' : 'Add Expense',
                isLoading: expenseProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
