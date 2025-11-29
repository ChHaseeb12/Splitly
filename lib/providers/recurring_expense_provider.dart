import 'package:flutter/material.dart';
import '../models/recurring_expense_model.dart';
import '../services/recurring_expense_service.dart';

class RecurringExpenseProvider with ChangeNotifier {
  final RecurringExpenseService _recurringExpenseService =
      RecurringExpenseService();

  bool _isLoading = false;
  String? _errorMessage;
  List<RecurringExpenseModel> _recurringExpenses = [];
  List<RecurringExpenseModel> _upcomingExpenses = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RecurringExpenseModel> get recurringExpenses => _recurringExpenses;
  List<RecurringExpenseModel> get upcomingExpenses => _upcomingExpenses;

  // Create recurring expense
  Future<void> createRecurringExpense(
    RecurringExpenseModel recurringExpense,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recurringExpenseService.createRecurringExpense(recurringExpense);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update recurring expense
  Future<void> updateRecurringExpense(
    RecurringExpenseModel recurringExpense,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recurringExpenseService.updateRecurringExpense(recurringExpense);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pause recurring expense
  Future<void> pauseRecurringExpense(String recurringId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recurringExpenseService.pauseRecurringExpense(recurringId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resume recurring expense
  Future<void> resumeRecurringExpense(String recurringId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recurringExpenseService.resumeRecurringExpense(recurringId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete recurring expense
  Future<void> deleteRecurringExpense(
    String recurringId, {
    bool deleteFutureInstances = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recurringExpenseService.deleteRecurringExpense(
        recurringId,
        deleteFutureInstances: deleteFutureInstances,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load recurring expenses for a group
  void loadRecurringExpensesByGroup(String groupId) {
    _recurringExpenseService.getRecurringExpensesByGroup(groupId).listen((
      expenses,
    ) {
      _recurringExpenses = expenses;
      notifyListeners();
    });
  }

  // Load active recurring expenses for a user
  void loadActiveRecurringExpenses(String userId) {
    _recurringExpenseService.getActiveRecurringExpenses(userId).listen((
      expenses,
    ) {
      _recurringExpenses = expenses;
      notifyListeners();
    });
  }

  // Load upcoming recurring expenses
  Future<void> loadUpcomingRecurringExpenses(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _upcomingExpenses = await _recurringExpenseService
          .getUpcomingRecurringExpenses(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate due expenses (background task)
  Future<void> generateDueExpenses() async {
    try {
      await _recurringExpenseService.generateDueExpenses();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
