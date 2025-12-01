import 'package:flutter/material.dart';
import 'package:splitly/models/group_model.dart';
import 'package:splitly/utils/design_system.dart';
import 'package:splitly/utils/locale_utils.dart';

/// Custom card widget for group overview with member count and balance
class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onTap;
  final double? balance; // Optional balance to display
  final String? currency;
  final Locale locale;

  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.balance,
    this.currency,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final memberCount = group.members.length;
    final hasBalance = balance != null && balance != 0;

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
              // Group Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.radiusMD,
                ),
                child: const Icon(
                  Icons.group,
                  size: AppConstants.iconSizeLG,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Group Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: AppTypography.fontWeightSemiBold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: AppConstants.iconSizeSM,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    if (group.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Balance (if provided)
              if (hasBalance) ...[
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      LocaleUtils.formatCurrency(
                        balance!.abs(),
                        currency ?? group.currency,
                        locale,
                      ),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: AppTypography.fontWeightBold,
                        color: balance! > 0
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      balance! > 0 ? 'you are owed' : 'you owe',
                      style: AppTypography.bodySmall.copyWith(
                        color: balance! > 0
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
