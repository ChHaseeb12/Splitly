import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification_model.dart';
import '../../utils/design_system.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import 'notification_settings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        notificationProvider.loadNotifications(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton(
              onPressed: () {
                if (authProvider.currentUser != null) {
                  notificationProvider.markAllAsRead(
                    authProvider.currentUser!.uid,
                  );
                }
              },
              child: const Text('Mark all read'),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: notificationProvider.isLoading
          ? const LoadingState(message: 'Loading notifications...')
          : notificationProvider.notifications.isEmpty
          ? EmptyState(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              message: 'You don\'t have any notifications yet',
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (authProvider.currentUser != null) {
                  notificationProvider.loadNotifications(
                    authProvider.currentUser!.uid,
                  );
                }
              },
              child: ListView.builder(
                padding: AppSpacing.paddingMD,
                itemCount: notificationProvider.notifications.length,
                itemBuilder: (context, index) {
                  final notification =
                      notificationProvider.notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () {
                      notificationProvider.markAsRead(notification.id);
                      _handleNotificationTap(context, notification);
                    },
                    onDismiss: () {
                      notificationProvider.deleteNotification(notification.id);
                    },
                  );
                },
              ),
            ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.EXPENSE_ADDED:
      case NotificationType.EXPENSE_UPDATED:
        // Navigate to expense detail
        break;
      case NotificationType.FRIEND_REQUEST:
        // Navigate to friend requests
        break;
      case NotificationType.GROUP_INVITE:
        // Navigate to group detail
        break;
      default:
        break;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: AppSpacing.paddingMD,
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        color: notification.isRead
            ? null
            : AppColors.primary.withValues(alpha: 0.05),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getIconColor(
              notification.type,
            ).withValues(alpha: 0.1),
            child: Icon(
              _getIcon(notification.type),
              color: _getIconColor(notification.type),
            ),
          ),
          title: Text(
            notification.title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.xs),
              Text(notification.body),
              SizedBox(height: AppSpacing.xs),
              Text(
                _formatTime(notification.createdAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.EXPENSE_ADDED:
      case NotificationType.EXPENSE_UPDATED:
        return Icons.receipt;
      case NotificationType.FRIEND_REQUEST:
      case NotificationType.FRIEND_ACCEPTED:
        return Icons.person_add;
      case NotificationType.PAYMENT_RECEIVED:
      case NotificationType.PAYMENT_SENT:
        return Icons.payment;
      case NotificationType.GROUP_INVITE:
      case NotificationType.GROUP_EXPENSE:
        return Icons.group;
      case NotificationType.COMMENT_ADDED:
        return Icons.comment;
      case NotificationType.BUDGET_ALERT:
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.EXPENSE_ADDED:
      case NotificationType.EXPENSE_UPDATED:
        return AppColors.info;
      case NotificationType.FRIEND_REQUEST:
      case NotificationType.FRIEND_ACCEPTED:
        return AppColors.success;
      case NotificationType.PAYMENT_RECEIVED:
        return AppColors.success;
      case NotificationType.PAYMENT_SENT:
        return AppColors.warning;
      case NotificationType.BUDGET_ALERT:
        return AppColors.error;
      default:
        return AppColors.primary;
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
