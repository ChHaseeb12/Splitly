import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';

/// Provider for managing sync state
class SyncProvider with ChangeNotifier {
  final SyncService _syncService;
  final ConnectivityService _connectivityService;
  final LocalStorageService _localStorageService;

  bool _isInitialized = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _syncError;
  bool _isOnline = true;
  int _queueSize = 0;

  SyncProvider(
    this._syncService,
    this._connectivityService,
    this._localStorageService,
  );

  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;
  bool get isOnline => _isOnline;
  int get queueSize => _queueSize;

  /// Initialize sync provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize connectivity service
      await _connectivityService.initialize();
      _isOnline = _connectivityService.isOnline;

      // Listen to connectivity changes
      _connectivityService.connectivityStream.listen((online) {
        _isOnline = online;
        notifyListeners();

        // Auto-sync when coming online
        if (online && !_isSyncing) {
          syncAll();
        }
      });

      // Start auto-sync
      _syncService.startAutoSync();

      // Load last sync time
      _lastSyncTime = _localStorageService.getLastSyncTime();
      _queueSize = _syncService.getQueueSize();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing sync provider: $e');
      _syncError = e.toString();
      notifyListeners();
    }
  }

  /// Sync all pending operations
  Future<bool> syncAll() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final success = await _syncService.syncAll();
      _lastSyncTime = _syncService.lastSyncTime;
      _syncError = _syncService.syncError;
      _queueSize = _syncService.getQueueSize();
      return success;
    } catch (e) {
      _syncError = e.toString();
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Fetch data from Firestore
  Future<void> fetchFromFirestore(String userId) async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      await _syncService.fetchFromFirestore(userId);
      _lastSyncTime = _syncService.lastSyncTime;
      _queueSize = _syncService.getQueueSize();
    } catch (e) {
      _syncError = e.toString();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Queue an operation for sync
  Future<void> queueOperation({
    required String operation,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _syncService.queueOperation(
      operation: operation,
      collection: collection,
      documentId: documentId,
      data: data,
    );
    _queueSize = _syncService.getQueueSize();
    notifyListeners();
  }

  /// Clear sync queue
  Future<void> clearQueue() async {
    await _syncService.clearQueue();
    _queueSize = 0;
    _syncError = null;
    notifyListeners();
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return _syncService.getSyncStats();
  }

  /// Get storage statistics
  Map<String, int> getStorageStats() {
    return _localStorageService.getStorageStats();
  }

  /// Get time since last sync
  String getTimeSinceLastSync() {
    if (_lastSyncTime == null) return 'Never';

    final difference = DateTime.now().difference(_lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
