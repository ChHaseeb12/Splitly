import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/design_system.dart';
import '../../widgets/loading_state.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
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
        notificationProvider.loadPreferences(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final preferences = notificationProvider.preferences;

    if (preferences == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification Settings')),
        body: const LoadingState(message: 'Loading preferences...'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: AppSpacing.paddingMD,
        children: [
          // Push Notifications
          Card(
            child: SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications on your device'),
              value: preferences.pushNotifications,
              onChanged: (value) {
                final updated = preferences.copyWith(pushNotifications: value);
                notificationProvider.updatePreferences(updated);
              },
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Email Notifications
          Card(
            child: SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive notifications via email'),
              value: preferences.emailNotifications,
              onChanged: (value) {
                final updated = preferences.copyWith(emailNotifications: value);
                notificationProvider.updatePreferences(updated);
              },
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Notification Types
          Text('Notification Types', style: AppTypography.h4),
          SizedBox(height: AppSpacing.md),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Expense Notifications'),
                  subtitle: const Text('New expenses, updates, and deletions'),
                  value: preferences.expenseNotifications,
                  onChanged: (value) {
                    final updated = preferences.copyWith(
                      expenseNotifications: value,
                    );
                    notificationProvider.updatePreferences(updated);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Friend Notifications'),
                  subtitle: const Text('Friend requests and acceptances'),
                  value: preferences.friendNotifications,
                  onChanged: (value) {
                    final updated = preferences.copyWith(
                      friendNotifications: value,
                    );
                    notificationProvider.updatePreferences(updated);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Payment Notifications'),
                  subtitle: const Text('Payment received and sent'),
                  value: preferences.paymentNotifications,
                  onChanged: (value) {
                    final updated = preferences.copyWith(
                      paymentNotifications: value,
                    );
                    notificationProvider.updatePreferences(updated);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Group Notifications'),
                  subtitle: const Text('Group invites and activities'),
                  value: preferences.groupNotifications,
                  onChanged: (value) {
                    final updated = preferences.copyWith(
                      groupNotifications: value,
                    );
                    notificationProvider.updatePreferences(updated);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Budget Notifications'),
                  subtitle: const Text('Budget alerts and warnings'),
                  value: preferences.budgetNotifications,
                  onChanged: (value) {
                    final updated = preferences.copyWith(
                      budgetNotifications: value,
                    );
                    notificationProvider.updatePreferences(updated);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Information
          Card(
            color: AppColors.info.withValues(alpha: 0.1),
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'About Notifications',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'You can customize which notifications you receive. '
                    'Push notifications require device permissions. '
                    'Email notifications will be sent to your registered email address.',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
