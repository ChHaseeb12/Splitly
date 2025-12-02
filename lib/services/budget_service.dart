import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create budget
  Future<void> createBudget(BudgetModel budget) async {
    try {
      await _firestore
          .collection('budgets')
          .doc(budget.id)
          .set(budget.toJson());
    } catch (e) {
      print('Error creating budget: $e');
      rethrow;
    }
  }

  // Update budget
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await _firestore.collection('budgets').doc(budget.id).update({
        ...budget.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating budget: $e');
      rethrow;
    }
  }

  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestore.collection('budgets').doc(budgetId).delete();
    } catch (e) {
      print('Error deleting budget: $e');
      rethrow;
    }
  }

  // Get budgets for user
  Stream<List<BudgetModel>> getBudgets(String userId) {
    return _firestore
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BudgetModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Get budgets for group
  Stream<List<BudgetModel>> getGroupBudgets(String groupId) {
    return _firestore
        .collection('budgets')
        .where('groupId', isEqualTo: groupId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BudgetModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Calculate spent amount for budget
  Future<double> calculateSpent(BudgetModel budget) async {
    try {
      DateTime startDate = budget.startDate;
      DateTime endDate =
          budget.endDate ??
          _getEndDateForPeriod(budget.startDate, budget.period);

      Query query = _firestore
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      // Filter by group if specified
      if (budget.groupId != null) {
        query = query.where('groupId', isEqualTo: budget.groupId);
      } else {
        // Personal budget - filter by user
        query = query.where(
          'participants',
          arrayContains: {'userId': budget.userId},
        );
      }

      final snapshot = await query.get();
      double total = 0.0;

      for (var doc in snapshot.docs) {
        final expense = ExpenseModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });

        // Filter by category if specified
        if (budget.category != null && expense.category != budget.category) {
          continue;
        }

        // Calculate user's share
        final participant = expense.participants.firstWhere(
          (p) => p.userId == budget.userId,
          orElse: () =>
              ExpenseParticipant(userId: budget.userId, splitAmount: 0.0),
        );

        total += participant.splitAmount;
      }

      return total;
    } catch (e) {
      print('Error calculating spent amount: $e');
      return 0.0;
    }
  }

  // Update spent amount for budget
  Future<void> updateSpentAmount(String budgetId) async {
    try {
      final doc = await _firestore.collection('budgets').doc(budgetId).get();
      if (!doc.exists) return;

      final budget = BudgetModel.fromJson({...doc.data()!, 'id': doc.id});

      final spent = await calculateSpent(budget);

      await _firestore.collection('budgets').doc(budgetId).update({
        'spent': spent,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating spent amount: $e');
      rethrow;
    }
  }

  // Check budget alerts
  Future<List<BudgetModel>> checkBudgetAlerts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      List<BudgetModel> alerts = [];

      for (var doc in snapshot.docs) {
        final budget = BudgetModel.fromJson({...doc.data(), 'id': doc.id});

        // Update spent amount
        final spent = await calculateSpent(budget);
        final updatedBudget = budget.copyWith(spent: spent);

        // Check if over budget or near limit
        if (updatedBudget.isOverBudget || updatedBudget.isNearLimit) {
          alerts.add(updatedBudget);
        }
      }

      return alerts;
    } catch (e) {
      print('Error checking budget alerts: $e');
      return [];
    }
  }

  // Get end date for budget period
  DateTime _getEndDateForPeriod(DateTime startDate, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.DAILY:
        return startDate.add(const Duration(days: 1));
      case BudgetPeriod.WEEKLY:
        return startDate.add(const Duration(days: 7));
      case BudgetPeriod.MONTHLY:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case BudgetPeriod.QUARTERLY:
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      case BudgetPeriod.YEARLY:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      case BudgetPeriod.CUSTOM:
        return startDate.add(const Duration(days: 30)); // Default to 30 days
    }
  }

  // Get budget by ID
  Future<BudgetModel?> getBudgetById(String budgetId) async {
    try {
      final doc = await _firestore.collection('budgets').doc(budgetId).get();
      if (!doc.exists) return null;

      return BudgetModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting budget: $e');
      return null;
    }
  }
}
