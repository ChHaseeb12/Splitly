import 'package:flutter/material.dart';
import '../models/analytics_models.dart';

/// Card displaying debt analytics summary
class DebtSummaryCard extends StatelessWidget {
  final DebtAnalytics analytics;

  const DebtSummaryCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debt Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDebtMetric(
                    'You Owe',
                    analytics.totalOwed,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDebtMetric(
                    'You Are Owed',
                    analytics.totalLent,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDebtMetric(
                    'Net Balance',
                    analytics.netBalance,
                    analytics.netBalance >= 0 ? Colors.green : Colors.red,
                    analytics.netBalance >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDebtMetric(
                    'Active Debts',
                    analytics.activeDebts.toDouble(),
                    Colors.blue,
                    Icons.people,
                    isCount: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtMetric(
    String label,
    double value,
    Color color,
    IconData icon, {
    bool isCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isCount
                ? value.toInt().toString()
                : '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
