import 'package:flutter/material.dart';
import 'package:splitly/utils/design_system.dart';

/// Loading indicators with consistent styling
class LoadingState extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const LoadingState({super.key, this.message, this.isFullScreen = true});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.primary),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Center(
        child: Padding(padding: AppSpacing.paddingXL, child: content),
      );
    }

    return content;
  }
}

/// Loading skeleton for list items
class LoadingSkeleton extends StatefulWidget {
  final int itemCount;
  final double height;

  const LoadingSkeleton({super.key, this.itemCount = 5, this.height = 80});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      padding: AppSpacing.paddingMD,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: widget.height,
              margin: AppSpacing.paddingVerticalSM,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppBorderRadius.radiusSM,
                boxShadow: AppElevation.shadowSM,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: AppBorderRadius.radiusSM,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.surfaceVariant,
                              AppColors.border,
                              AppColors.surfaceVariant,
                            ],
                            stops: [
                              _animation.value - 0.3,
                              _animation.value,
                              _animation.value + 0.3,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
