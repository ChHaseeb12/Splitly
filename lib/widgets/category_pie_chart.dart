import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics_models.dart';

/// Pie chart showing spending by category
class CategoryPieChart extends StatelessWidget {
  final List<CategorySpending> categories;

  const CategoryPieChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _buildSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        value: category.amount,
        title: '${category.percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final color = colors[index % colors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              '${_getCategoryDisplayName(category.category)} (\$${category.amount.toStringAsFixed(0)})',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'FOOD':
        return 'Food';
      case 'ENTERTAINMENT':
        return 'Entertainment';
      case 'UTILITIES':
        return 'Utilities';
      case 'TRANSPORTATION':
        return 'Transport';
      case 'SHOPPING':
        return 'Shopping';
      case 'TRAVEL':
        return 'Travel';
      case 'PERSONAL':
        return 'Personal';
      case 'HEALTH':
        return 'Health';
      case 'SUBSCRIPTION':
        return 'Subscription';
      case 'OTHER':
        return 'Other';
      default:
        return category;
    }
  }
}
