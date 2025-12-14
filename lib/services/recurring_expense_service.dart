import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recurring_expense_model.dart';
import '../models/expense_model.dart';
import 'expense_service.dart';

class RecurringExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ExpenseService _expenseService = ExpenseService();

  // Create recurring expense
  Future<void> createRecurringExpense(
    RecurringExpenseModel recurringExpense,
  ) async {
    try {
      await _firestore
          .collection('recurringExpenses')
          .doc(recurringExpense.recurringId)
          .set(recurringExpense.toJson());
    } catch (e) {
      throw Exception('Failed to create recurring expense: $e');
    }
  }

  // Update recurring expense
  Future<void> updateRecurringExpense(
    RecurringExpenseModel recurringExpense,
  ) async {
    try {
      await _firestore
          .collection('recurringExpenses')
          .doc(recurringExpense.recurringId)
          .update(
            recurringExpense.copyWith(updatedAt: Timestamp.now()).toJson(),
          );
    } catch (e) {
      throw Exception('Failed to update recurring expense: $e');
    }
  }

  // Pause recurring expense
  Future<void> pauseRecurringExpense(String recurringId) async {
    try {
      await _firestore.collection('recurringExpenses').doc(recurringId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to pause recurring expense: $e');
    }
  }

  // Resume recurring expense
  Future<void> resumeRecurringExpense(String recurringId) async {
    try {
      await _firestore.collection('recurringExpenses').doc(recurringId).update({
        'isActive': true,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to resume recurring expense: $e');
    }
  }

  // Delete recurring expense
  Future<void> deleteRecurringExpense(
    String recurringId, {
    bool deleteFutureInstances = false,
  }) async {
    try {
      if (deleteFutureInstances) {
        // Delete all future expense instances
        final recurringExpense = await getRecurringExpense(recurringId);
        if (recurringExpense != null) {
          final futureExpenses = await _firestore
              .collection('expenses')
              .where('recurringId', isEqualTo: recurringId)
              .where('date', isGreaterThanOrEqualTo: Timestamp.now())
              .get();

          for (var doc in futureExpenses.docs) {
            await _expenseService.deleteExpense(doc.id);
          }
        }
      }

      await _firestore
          .collection('recurringExpenses')
          .doc(recurringId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete recurring expense: $e');
    }
  }

  // Get recurring expense by ID
  Future<RecurringExpenseModel?> getRecurringExpense(String recurringId) async {
    try {
      final doc = await _firestore
          .collection('recurringExpenses')
          .doc(recurringId)
          .get();
      if (doc.exists) {
        return RecurringExpenseModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get recurring expense: $e');
    }
  }

  // Get recurring expenses for a group
  Stream<List<RecurringExpenseModel>> getRecurringExpensesByGroup(
    String groupId,
  ) {
    return _firestore
        .collection('recurringExpenses')
        .where('groupId', isEqualTo: groupId)
        .orderBy('nextDueDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecurringExpenseModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get active recurring expenses
  Stream<List<RecurringExpenseModel>> getActiveRecurringExpenses(
    String userId,
  ) {
    return _firestore
        .collection('recurringExpenses')
        .where('payerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('nextDueDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecurringExpenseModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Helper method to parse split type
  SplitType _parseSplitType(String splitType) {
    switch (splitType.toUpperCase()) {
      case 'EQUAL':
        return SplitType.equal;
      case 'UNEQUAL':
        return SplitType.unequal;
      case 'PERCENTAGE':
        return SplitType.percentage;
      default:
        return SplitType.equal;
    }
  }

  // Calculate next due date based on frequency
  DateTime calculateNextDueDate(
    DateTime currentDate,
    RecurringFrequency frequency,
  ) {
    switch (frequency) {
      case RecurringFrequency.DAILY:
        return currentDate.add(const Duration(days: 1));
      case RecurringFrequency.WEEKLY:
        return currentDate.add(const Duration(days: 7));
      case RecurringFrequency.MONTHLY:
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
      case RecurringFrequency.YEARLY:
        return DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
        );
    }
  }

  // Auto-generate expense instances (should be called by background task)
  Future<void> generateDueExpenses() async {
    try {
      final now = DateTime.now();
      final dueExpenses = await _firestore
          .collection('recurringExpenses')
          .where('isActive', isEqualTo: true)
          .where('autoCreate', isEqualTo: true)
          .where('nextDueDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      for (var doc in dueExpenses.docs) {
        final recurring = RecurringExpenseModel.fromJson(doc.data());

        // Check if end date has passed
        if (recurring.endDate != null && now.isAfter(recurring.endDate!)) {
          await pauseRecurringExpense(recurring.recurringId);
          continue;
        }

        // Create expense instance
        final participantsList =
            (recurring.splitConfig['participants'] as List<dynamic>?)
                ?.map((p) => p as Map<String, dynamic>)
                .toList() ??
            [];

        await _expenseService.addExpense(
          groupId: recurring.groupId,
          payerId: recurring.payerId,
          amount: recurring.amount,
          currency: recurring.currency,
          category: recurring.category,
          description: '${recurring.description} (Recurring)',
          date: recurring.nextDueDate,
          participants: participantsList,
          splitType: _parseSplitType(
            recurring.splitConfig['splitType'] ?? 'EQUAL',
          ),
        );

        // Update next due date
        final nextDue = calculateNextDueDate(
          recurring.nextDueDate,
          recurring.frequency,
        );
        await _firestore
            .collection('recurringExpenses')
            .doc(recurring.recurringId)
            .update({
              'nextDueDate': Timestamp.fromDate(nextDue),
              'updatedAt': Timestamp.now(),
            });
      }
    } catch (e) {
      throw Exception('Failed to generate due expenses: $e');
    }
  }

  // Get upcoming recurring expenses (next 30 days)
  Future<List<RecurringExpenseModel>> getUpcomingRecurringExpenses(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('recurringExpenses')
          .where('payerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .where('nextDueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where(
            'nextDueDate',
            isLessThanOrEqualTo: Timestamp.fromDate(thirtyDaysLater),
          )
          .orderBy('nextDueDate')
          .get();

      return snapshot.docs
          .map((doc) => RecurringExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming recurring expenses: $e');
    }
  }
}
