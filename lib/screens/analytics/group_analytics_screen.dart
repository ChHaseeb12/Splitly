import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';
import '../../models/analytics_models.dart';
import '../../widgets/category_pie_chart.dart';

/// Group Analytics Screen
class GroupAnalyticsScreen extends StatefulWidget {
  final String groupId;

  const GroupAnalyticsScreen({super.key, required this.groupId});

  @override
  State<GroupAnalyticsScreen> createState() => _GroupAnalyticsScreenState();
}

class _GroupAnalyticsScreenState extends State<GroupAnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.thisMonth;
  GroupAnalytics? _analytics;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    final analyticsProvider = Provider.of<AnalyticsProvider>(
      context,
      listen: false,
    );

    try {
      await analyticsProvider.loadGroupAnalytics([widget.groupId]);
      if (analyticsProvider.groupAnalytics.isNotEmpty) {
        setState(() {
          _analytics = analyticsProvider.groupAnalytics.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
          PopupMenuButton<AnalyticsPeriod>(
            icon: const Icon(Icons.date_range),
            onSelected: (period) {
              setState(() => _selectedPeriod = period);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AnalyticsPeriod.thisWeek,
                child: Text('This Week'),
              ),
              const PopupMenuItem(
                value: AnalyticsPeriod.thisMonth,
                child: Text('This Month'),
              ),
              const PopupMenuItem(
                value: AnalyticsPeriod.thisYear,
                child: Text('This Year'),
              ),
              const PopupMenuItem(
                value: AnalyticsPeriod.last30Days,
                child: Text('Last 30 Days'),
              ),
              const PopupMenuItem(
                value: AnalyticsPeriod.allTime,
                child: Text('All Time'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analytics == null
          ? const Center(child: Text('No data available'))
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Period selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedPeriod.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Group summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _analytics!.groupName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            'Total Spent',
                            '\$${_analytics!.totalSpent.toStringAsFixed(2)}',
                            Icons.shopping_cart,
                            Colors.blue,
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            'Total Expenses',
                            '${_analytics!.expenseCount}',
                            Icons.receipt,
                            Colors.green,
                          ),
                          if (_analytics!.lastExpenseDate != null) ...[
                            const Divider(),
                            _buildSummaryRow(
                              'Last Expense',
                              _formatDate(_analytics!.lastExpenseDate!),
                              Icons.access_time,
                              Colors.grey,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category breakdown
                  if (_analytics!.categoryBreakdown.isNotEmpty) ...[
                    const Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CategoryPieChart(categories: _buildCategorySpending()),
                    const SizedBox(height: 16),
                  ],

                  // Member spending
                  if (_analytics!.memberSpending.isNotEmpty) ...[
                    const Text(
                      'Spending by Member',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: _analytics!.memberSpending.entries
                            .map(
                              (entry) => ListTile(
                                leading: CircleAvatar(
                                  child: Text(entry.key[0].toUpperCase()),
                                ),
                                title: Text(
                                  'User ${entry.key.substring(0, 8)}',
                                ),
                                trailing: Text(
                                  '\$${entry.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon,
    Color color,
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
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<CategorySpending> _buildCategorySpending() {
    final total = _analytics!.categoryBreakdown.values.fold(
      0.0,
      (a, b) => a + b,
    );
    return _analytics!.categoryBreakdown.entries.map((entry) {
      return CategorySpending(
        category: entry.key,
        amount: entry.value,
        count: 0,
        percentage: (entry.value / total) * 100,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
