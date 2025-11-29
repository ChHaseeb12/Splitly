import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/currency_converter.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseDetailScreen({super.key, required this.expense});

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

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Receipt'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final defaultCurrency = currencyProvider.defaultCurrency;
    final showConversion = expense.currency != defaultCurrency;

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Amount Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: _getCategoryColor(expense.category),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showConversion) ...[
                    const SizedBox(height: 8),
                    CurrencyConverter(
                      amount: expense.amount,
                      fromCurrency: expense.currency,
                      toCurrency: defaultCurrency,
                      showRate: true,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    expense.description ?? 'No description',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildDetailRow('Category', expense.category),
                  _buildDetailRow(
                    'Date',
                    expense.date.toString().split(' ')[0],
                  ),
                  _buildDetailRow(
                    'Split Type',
                    expense.splitType.name.toUpperCase(),
                  ),
                  _buildDetailRow('Status', expense.status.name.toUpperCase()),
                  _buildDetailRow(
                    'Participants',
                    '${expense.participants.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Participants Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Split Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ...expense.participants.map((participant) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(participant.userId),
                          Text(
                            '${expense.currency} ${participant.splitAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Notes Card
          if (expense.notes != null && expense.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Text(expense.notes!),
                  ],
                ),
              ),
            ),
          ],

          // Attachments Card
          if (expense.attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receipts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: expense.attachments.length,
                      itemBuilder: (context, index) {
                        final imageUrl = expense.attachments[index];
                        return GestureDetector(
                          onTap: () => _showImagePreview(context, imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
