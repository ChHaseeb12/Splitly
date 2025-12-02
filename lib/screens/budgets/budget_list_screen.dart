import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/budget_model.dart';
import '../../utils/design_system.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import 'create_budget_screen.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final budgetProvider = Provider.of<BudgetProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        budgetProvider.loadBudgets(authProvider.currentUser!.uid);
        budgetProvider.checkAlerts(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: budgetProvider.isLoading
          ? const LoadingState(message: 'Loading budgets...')
          : Column(
              children: [
                // Budget Alerts
                if (budgetProvider.alerts.isNotEmpty)
                  Container(
                    color: AppColors.error.withValues(alpha: 0.1),
                    padding: AppSpacing.paddingMD,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: AppColors.error),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Budget Alerts',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.sm),
                        ...budgetProvider.alerts.map(
                          (budget) => Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Text(
                              budget.isOverBudget
                                  ? '${budget.name}: Over budget by \$${(budget.spent - budget.amount).toStringAsFixed(2)}'
                                  : '${budget.name}: ${budget.percentageUsed.toStringAsFixed(0)}% used',
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Budget List
                Expanded(
                  child: budgetProvider.budgets.isEmpty
                      ? EmptyState(
                          icon: Icons.account_balance_wallet,
                          title: 'No Budgets',
                          message: 'Create a budget to track your spending',
                          actionLabel: 'Create Budget',
                          onAction: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateBudgetScreen(),
                              ),
                            );
                          },
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (authProvider.currentUser != null) {
                              budgetProvider.loadBudgets(
                                authProvider.currentUser!.uid,
                              );
                            }
                          },
                          child: ListView.builder(
                            padding: AppSpacing.paddingMD,
                            itemCount: budgetProvider.budgets.length,
                            itemBuilder: (context, index) {
                              final budget = budgetProvider.budgets[index];
                              return _BudgetCard(budget: budget);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final percentage = budget.percentageUsed.clamp(0.0, 100.0);
    final isOverBudget = budget.isOverBudget;
    final isNearLimit = budget.isNearLimit;

    Color progressColor;
    if (isOverBudget) {
      progressColor = AppColors.error;
    } else if (isNearLimit) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.success;
    }

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(budget.name, style: AppTypography.h4),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        _getPeriodText(budget.period),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (budget.category != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.categoryColors[budget.category]
                          ?.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.radiusSM,
                    ),
                    child: Text(
                      budget.category!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.categoryColors[budget.category],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Progress Bar
            ClipRRect(
              borderRadius: AppBorderRadius.radiusSM,
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            SizedBox(height: AppSpacing.sm),

            // Amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${budget.spent.toStringAsFixed(2)}',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Budget',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${budget.amount.toStringAsFixed(2)}',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),

            // Remaining
            Text(
              isOverBudget
                  ? 'Over budget by \$${(budget.spent - budget.amount).toStringAsFixed(2)}'
                  : 'Remaining: \$${budget.remaining.toStringAsFixed(2)} (${(100 - percentage).toStringAsFixed(0)}%)',
              style: AppTypography.bodyMedium.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodText(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.DAILY:
        return 'Daily Budget';
      case BudgetPeriod.WEEKLY:
        return 'Weekly Budget';
      case BudgetPeriod.MONTHLY:
        return 'Monthly Budget';
      case BudgetPeriod.QUARTERLY:
        return 'Quarterly Budget';
      case BudgetPeriod.YEARLY:
        return 'Yearly Budget';
      case BudgetPeriod.CUSTOM:
        return 'Custom Period';
    }
  }
}
