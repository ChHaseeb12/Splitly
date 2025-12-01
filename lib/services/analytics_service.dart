import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/debt_model.dart';
import '../models/analytics_models.dart';

/// Service for calculating analytics and insights
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get spending summary for a user in a date range
  Future<SpendingSummary> getSpendingSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? groupId,
  }) async {
    try {
      // Query expenses
      Query query = _firestore
          .collection('expenses')
          .where('participants', arrayContains: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (groupId != null) {
        query = query.where('groupId', isEqualTo: groupId);
      }

      final snapshot = await query.get();
      final expenses = snapshot.docs
          .map(
            (doc) => ExpenseModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'expenseId': doc.id,
            }),
          )
          .toList();

      // Calculate totals
      double totalSpent = 0;
      double totalOwed = 0;
      double totalLent = 0;
      Map<String, double> categoryBreakdown = {};
      Map<String, double> participantBreakdown = {};

      for (var expense in expenses) {
        // Category breakdown
        categoryBreakdown[expense.category] =
            (categoryBreakdown[expense.category] ?? 0) + expense.amount;

        // Participant breakdown
        for (var participant in expense.participants) {
          participantBreakdown[participant.userId] =
              (participantBreakdown[participant.userId] ?? 0) +
              participant.splitAmount;
        }

        // Calculate user's share
        final userParticipant = expense.participants.firstWhere(
          (p) => p.userId == userId,
          orElse: () => ExpenseParticipant(userId: userId, splitAmount: 0),
        );
        final userAmount = userParticipant.splitAmount;

        if (expense.payerId == userId) {
          // User paid
          totalSpent += expense.amount;
          totalLent += expense.amount - userAmount;
        } else {
          // Someone else paid
          totalOwed += userAmount;
        }
      }

      return SpendingSummary(
        totalSpent: totalSpent,
        totalOwed: totalOwed,
        totalLent: totalLent,
        expenseCount: expenses.length,
        startDate: startDate,
        endDate: endDate,
        categoryBreakdown: categoryBreakdown,
        participantBreakdown: participantBreakdown,
      );
    } catch (e) {
      print('Error getting spending summary: $e');
      return SpendingSummary(
        totalSpent: 0,
        totalOwed: 0,
        totalLent: 0,
        expenseCount: 0,
        startDate: startDate,
        endDate: endDate,
        categoryBreakdown: {},
        participantBreakdown: {},
      );
    }
  }

  /// Get category spending breakdown
  Future<List<CategorySpending>> getCategorySpending({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? groupId,
  }) async {
    final summary = await getSpendingSummary(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      groupId: groupId,
    );

    final total = summary.categoryBreakdown.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return [];

    return summary.categoryBreakdown.entries.map((entry) {
      return CategorySpending(
        category: entry.key,
        amount: entry.value,
        count: 0, // TODO: Calculate count per category
        percentage: (entry.value / total) * 100,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Get spending trend over time
  Future<List<SpendingTrendPoint>> getSpendingTrend({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? groupId,
  }) async {
    try {
      Query query = _firestore
          .collection('expenses')
          .where('participants', arrayContains: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date');

      if (groupId != null) {
        query = query.where('groupId', isEqualTo: groupId);
      }

      final snapshot = await query.get();
      final expenses = snapshot.docs
          .map(
            (doc) => ExpenseModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'expenseId': doc.id,
            }),
          )
          .toList();

      // Group by day
      Map<String, List<ExpenseModel>> expensesByDay = {};
      for (var expense in expenses) {
        final dateKey =
            '${expense.date.year}-${expense.date.month}-${expense.date.day}';
        expensesByDay[dateKey] = [...(expensesByDay[dateKey] ?? []), expense];
      }

      // Create trend points
      List<SpendingTrendPoint> points = [];
      for (var entry in expensesByDay.entries) {
        final date = entry.value.first.date;
        final amount = entry.value.fold(0.0, (sum, e) => sum + e.amount);
        points.add(
          SpendingTrendPoint(
            date: date,
            amount: amount,
            count: entry.value.length,
          ),
        );
      }

      return points..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      print('Error getting spending trend: $e');
      return [];
    }
  }

  /// Get debt analytics
  Future<DebtAnalytics> getDebtAnalytics({required String userId}) async {
    try {
      // Query debts where user is involved
      final owedSnapshot = await _firestore
          .collection('debts')
          .where('fromUserId', isEqualTo: userId)
          .get();

      final lentSnapshot = await _firestore
          .collection('debts')
          .where('toUserId', isEqualTo: userId)
          .get();

      final owedDebts = owedSnapshot.docs
          .map((doc) => DebtModel.fromJson({...doc.data(), 'debtId': doc.id}))
          .toList();

      final lentDebts = lentSnapshot.docs
          .map((doc) => DebtModel.fromJson({...doc.data(), 'debtId': doc.id}))
          .toList();

      double totalOwed = owedDebts.fold(0.0, (sum, debt) => sum + debt.amount);
      double totalLent = lentDebts.fold(0.0, (sum, debt) => sum + debt.amount);

      Map<String, double> debtByPerson = {};
      for (var debt in owedDebts) {
        debtByPerson[debt.toUserId] =
            (debtByPerson[debt.toUserId] ?? 0) + debt.amount;
      }
      for (var debt in lentDebts) {
        debtByPerson[debt.fromUserId] =
            (debtByPerson[debt.fromUserId] ?? 0) - debt.amount;
      }

      return DebtAnalytics(
        totalOwed: totalOwed,
        totalLent: totalLent,
        activeDebts: owedDebts.length + lentDebts.length,
        settledDebts: 0, // TODO: Track settled debts
        averageDebt:
            (totalOwed + totalLent) / (owedDebts.length + lentDebts.length + 1),
        debtByPerson: debtByPerson,
        debtByGroup: {}, // TODO: Calculate debt by group
      );
    } catch (e) {
      print('Error getting debt analytics: $e');
      return DebtAnalytics(
        totalOwed: 0,
        totalLent: 0,
        activeDebts: 0,
        settledDebts: 0,
        averageDebt: 0,
        debtByPerson: {},
        debtByGroup: {},
      );
    }
  }

  /// Get group analytics
  Future<GroupAnalytics> getGroupAnalytics({
    required String groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final expensesSnapshot = await _firestore
          .collection('expenses')
          .where('groupId', isEqualTo: groupId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final expenses = expensesSnapshot.docs
          .map(
            (doc) =>
                ExpenseModel.fromJson({...doc.data(), 'expenseId': doc.id}),
          )
          .toList();

      double totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
      Map<String, double> categoryBreakdown = {};
      Map<String, double> memberSpending = {};

      for (var expense in expenses) {
        categoryBreakdown[expense.category] =
            (categoryBreakdown[expense.category] ?? 0) + expense.amount;

        memberSpending[expense.payerId] =
            (memberSpending[expense.payerId] ?? 0) + expense.amount;
      }

      // Get group name
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      final groupName = groupDoc.data()?['name'] ?? 'Unknown Group';

      return GroupAnalytics(
        groupId: groupId,
        groupName: groupName,
        totalSpent: totalSpent,
        expenseCount: expenses.length,
        categoryBreakdown: categoryBreakdown,
        memberSpending: memberSpending,
        lastExpenseDate: expenses.isNotEmpty ? expenses.last.date : null,
      );
    } catch (e) {
      print('Error getting group analytics: $e');
      return GroupAnalytics(
        groupId: groupId,
        groupName: 'Unknown Group',
        totalSpent: 0,
        expenseCount: 0,
        categoryBreakdown: {},
        memberSpending: {},
      );
    }
  }

  /// Get top spending categories
  Future<List<CategorySpending>> getTopCategories({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    final categories = await getCategorySpending(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return categories.take(limit).toList();
  }

  /// Compare spending between two periods
  Future<Map<String, dynamic>> compareSpending({
    required String userId,
    required DateTime period1Start,
    required DateTime period1End,
    required DateTime period2Start,
    required DateTime period2End,
  }) async {
    final summary1 = await getSpendingSummary(
      userId: userId,
      startDate: period1Start,
      endDate: period1End,
    );

    final summary2 = await getSpendingSummary(
      userId: userId,
      startDate: period2Start,
      endDate: period2End,
    );

    final difference = summary1.totalSpent - summary2.totalSpent;
    final percentageChange = summary2.totalSpent > 0
        ? ((difference / summary2.totalSpent) * 100)
        : 0.0;

    return {
      'period1': summary1,
      'period2': summary2,
      'difference': difference,
      'percentageChange': percentageChange,
      'increased': difference > 0,
    };
  }
}
