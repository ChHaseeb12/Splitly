import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recurring_expense_provider.dart';
import '../../models/recurring_expense_model.dart';
import 'create_recurring_expense_screen.dart';

class RecurringExpenseListScreen extends StatefulWidget {
  final String groupId;

  const RecurringExpenseListScreen({super.key, required this.groupId});

  @override
  State<RecurringExpenseListScreen> createState() =>
      _RecurringExpenseListScreenState();
}

class _RecurringExpenseListScreenState
    extends State<RecurringExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RecurringExpenseProvider>(
        context,
        listen: false,
      );
      provider.loadRecurringExpensesByGroup(widget.groupId);
    });
  }

  String _getFrequencyText(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.DAILY:
        return 'Daily';
      case RecurringFrequency.WEEKLY:
        return 'Weekly';
      case RecurringFrequency.MONTHLY:
        return 'Monthly';
      case RecurringFrequency.YEARLY:
        return 'Yearly';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
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
        return Icons.local_hospital;
      case 'SUBSCRIPTION':
        return Icons.subscriptions;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD':
        return Colors.orange;
      case 'ENTERTAINMENT':
        return Colors.purple;
      case 'UTILITIES':
        return Colors.yellow.shade700;
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

  void _showOptionsDialog(RecurringExpenseModel recurring) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recurring Expense Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                recurring.isActive ? Icons.pause : Icons.play_arrow,
              ),
              title: Text(recurring.isActive ? 'Pause' : 'Resume'),
              onTap: () {
                Navigator.pop(context);
                final provider = Provider.of<RecurringExpenseProvider>(
                  context,
                  listen: false,
                );
                if (recurring.isActive) {
                  provider.pauseRecurringExpense(recurring.recurringId);
                } else {
                  provider.resumeRecurringExpense(recurring.recurringId);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      recurring.isActive
                          ? 'Recurring expense paused'
                          : 'Recurring expense resumed',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(recurring);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(RecurringExpenseModel recurring) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Expense'),
        content: const Text(
          'Do you want to delete future expense instances as well?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = Provider.of<RecurringExpenseProvider>(
                context,
                listen: false,
              );
              provider.deleteRecurringExpense(
                recurring.recurringId,
                deleteFutureInstances: false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recurring expense deleted')),
              );
            },
            child: const Text('Delete Template Only'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = Provider.of<RecurringExpenseProvider>(
                context,
                listen: false,
              );
              provider.deleteRecurringExpense(
                recurring.recurringId,
                deleteFutureInstances: true,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Recurring expense and future instances deleted',
                  ),
                ),
              );
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Expenses')),
      body: Consumer<RecurringExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.recurringExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No recurring expenses',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create one to automate regular expenses',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.recurringExpenses.length,
            itemBuilder: (context, index) {
              final recurring = provider.recurringExpenses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(recurring.category),
                    child: Icon(
                      _getCategoryIcon(recurring.category),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    recurring.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${recurring.currency} ${recurring.amount.toStringAsFixed(2)}',
                      ),
                      Text(
                        '${_getFrequencyText(recurring.frequency)} • Next: ${recurring.nextDueDate.toString().split(' ')[0]}',
                      ),
                      if (!recurring.isActive)
                        const Text(
                          'PAUSED',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptionsDialog(recurring),
                  ),
                  isThreeLine: true,
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
            MaterialPageRoute(
              builder: (context) =>
                  CreateRecurringExpenseScreen(groupId: widget.groupId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
