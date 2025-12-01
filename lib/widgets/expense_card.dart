import 'package:flutter/material.dart';
import 'package:splitly/models/expense_model.dart';
import 'package:splitly/utils/design_system.dart';
import 'package:splitly/utils/locale_utils.dart';

/// Custom card widget to display expense with split info
class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;
  final String currentUserId;
  final Locale locale;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
    required this.currentUserId,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate user's share
    double userShare = 0.0;
    for (var participant in expense.participants) {
      if (participant.userId == currentUserId) {
        userShare = participant.splitAmount;
        break;
      }
    }

    final bool isPayer = expense.payerId == currentUserId;
    final categoryColor =
        AppColors.categoryColors[expense.category] ?? AppColors.textTertiary;

    return Card(
      margin: AppSpacing.paddingVerticalSM,
      elevation: AppElevation.sm,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusSM),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.radiusSM,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.radiusSM,
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: categoryColor,
                      size: AppConstants.iconSizeMD,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Description and Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description ?? 'No description',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: AppTypography.fontWeightSemiBold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocaleUtils.formatDate(expense.date, locale),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        LocaleUtils.formatCurrency(
                          expense.amount,
                          expense.currency,
                          locale,
                        ),
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: AppTypography.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPayer ? 'You paid' : 'Your share',
                        style: AppTypography.bodySmall.copyWith(
                          color: isPayer
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Split Info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppBorderRadius.radiusSM,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSplitTypeIcon(expense.splitType),
                      size: AppConstants.iconSizeSM,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_getSplitTypeLabel(expense.splitType)} • ${expense.participants.length} people',
                      style: AppTypography.bodySmall,
                    ),
                    if (!isPayer) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        LocaleUtils.formatCurrency(
                          userShare,
                          expense.currency,
                          locale,
                        ),
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: AppTypography.fontWeightSemiBold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        return Icons.local_hospital;
      case 'SUBSCRIPTION':
        return Icons.subscriptions;
      default:
        return Icons.category;
    }
  }

  IconData _getSplitTypeIcon(SplitType splitType) {
    switch (splitType) {
      case SplitType.equal:
        return Icons.people;
      case SplitType.unequal:
        return Icons.format_list_numbered;
      case SplitType.percentage:
        return Icons.percent;
      case SplitType.shares:
        return Icons.pie_chart;
    }
  }

  String _getSplitTypeLabel(SplitType splitType) {
    switch (splitType) {
      case SplitType.equal:
        return 'Equal split';
      case SplitType.unequal:
        return 'Unequal split';
      case SplitType.percentage:
        return 'Percentage split';
      case SplitType.shares:
        return 'Shares split';
    }
  }
}
