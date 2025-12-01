import 'package:flutter/material.dart';
import 'package:splitly/utils/design_system.dart';
import 'package:splitly/utils/locale_utils.dart';

/// Custom card widget to show balance between two people
class DebtCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final double amount;
  final String currency;
  final bool isOwed; // true if they owe you, false if you owe them
  final VoidCallback onTap;
  final VoidCallback? onSettle;
  final Locale locale;

  const DebtCard({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.currency,
    required this.isOwed,
    required this.onTap,
    this.onSettle,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final absAmount = amount.abs();
    final color = isOwed ? AppColors.success : AppColors.warning;

    return Card(
      margin: AppSpacing.paddingVerticalSM,
      elevation: AppElevation.sm,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusSM),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.radiusSM,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: AppTypography.h4.copyWith(color: color),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOwed ? 'owes you' : 'you owe',
                      style: AppTypography.bodySmall.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              // Amount and Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    LocaleUtils.formatCurrency(absAmount, currency, locale),
                    style: AppTypography.h4.copyWith(
                      color: color,
                      fontWeight: AppTypography.fontWeightBold,
                    ),
                  ),
                  if (onSettle != null) ...[
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: onSettle,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Settle',
                        style: AppTypography.bodySmall.copyWith(
                          color: color,
                          fontWeight: AppTypography.fontWeightSemiBold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
