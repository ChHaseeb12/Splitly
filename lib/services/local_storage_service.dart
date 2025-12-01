import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/expense_model.dart';
import '../models/group_model.dart';
import '../models/friend_model.dart';
import '../models/recurring_expense_model.dart';
import '../models/saved_split_model.dart';
import '../models/sync_queue_item.dart';

/// Service for managing local database with Hive
class LocalStorageService {
  static const String _userBox = 'users';
  static const String _expenseBox = 'expenses';
  static const String _groupBox = 'groups';
  static const String _friendBox = 'friends';
  static const String _recurringBox = 'recurring_expenses';
  static const String _savedSplitBox = 'saved_splits';
  static const String _syncQueueBox = 'sync_queue';
  static const String _cacheMetaBox = 'cache_meta';

  /// Initialize Hive and open all boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Open all boxes
    await Hive.openBox(_userBox);
    await Hive.openBox(_expenseBox);
    await Hive.openBox(_groupBox);
    await Hive.openBox(_friendBox);
    await Hive.openBox(_recurringBox);
    await Hive.openBox(_savedSplitBox);
    await Hive.openBox(_syncQueueBox);
    await Hive.openBox(_cacheMetaBox);
  }

  // User operations
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box(_userBox);
    await box.put(user.uid, user.toJson());
    await _updateCacheTime('user_${user.uid}');
  }

  UserModel? getUser(String uid) {
    final box = Hive.box(_userBox);
    final data = box.get(uid);
    if (data != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<void> deleteUser(String uid) async {
    final box = Hive.box(_userBox);
    await box.delete(uid);
  }

  // Expense operations
  Future<void> saveExpense(ExpenseModel expense) async {
    final box = Hive.box(_expenseBox);
    await box.put(expense.expenseId, expense.toJson());
    await _updateCacheTime('expense_${expense.expenseId}');
  }

  ExpenseModel? getExpense(String expenseId) {
    final box = Hive.box(_expenseBox);
    final data = box.get(expenseId);
    if (data != null) {
      return ExpenseModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<ExpenseModel> getAllExpenses() {
    final box = Hive.box(_expenseBox);
    return box.values
        .map((data) => ExpenseModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  List<ExpenseModel> getExpensesByGroup(String groupId) {
    return getAllExpenses()
        .where((expense) => expense.groupId == groupId)
        .toList();
  }

  Future<void> deleteExpense(String expenseId) async {
    final box = Hive.box(_expenseBox);
    await box.delete(expenseId);
  }

  // Group operations
  Future<void> saveGroup(GroupModel group) async {
    final box = Hive.box(_groupBox);
    await box.put(group.groupId, group.toJson());
    await _updateCacheTime('group_${group.groupId}');
  }

  GroupModel? getGroup(String groupId) {
    final box = Hive.box(_groupBox);
    final data = box.get(groupId);
    if (data != null) {
      return GroupModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<GroupModel> getAllGroups() {
    final box = Hive.box(_groupBox);
    return box.values
        .map((data) => GroupModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<void> deleteGroup(String groupId) async {
    final box = Hive.box(_groupBox);
    await box.delete(groupId);
  }

  // Friend operations
  Future<void> saveFriend(FriendModel friend) async {
    final box = Hive.box(_friendBox);
    await box.put(friend.friendId, friend.toJson());
    await _updateCacheTime('friend_${friend.friendId}');
  }

  FriendModel? getFriend(String friendId) {
    final box = Hive.box(_friendBox);
    final data = box.get(friendId);
    if (data != null) {
      return FriendModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<FriendModel> getAllFriends() {
    final box = Hive.box(_friendBox);
    return box.values
        .map((data) => FriendModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<void> deleteFriend(String friendId) async {
    final box = Hive.box(_friendBox);
    await box.delete(friendId);
  }

  // Recurring expense operations
  Future<void> saveRecurringExpense(RecurringExpenseModel recurring) async {
    final box = Hive.box(_recurringBox);
    await box.put(recurring.recurringId, recurring.toJson());
    await _updateCacheTime('recurring_${recurring.recurringId}');
  }

  RecurringExpenseModel? getRecurringExpense(String recurringId) {
    final box = Hive.box(_recurringBox);
    final data = box.get(recurringId);
    if (data != null) {
      return RecurringExpenseModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<RecurringExpenseModel> getAllRecurringExpenses() {
    final box = Hive.box(_recurringBox);
    return box.values
        .map(
          (data) =>
              RecurringExpenseModel.fromJson(Map<String, dynamic>.from(data)),
        )
        .toList();
  }

  Future<void> deleteRecurringExpense(String recurringId) async {
    final box = Hive.box(_recurringBox);
    await box.delete(recurringId);
  }

  // Saved split operations
  Future<void> saveSavedSplit(SavedSplitModel split) async {
    final box = Hive.box(_savedSplitBox);
    await box.put(split.savedSplitId, split.toJson());
    await _updateCacheTime('split_${split.savedSplitId}');
  }

  SavedSplitModel? getSavedSplit(String splitId) {
    final box = Hive.box(_savedSplitBox);
    final data = box.get(splitId);
    if (data != null) {
      return SavedSplitModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  List<SavedSplitModel> getAllSavedSplits() {
    final box = Hive.box(_savedSplitBox);
    return box.values
        .map(
          (data) => SavedSplitModel.fromJson(Map<String, dynamic>.from(data)),
        )
        .toList();
  }

  Future<void> deleteSavedSplit(String splitId) async {
    final box = Hive.box(_savedSplitBox);
    await box.delete(splitId);
  }

  // Sync queue operations
  Future<void> addToSyncQueue(SyncQueueItem item) async {
    final box = Hive.box(_syncQueueBox);
    await box.put(item.id, item.toJson());
  }

  List<SyncQueueItem> getSyncQueue() {
    final box = Hive.box(_syncQueueBox);
    return box.values
        .map((data) => SyncQueueItem.fromJson(Map<String, dynamic>.from(data)))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> removeFromSyncQueue(String itemId) async {
    final box = Hive.box(_syncQueueBox);
    await box.delete(itemId);
  }

  Future<void> updateSyncQueueItem(SyncQueueItem item) async {
    final box = Hive.box(_syncQueueBox);
    await box.put(item.id, item.toJson());
  }

  Future<void> clearSyncQueue() async {
    final box = Hive.box(_syncQueueBox);
    await box.clear();
  }

  // Cache metadata operations
  Future<void> _updateCacheTime(String key) async {
    final box = Hive.box(_cacheMetaBox);
    await box.put(key, DateTime.now().toIso8601String());
  }

  DateTime? getCacheTime(String key) {
    final box = Hive.box(_cacheMetaBox);
    final timeStr = box.get(key);
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    final box = Hive.box(_cacheMetaBox);
    await box.put('last_sync', time.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final box = Hive.box(_cacheMetaBox);
    final timeStr = box.get('last_sync');
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await Hive.box(_userBox).clear();
    await Hive.box(_expenseBox).clear();
    await Hive.box(_groupBox).clear();
    await Hive.box(_friendBox).clear();
    await Hive.box(_recurringBox).clear();
    await Hive.box(_savedSplitBox).clear();
    await Hive.box(_syncQueueBox).clear();
    await Hive.box(_cacheMetaBox).clear();
  }

  // Get storage statistics
  Map<String, int> getStorageStats() {
    return {
      'users': Hive.box(_userBox).length,
      'expenses': Hive.box(_expenseBox).length,
      'groups': Hive.box(_groupBox).length,
      'friends': Hive.box(_friendBox).length,
      'recurring': Hive.box(_recurringBox).length,
      'savedSplits': Hive.box(_savedSplitBox).length,
      'syncQueue': Hive.box(_syncQueueBox).length,
    };
  }
}
