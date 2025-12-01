// Analytics Models for Splitly
// Contains models for spending analytics, debt analytics, and insights

/// Spending summary for a specific period
class SpendingSummary {
  final double totalSpent;
  final double totalOwed;
  final double totalLent;
  final int expenseCount;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, double> categoryBreakdown; // category -> amount
  final Map<String, double> participantBreakdown; // userId -> amount

  SpendingSummary({
    required this.totalSpent,
    required this.totalOwed,
    required this.totalLent,
    required this.expenseCount,
    required this.startDate,
    required this.endDate,
    required this.categoryBreakdown,
    required this.participantBreakdown,
  });

  double get netBalance => totalLent - totalOwed;
}

/// Category spending data for charts
class CategorySpending {
  final String category;
  final double amount;
  final int count;
  final double percentage;

  CategorySpending({
    required this.category,
    required this.amount,
    required this.count,
    required this.percentage,
  });
}

/// Spending trend data point
class SpendingTrendPoint {
  final DateTime date;
  final double amount;
  final int count;

  SpendingTrendPoint({
    required this.date,
    required this.amount,
    required this.count,
  });
}

/// Debt analytics summary
class DebtAnalytics {
  final double totalOwed;
  final double totalLent;
  final int activeDebts;
  final int settledDebts;
  final double averageDebt;
  final Map<String, double> debtByPerson; // userId -> amount
  final Map<String, double> debtByGroup; // groupId -> amount

  DebtAnalytics({
    required this.totalOwed,
    required this.totalLent,
    required this.activeDebts,
    required this.settledDebts,
    required this.averageDebt,
    required this.debtByPerson,
    required this.debtByGroup,
  });

  double get netBalance => totalLent - totalOwed;
}

/// Group analytics summary
class GroupAnalytics {
  final String groupId;
  final String groupName;
  final double totalSpent;
  final int expenseCount;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> memberSpending; // userId -> amount
  final DateTime? lastExpenseDate;

  GroupAnalytics({
    required this.groupId,
    required this.groupName,
    required this.totalSpent,
    required this.expenseCount,
    required this.categoryBreakdown,
    required this.memberSpending,
    this.lastExpenseDate,
  });
}

/// Time period for analytics
enum AnalyticsPeriod {
  thisWeek,
  thisMonth,
  thisYear,
  last30Days,
  last90Days,
  allTime,
  custom,
}

extension AnalyticsPeriodExtension on AnalyticsPeriod {
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.thisWeek:
        return 'This Week';
      case AnalyticsPeriod.thisMonth:
        return 'This Month';
      case AnalyticsPeriod.thisYear:
        return 'This Year';
      case AnalyticsPeriod.last30Days:
        return 'Last 30 Days';
      case AnalyticsPeriod.last90Days:
        return 'Last 90 Days';
      case AnalyticsPeriod.allTime:
        return 'All Time';
      case AnalyticsPeriod.custom:
        return 'Custom';
    }
  }

  DateRange getDateRange() {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsPeriod.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: now,
        );
      case AnalyticsPeriod.thisMonth:
        return DateRange(start: DateTime(now.year, now.month, 1), end: now);
      case AnalyticsPeriod.thisYear:
        return DateRange(start: DateTime(now.year, 1, 1), end: now);
      case AnalyticsPeriod.last30Days:
        return DateRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      case AnalyticsPeriod.last90Days:
        return DateRange(
          start: now.subtract(const Duration(days: 90)),
          end: now,
        );
      case AnalyticsPeriod.allTime:
        return DateRange(start: DateTime(2020, 1, 1), end: now);
      case AnalyticsPeriod.custom:
        return DateRange(start: now, end: now);
    }
  }
}

/// Date range for analytics
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}
