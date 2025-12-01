import 'package:flutter/material.dart';
import 'package:splitly/utils/design_system.dart';
import 'package:splitly/utils/locale_utils.dart';

/// Visual representation of expense split
class SplitPreview extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final String currency;
  final double totalAmount;
  final String splitType;
  final Locale locale;

  const SplitPreview({
    super.key,
    required this.participants,
    required this.currency,
    required this.totalAmount,
    required this.splitType,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppBorderRadius.radiusMD,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                _getSplitTypeIcon(splitType),
                size: AppConstants.iconSizeMD,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Split Preview',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
              const Spacer(),
              Text(
                LocaleUtils.formatCurrency(totalAmount, currency, locale),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: AppTypography.fontWeightBold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Participants List
          ...participants.map((participant) {
            final amount = (participant['amount'] as num).toDouble();
            final percentage = (amount / totalAmount * 100);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                children: [
                  Row(
                    children: [
                      // User Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          (participant['userName'] as String).isNotEmpty
                              ? (participant['userName'] as String)[0]
                                    .toUpperCase()
                              : '?',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: AppTypography.fontWeightSemiBold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // User Name
                      Expanded(
                        child: Text(
                          participant['userName'] as String,
                          style: AppTypography.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Amount and Percentage
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            LocaleUtils.formatCurrency(
                              amount,
                              currency,
                              locale,
                            ),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: AppTypography.fontWeightSemiBold,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: AppBorderRadius.radiusRound,
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primary.withValues(alpha: 0.7),
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getSplitTypeIcon(String splitType) {
    switch (splitType) {
      case 'EQUAL':
        return Icons.people;
      case 'UNEQUAL':
        return Icons.format_list_numbered;
      case 'PERCENTAGE':
        return Icons.percent;
      case 'SHARES':
        return Icons.pie_chart;
      default:
        return Icons.people;
    }
  }
}
