import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sync_queue_item.dart';
import '../models/expense_model.dart';
import '../models/group_model.dart';
import '../models/friend_model.dart';
import '../models/recurring_expense_model.dart';
import '../models/saved_split_model.dart';
import 'local_storage_service.dart';
import 'connectivity_service.dart';

/// Service for synchronizing local data with Firestore
class SyncService {
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _syncError;
  int _syncedItems = 0;
  int _failedItems = 0;

  SyncService(this._localStorage, this._connectivity);

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;
  int get syncedItems => _syncedItems;
  int get failedItems => _failedItems;

  /// Start automatic sync when connectivity is restored
  void startAutoSync() {
    _connectivity.connectivityStream.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        syncAll();
      }
    });
  }

  /// Sync all pending operations
  Future<bool> syncAll() async {
    if (_isSyncing) {
      print('Sync already in progress');
      return false;
    }

    if (!_connectivity.isOnline) {
      _syncError = 'No internet connection';
      return false;
    }

    _isSyncing = true;
    _syncError = null;
    _syncedItems = 0;
    _failedItems = 0;

    try {
      print('Starting sync...');

      // Get all pending sync items
      final queue = _localStorage.getSyncQueue();
      print('Found ${queue.length} items to sync');

      for (final item in queue) {
        try {
          await _processSyncItem(item);
          await _localStorage.removeFromSyncQueue(item.id);
          _syncedItems++;
          print('Synced: ${item.collection}/${item.documentId}');
        } catch (e) {
          _failedItems++;
          print('Failed to sync: ${item.collection}/${item.documentId} - $e');

          // Update retry count
          final updatedItem = item.copyWith(
            retryCount: item.retryCount + 1,
            error: e.toString(),
          );
          await _localStorage.updateSyncQueueItem(updatedItem);

          // Remove from queue if too many retries
          if (updatedItem.retryCount >= 3) {
            await _localStorage.removeFromSyncQueue(item.id);
            print('Removed from queue after 3 failed attempts');
          }
        }
      }

      // Update last sync time
      _lastSyncTime = DateTime.now();
      await _localStorage.setLastSyncTime(_lastSyncTime!);

      print('Sync completed: $_syncedItems synced, $_failedItems failed');
      return _failedItems == 0;
    } catch (e) {
      _syncError = e.toString();
      print('Sync error: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single sync item
  Future<void> _processSyncItem(SyncQueueItem item) async {
    final collection = _firestore.collection(item.collection);

    switch (item.operation) {
      case 'CREATE':
      case 'UPDATE':
        await collection
            .doc(item.documentId)
            .set(item.data, SetOptions(merge: true));
        break;

      case 'DELETE':
        await collection.doc(item.documentId).delete();
        break;

      default:
        throw Exception('Unknown operation: ${item.operation}');
    }
  }

  /// Add operation to sync queue
  Future<void> queueOperation({
    required String operation,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final item = SyncQueueItem(
      id: '${collection}_${documentId}_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      collection: collection,
      documentId: documentId,
      data: data,
      timestamp: DateTime.now(),
    );

    await _localStorage.addToSyncQueue(item);
    print('Queued: $operation ${item.collection}/${item.documentId}');

    // Try to sync immediately if online
    if (_connectivity.isOnline && !_isSyncing) {
      syncAll();
    }
  }

  /// Fetch data from Firestore and update local storage
  Future<void> fetchFromFirestore(String userId) async {
    if (!_connectivity.isOnline) {
      throw Exception('No internet connection');
    }

    try {
      print('Fetching data from Firestore...');

      // Fetch expenses
      final expensesSnapshot = await _firestore
          .collection('expenses')
          .where('participants', arrayContains: userId)
          .get();

      for (final doc in expensesSnapshot.docs) {
        final expense = ExpenseModel.fromJson(doc.data());
        await _localStorage.saveExpense(expense);
      }
      print('Fetched ${expensesSnapshot.docs.length} expenses');

      // Fetch groups
      final groupsSnapshot = await _firestore
          .collection('groups')
          .where('members', arrayContains: userId)
          .get();

      for (final doc in groupsSnapshot.docs) {
        final group = GroupModel.fromJson(doc.data());
        await _localStorage.saveGroup(group);
      }
      print('Fetched ${groupsSnapshot.docs.length} groups');

      // Fetch friends
      final friendsSnapshot1 = await _firestore
          .collection('friends')
          .where('userId1', isEqualTo: userId)
          .get();

      final friendsSnapshot2 = await _firestore
          .collection('friends')
          .where('userId2', isEqualTo: userId)
          .get();

      for (final doc in [...friendsSnapshot1.docs, ...friendsSnapshot2.docs]) {
        final friend = FriendModel.fromJson(doc.data());
        await _localStorage.saveFriend(friend);
      }
      print(
        'Fetched ${friendsSnapshot1.docs.length + friendsSnapshot2.docs.length} friends',
      );

      // Fetch recurring expenses
      final recurringSnapshot = await _firestore
          .collection('recurringExpenses')
          .where('payerId', isEqualTo: userId)
          .get();

      for (final doc in recurringSnapshot.docs) {
        final recurring = RecurringExpenseModel.fromJson(doc.data());
        await _localStorage.saveRecurringExpense(recurring);
      }
      print('Fetched ${recurringSnapshot.docs.length} recurring expenses');

      // Fetch saved splits
      final splitsSnapshot = await _firestore
          .collection('savedSplits')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in splitsSnapshot.docs) {
        final split = SavedSplitModel.fromJson(doc.data());
        await _localStorage.saveSavedSplit(split);
      }
      print('Fetched ${splitsSnapshot.docs.length} saved splits');

      _lastSyncTime = DateTime.now();
      await _localStorage.setLastSyncTime(_lastSyncTime!);
      print('Fetch completed successfully');
    } catch (e) {
      print('Error fetching from Firestore: $e');
      rethrow;
    }
  }

  /// Clear sync queue
  Future<void> clearQueue() async {
    await _localStorage.clearSyncQueue();
    _syncedItems = 0;
    _failedItems = 0;
    _syncError = null;
  }

  /// Get sync queue size
  int getQueueSize() {
    return _localStorage.getSyncQueue().length;
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'syncError': _syncError,
      'syncedItems': _syncedItems,
      'failedItems': _failedItems,
      'queueSize': getQueueSize(),
      'isOnline': _connectivity.isOnline,
    };
  }
}
