import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';

/// Widget to display sync status in app bar
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        if (!syncProvider.isInitialized) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Connectivity indicator
              Icon(
                syncProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: syncProvider.isOnline ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 4),

              // Sync indicator
              if (syncProvider.isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              else if (syncProvider.queueSize > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${syncProvider.queueSize}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Bottom banner to show sync status
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        if (!syncProvider.isInitialized) {
          return const SizedBox.shrink();
        }

        // Show banner only when offline or syncing
        if (syncProvider.isOnline && !syncProvider.isSyncing) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: syncProvider.isOnline ? Colors.blue : Colors.grey[800],
          child: Row(
            children: [
              Icon(
                syncProvider.isSyncing ? Icons.sync : Icons.cloud_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  syncProvider.isSyncing
                      ? 'Syncing...'
                      : 'Offline - Changes will sync when online',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (syncProvider.queueSize > 0)
                Text(
                  '${syncProvider.queueSize} pending',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
            ],
          ),
        );
      },
    );
  }
}
