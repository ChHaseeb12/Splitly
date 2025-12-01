import 'package:flutter/material.dart';
import '../models/analytics_models.dart';

/// Card displaying spending summary
class SpendingSummaryCard extends StatelessWidget {
  final SpendingSummary summary;

  const SpendingSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Total Spent',
              summary.totalSpent,
              Colors.blue,
              Icons.shopping_cart,
            ),
            const Divider(),
            _buildSummaryRow(
              'You Owe',
              summary.totalOwed,
              Colors.red,
              Icons.arrow_upward,
            ),
            const Divider(),
            _buildSummaryRow(
              'You Are Owed',
              summary.totalLent,
              Colors.green,
              Icons.arrow_downward,
            ),
            const Divider(),
            _buildSummaryRow(
              'Net Balance',
              summary.netBalance,
              summary.netBalance >= 0 ? Colors.green : Colors.red,
              summary.netBalance >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Total Expenses'),
                  ],
                ),
                Text(
                  '${summary.expenseCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
