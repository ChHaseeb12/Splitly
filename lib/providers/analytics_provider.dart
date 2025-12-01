import 'package:flutter/foundation.dart';
import '../models/analytics_models.dart';
import '../services/analytics_service.dart';

/// Provider for analytics state management
class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  // State
  bool _isLoading = false;
  String? _error;
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.thisMonth;
  DateRange? _customDateRange;

  // Analytics data
  SpendingSummary? _spendingSummary;
  List<CategorySpending> _categorySpending = [];
  List<SpendingTrendPoint> _spendingTrend = [];
  DebtAnalytics? _debtAnalytics;
  List<GroupAnalytics> _groupAnalytics = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AnalyticsPeriod get selectedPeriod => _selectedPeriod;
  DateRange? get customDateRange => _customDateRange;
  SpendingSummary? get spendingSummary => _spendingSummary;
  List<CategorySpending> get categorySpending => _categorySpending;
  List<SpendingTrendPoint> get spendingTrend => _spendingTrend;
  DebtAnalytics? get debtAnalytics => _debtAnalytics;
  List<GroupAnalytics> get groupAnalytics => _groupAnalytics;

  /// Get current date range based on selected period
  DateRange get currentDateRange {
    if (_selectedPeriod == AnalyticsPeriod.custom && _customDateRange != null) {
      return _customDateRange!;
    }
    return _selectedPeriod.getDateRange();
  }

  /// Set selected period
  void setSelectedPeriod(AnalyticsPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  /// Set custom date range
  void setCustomDateRange(DateTime start, DateTime end) {
    _customDateRange = DateRange(start: start, end: end);
    _selectedPeriod = AnalyticsPeriod.custom;
    notifyListeners();
  }

  /// Load all analytics for a user
  Future<void> loadAnalytics(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dateRange = currentDateRange;

      // Load spending summary
      _spendingSummary = await _analyticsService.getSpendingSummary(
        userId: userId,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      // Load category spending
      _categorySpending = await _analyticsService.getCategorySpending(
        userId: userId,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      // Load spending trend
      _spendingTrend = await _analyticsService.getSpendingTrend(
        userId: userId,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      // Load debt analytics
      _debtAnalytics = await _analyticsService.getDebtAnalytics(userId: userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load group analytics
  Future<void> loadGroupAnalytics(List<String> groupIds) async {
    try {
      final dateRange = currentDateRange;
      _groupAnalytics = [];

      for (var groupId in groupIds) {
        final analytics = await _analyticsService.getGroupAnalytics(
          groupId: groupId,
          startDate: dateRange.start,
          endDate: dateRange.end,
        );
        _groupAnalytics.add(analytics);
      }

      notifyListeners();
    } catch (e) {
      print('Error loading group analytics: $e');
    }
  }

  /// Refresh analytics
  Future<void> refresh(String userId) async {
    await loadAnalytics(userId);
  }

  /// Clear analytics data
  void clear() {
    _spendingSummary = null;
    _categorySpending = [];
    _spendingTrend = [];
    _debtAnalytics = null;
    _groupAnalytics = [];
    _error = null;
    notifyListeners();
  }
}
