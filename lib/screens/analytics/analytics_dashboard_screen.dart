import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/analytics_models.dart';
import '../../widgets/spending_summary_card.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/spending_trend_chart.dart';
import '../../widgets/debt_summary_card.dart';

/// Analytics Dashboard Screen
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  Future<void> _loadAnalytics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await analyticsProvider.loadAnalytics(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
          PopupMenuButton<AnalyticsPeriod>(
            icon: const Icon(Icons.date_range),
            onSelected: (period) {
              Provider.of<AnalyticsProvider>(
                context,
                listen: false,
              ).setSelectedPeriod(period);
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
                value: AnalyticsPeriod.last90Days,
                child: Text('Last 90 Days'),
              ),
              const PopupMenuItem(
                value: AnalyticsPeriod.allTime,
                child: Text('All Time'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, child) {
          if (analyticsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (analyticsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${analyticsProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAnalytics,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAnalytics,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Period selector
                _buildPeriodSelector(analyticsProvider),
                const SizedBox(height: 16),

                // Spending summary
                if (analyticsProvider.spendingSummary != null)
                  SpendingSummaryCard(
                    summary: analyticsProvider.spendingSummary!,
                  ),
                const SizedBox(height: 16),

                // Debt summary
                if (analyticsProvider.debtAnalytics != null)
                  DebtSummaryCard(analytics: analyticsProvider.debtAnalytics!),
                const SizedBox(height: 16),

                // Category breakdown
                if (analyticsProvider.categorySpending.isNotEmpty) ...[
                  const Text(
                    'Spending by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CategoryPieChart(
                    categories: analyticsProvider.categorySpending,
                  ),
                  const SizedBox(height: 16),
                ],

                // Spending trend
                if (analyticsProvider.spendingTrend.isNotEmpty) ...[
                  const Text(
                    'Spending Trend',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SpendingTrendChart(
                    trendPoints: analyticsProvider.spendingTrend,
                  ),
                  const SizedBox(height: 16),
                ],

                // Empty state
                if (analyticsProvider.spendingSummary?.expenseCount == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No expenses in this period',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(AnalyticsProvider provider) {
    return Card(
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Select Period',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildPeriodOption(
                    AnalyticsPeriod.thisWeek,
                    'This Week',
                    provider,
                  ),
                  _buildPeriodOption(
                    AnalyticsPeriod.thisMonth,
                    'This Month',
                    provider,
                  ),
                  _buildPeriodOption(
                    AnalyticsPeriod.thisYear,
                    'This Year',
                    provider,
                  ),
                  _buildPeriodOption(
                    AnalyticsPeriod.last30Days,
                    'Last 30 Days',
                    provider,
                  ),
                  _buildPeriodOption(
                    AnalyticsPeriod.last90Days,
                    'Last 90 Days',
                    provider,
                  ),
                  _buildPeriodOption(
                    AnalyticsPeriod.allTime,
                    'All Time',
                    provider,
                  ),
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Period',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.selectedPeriod.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodOption(
    AnalyticsPeriod period,
    String label,
    AnalyticsProvider provider,
  ) {
    final isSelected = provider.selectedPeriod == period;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      onTap: () {
        provider.setSelectedPeriod(period);
        Navigator.pop(context);
        _loadAnalytics();
      },
    );
  }
}
