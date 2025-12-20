import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/comment_model.dart';
import '../../utils/design_system.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';

class ActivityFeedScreen extends StatefulWidget {
  final String? groupId;

  const ActivityFeedScreen({super.key, this.groupId});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final commentProvider = Provider.of<CommentProvider>(
        context,
        listen: false,
      );

      if (widget.groupId != null) {
        commentProvider.loadGroupActivity(widget.groupId!);
      } else if (authProvider.currentUser != null) {
        commentProvider.loadUserActivity(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupId != null ? 'Group Activity' : 'Activity Feed',
        ),
      ),
      body: commentProvider.isLoading
          ? const LoadingState(message: 'Loading activity...')
          : commentProvider.activities.isEmpty
          ? EmptyState(
              icon: Icons.feed,
              title: 'No Activity',
              message: 'No recent activity to show',
            )
          : RefreshIndicator(
              onRefresh: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                if (widget.groupId != null) {
                  commentProvider.loadGroupActivity(widget.groupId!);
                } else if (authProvider.currentUser != null) {
                  commentProvider.loadUserActivity(
                    authProvider.currentUser!.uid,
                  );
                }
              },
              child: ListView.builder(
                padding: AppSpacing.paddingMD,
                itemCount: commentProvider.activities.length,
                itemBuilder: (context, index) {
                  final activity = commentProvider.activities[index];
                  return _ActivityCard(activity: activity);
                },
              ),
            ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityFeedItem activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getIconColor(activity.type).withValues(alpha: 0.1),
          child: Icon(
            _getIcon(activity.type),
            color: _getIconColor(activity.type),
          ),
        ),
        title: Text(
          activity.userName,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.xs),
            Text(activity.description),
            SizedBox(height: AppSpacing.xs),
            Text(
              _formatTime(activity.createdAt),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(ActivityType type) {
    switch (type) {
      case ActivityType.EXPENSE_ADDED:
        return Icons.add_circle;
      case ActivityType.EXPENSE_UPDATED:
        return Icons.edit;
      case ActivityType.EXPENSE_DELETED:
        return Icons.delete;
      case ActivityType.PAYMENT_MADE:
      case ActivityType.SETTLEMENT_MADE:
        return Icons.payment;
      case ActivityType.COMMENT_ADDED:
        return Icons.comment;
      case ActivityType.MEMBER_ADDED:
        return Icons.person_add;
      case ActivityType.MEMBER_REMOVED:
        return Icons.person_remove;
      case ActivityType.FRIEND_REQUEST_SENT:
        return Icons.send;
      case ActivityType.FRIEND_REQUEST_ACCEPTED:
        return Icons.check_circle;
      case ActivityType.FRIEND_REMOVED:
        return Icons.person_off;
      case ActivityType.GROUP_CREATED:
        return Icons.group_add;
      case ActivityType.GROUP_DELETED:
        return Icons.group_remove;
      default:
        return Icons.info;
    }
  }

  Color _getIconColor(ActivityType type) {
    switch (type) {
      case ActivityType.EXPENSE_ADDED:
        return AppColors.success;
      case ActivityType.EXPENSE_UPDATED:
        return AppColors.info;
      case ActivityType.EXPENSE_DELETED:
        return AppColors.error;
      case ActivityType.PAYMENT_MADE:
      case ActivityType.SETTLEMENT_MADE:
        return AppColors.success;
      case ActivityType.COMMENT_ADDED:
        return AppColors.info;
      case ActivityType.MEMBER_ADDED:
      case ActivityType.FRIEND_REQUEST_ACCEPTED:
        return AppColors.success;
      case ActivityType.MEMBER_REMOVED:
      case ActivityType.FRIEND_REMOVED:
        return AppColors.warning;
      case ActivityType.FRIEND_REQUEST_SENT:
        return AppColors.info;
      case ActivityType.GROUP_CREATED:
        return AppColors.primary;
      case ActivityType.GROUP_DELETED:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
