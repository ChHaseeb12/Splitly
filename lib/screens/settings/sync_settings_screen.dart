import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sync_provider.dart';

/// Screen for managing sync settings and viewing sync status
class SyncSettingsScreen extends StatelessWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync & Offline'), elevation: 0),
      body: Consumer<SyncProvider>(
        builder: (context, syncProvider, child) {
          if (!syncProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = syncProvider.getSyncStats();
          final storageStats = syncProvider.getStorageStats();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connectivity Status
              _buildSection(
                title: 'Connection Status',
                children: [
                  _buildStatusTile(
                    icon: syncProvider.isOnline
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    iconColor: syncProvider.isOnline
                        ? Colors.green
                        : Colors.grey,
                    title: syncProvider.isOnline ? 'Online' : 'Offline',
                    subtitle: syncProvider.isOnline
                        ? 'Connected to internet'
                        : 'No internet connection',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sync Status
              _buildSection(
                title: 'Sync Status',
                children: [
                  _buildInfoTile(
                    icon: Icons.sync,
                    title: 'Last Synced',
                    value: syncProvider.getTimeSinceLastSync(),
                  ),
                  _buildInfoTile(
                    icon: Icons.pending_actions,
                    title: 'Pending Changes',
                    value: '${syncProvider.queueSize}',
                  ),
                  if (syncProvider.syncError != null)
                    _buildInfoTile(
                      icon: Icons.error_outline,
                      title: 'Last Error',
                      value: syncProvider.syncError!,
                      valueColor: Colors.red,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Sync Actions
              if (syncProvider.isOnline) ...[
                ElevatedButton.icon(
                  onPressed: syncProvider.isSyncing
                      ? null
                      : () => _syncNow(context, syncProvider),
                  icon: syncProvider.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    syncProvider.isSyncing ? 'Syncing...' : 'Sync Now',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (syncProvider.queueSize > 0)
                OutlinedButton.icon(
                  onPressed: () => _clearQueue(context, syncProvider),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Pending Changes'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.red,
                  ),
                ),

              const SizedBox(height: 24),

              // Local Storage
              _buildSection(
                title: 'Local Storage',
                children: [
                  _buildInfoTile(
                    icon: Icons.receipt_long,
                    title: 'Expenses',
                    value: '${storageStats['expenses']}',
                  ),
                  _buildInfoTile(
                    icon: Icons.group,
                    title: 'Groups',
                    value: '${storageStats['groups']}',
                  ),
                  _buildInfoTile(
                    icon: Icons.people,
                    title: 'Friends',
                    value: '${storageStats['friends']}',
                  ),
                  _buildInfoTile(
                    icon: Icons.repeat,
                    title: 'Recurring Expenses',
                    value: '${storageStats['recurring']}',
                  ),
                  _buildInfoTile(
                    icon: Icons.bookmark,
                    title: 'Saved Splits',
                    value: '${storageStats['savedSplits']}',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Information
              _buildSection(
                title: 'How It Works',
                children: [
                  _buildInfoCard(
                    icon: Icons.offline_bolt,
                    title: 'Offline Mode',
                    description:
                        'All data is stored locally on your device. You can view and create expenses even without internet.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.cloud_sync,
                    title: 'Automatic Sync',
                    description:
                        'Changes are automatically synced to the cloud when you\'re online. Pending changes are queued and synced later.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.security,
                    title: 'Data Safety',
                    description:
                        'Your data is securely stored both locally and in the cloud. Local data is encrypted on your device.',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Debug Info (only in development)
              if (stats['syncedItems'] > 0 || stats['failedItems'] > 0)
                _buildSection(
                  title: 'Sync Statistics',
                  children: [
                    _buildInfoTile(
                      icon: Icons.check_circle,
                      title: 'Synced Items',
                      value: '${stats['syncedItems']}',
                    ),
                    _buildInfoTile(
                      icon: Icons.error,
                      title: 'Failed Items',
                      value: '${stats['failedItems']}',
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildStatusTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: valueColor ?? Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncNow(BuildContext context, SyncProvider syncProvider) async {
    final success = await syncProvider.syncAll();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Sync completed successfully'
                : 'Sync completed with errors',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _clearQueue(
    BuildContext context,
    SyncProvider syncProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Pending Changes?'),
        content: const Text(
          'This will remove all pending changes from the sync queue. '
          'These changes will not be synced to the cloud.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await syncProvider.clearQueue();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pending changes cleared')),
        );
      }
    }
  }
}
