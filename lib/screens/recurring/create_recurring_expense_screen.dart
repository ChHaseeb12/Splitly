import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/recurring_expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/recurring_expense_model.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';

class CreateRecurringExpenseScreen extends StatefulWidget {
  final String groupId;

  const CreateRecurringExpenseScreen({super.key, required this.groupId});

  @override
  State<CreateRecurringExpenseScreen> createState() =>
      _CreateRecurringExpenseScreenState();
}

class _CreateRecurringExpenseScreenState
    extends State<CreateRecurringExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'FOOD';
  String _selectedCurrency = 'USD';
  RecurringFrequency _selectedFrequency = RecurringFrequency.MONTHLY;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _autoCreate = true;

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

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'INR',
    'CNY',
  ];

  void _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  DateTime _calculateNextDueDate() {
    switch (_selectedFrequency) {
      case RecurringFrequency.DAILY:
        return _startDate.add(const Duration(days: 1));
      case RecurringFrequency.WEEKLY:
        return _startDate.add(const Duration(days: 7));
      case RecurringFrequency.MONTHLY:
        return DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
      case RecurringFrequency.YEARLY:
        return DateTime(_startDate.year + 1, _startDate.month, _startDate.day);
    }
  }

  void _createRecurringExpense() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final recurringProvider = Provider.of<RecurringExpenseProvider>(
        context,
        listen: false,
      );

      final recurringId = FirebaseFirestore.instance
          .collection('recurringExpenses')
          .doc()
          .id;
      final baseExpenseId = FirebaseFirestore.instance
          .collection('expenses')
          .doc()
          .id;

      final recurringExpense = RecurringExpenseModel(
        recurringId: recurringId,
        baseExpenseId: baseExpenseId,
        groupId: widget.groupId,
        payerId: authProvider.currentUser!.uid,
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        category: _selectedCategory,
        description: _descriptionController.text,
        frequency: _selectedFrequency,
        startDate: _startDate,
        endDate: _endDate,
        nextDueDate: _calculateNextDueDate(),
        isActive: true,
        autoCreate: _autoCreate,
        splitConfig: {'splitType': 'EQUAL', 'participants': []},
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await recurringProvider.createRecurringExpense(recurringExpense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recurring expense created successfully'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Recurring Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MyTextfield(
              controller: _amountController,
              hintText: 'Amount',
              obscureText: false,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            MyTextfield(
              controller: _descriptionController,
              hintText: 'Description',
              obscureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(value: currency, child: Text(currency));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecurringFrequency>(
              value: _selectedFrequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: RecurringFrequency.values.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_startDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectStartDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('End Date (Optional)'),
              subtitle: Text(
                _endDate?.toString().split(' ')[0] ?? 'No end date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectEndDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto-create expenses'),
              subtitle: const Text('Automatically create expenses on due date'),
              value: _autoCreate,
              onChanged: (value) {
                setState(() {
                  _autoCreate = value;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(height: 24),
            MyButton(
              onPressed: _createRecurringExpense,
              text: 'Create Recurring Expense',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
