import 'package:flutter/material.dart';
import 'package:splitly/utils/design_system.dart';

/// Filterable category selector chip
class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        AppColors.categoryColors[category] ?? AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor.withValues(alpha: 0.2)
              : AppColors.surfaceVariant,
          borderRadius: AppBorderRadius.radiusRound,
          border: Border.all(
            color: isSelected ? categoryColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: AppConstants.iconSizeSM,
              color: isSelected ? categoryColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _getCategoryLabel(category),
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? categoryColor : AppColors.textSecondary,
                fontWeight: isSelected
                    ? AppTypography.fontWeightSemiBold
                    : AppTypography.fontWeightRegular,
              ),
            ),
          ],
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

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'FOOD':
        return 'Food';
      case 'ENTERTAINMENT':
        return 'Entertainment';
      case 'UTILITIES':
        return 'Utilities';
      case 'TRANSPORTATION':
        return 'Transportation';
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
      default:
        return 'Other';
    }
  }
}
