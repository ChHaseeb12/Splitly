import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final String groupId;

  const ExpenseListScreen({super.key, required this.groupId});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    if (_selectedCategory != null) {
      expenseProvider.loadExpensesByCategory(
        groupId: widget.groupId,
        category: _selectedCategory!,
      );
    } else {
      expenseProvider.loadExpensesByGroup(widget.groupId);
    }
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadExpenses();
  }

  Future<void> _filterByDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null && mounted) {
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      await expenseProvider.getExpensesByDateRange(
        groupId: widget.groupId,
        startDate: picked.start,
        endDate: picked.end,
      );

      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
    _loadExpenses();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'FOOD':
        return Icons.restaurant;
      case 'ENTERTAINMENT':
        return Icons.movie;
      case 'UTILITIES':
        return Icons.lightbulb;
      case 'TRANSPORTATION':
        return Icons.directions_car;
      case 'SHOPPING':
        return Icons.shopping_bag;
      case 'TRAVEL':
        return Icons.flight;
      case 'PERSONAL':
        return Icons.person;
      case 'HEALTH':
        return Icons.health_and_safety;
      case 'SUBSCRIPTION':
        return Icons.subscriptions;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'FOOD':
        return Colors.orange;
      case 'ENTERTAINMENT':
        return Colors.purple;
      case 'UTILITIES':
        return Colors.yellow;
      case 'TRANSPORTATION':
        return Colors.blue;
      case 'SHOPPING':
        return Colors.pink;
      case 'TRAVEL':
        return Colors.teal;
      case 'PERSONAL':
        return Colors.green;
      case 'HEALTH':
        return Colors.red;
      case 'SUBSCRIPTION':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Colors.grey[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildFilterSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters
          if (_selectedCategory != null || _startDate != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(_selectedCategory!),
                      onDeleted: () => _filterByCategory(null),
                    ),
                  if (_startDate != null && _endDate != null)
                    Chip(
                      label: Text(
                        '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _loadExpenses();
                      },
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

          // Expense list
          Expanded(
            child: expenseProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : expenseProvider.expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: expenseProvider.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenseProvider.expenses[index];
                      return _buildExpenseCard(expense);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(groupId: widget.groupId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category),
          child: Icon(_getCategoryIcon(expense.category), color: Colors.white),
        ),
        title: Text(
          expense.description ?? expense.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
            ),
            Text('${expense.participants.length} participants'),
            Text('Split: ${expense.splitType.toString().split('.').last}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              expense.currency,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          // Navigate to expense detail screen
          _showExpenseDetails(expense);
        },
      ),
    );
  }

  void _showExpenseDetails(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.description ?? expense.category),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount: \$${expense.amount.toStringAsFixed(2)} ${expense.currency}',
              ),
              const SizedBox(height: 8),
              Text('Category: ${expense.category}'),
              const SizedBox(height: 8),
              Text(
                'Date: ${expense.date.day}/${expense.date.month}/${expense.date.year}',
              ),
              const SizedBox(height: 8),
              Text(
                'Split Type: ${expense.splitType.toString().split('.').last}',
              ),
              const SizedBox(height: 8),
              Text('Status: ${expense.status.toString().split('.').last}'),
              const SizedBox(height: 16),
              const Text(
                'Participants:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...expense.participants.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${p.userId}: \$${p.splitAmount.toStringAsFixed(2)}',
                  ),
                ),
              ),
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

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Expenses',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Filter by Category'),
            onTap: () {
              Navigator.pop(context);
              _showCategoryFilter();
            },
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Filter by Date Range'),
            onTap: () {
              Navigator.pop(context);
              _filterByDateRange();
            },
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                [
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
                ].map((category) {
                  return ListTile(
                    leading: Icon(_getCategoryIcon(category)),
                    title: Text(category),
                    onTap: () {
                      Navigator.pop(context);
                      _filterByCategory(category);
                    },
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
