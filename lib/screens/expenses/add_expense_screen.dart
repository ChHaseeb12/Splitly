import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';
import '../../widgets/currency_selector.dart';

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

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addParticipant(String userId) {
    setState(() {
      _participants.add({
        'userId': userId,
        'amount': 0.0,
        'percentage': 0.0,
        'shares': 1.0,
      });
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: \$${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Text(
              'Split Type: ${_selectedSplitType.toString().split('.').last.toUpperCase()}',
            ),
            const SizedBox(height: 16),
            const Text('Each person pays:'),
            ..._participants.map(
              (p) =>
                  Text('${p['userId']}: \$${splitAmount.toStringAsFixed(2)}'),
            ),
          ],
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
                    onPressed: () {
                      // In real app, show user picker dialog
                      _addParticipant('user_${_participants.length + 1}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._participants.asMap().entries.map((entry) {
                final index = entry.key;
                final participant = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(participant['userId']),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeParticipant(index),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

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
