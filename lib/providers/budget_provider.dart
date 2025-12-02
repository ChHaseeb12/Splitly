import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  List<BudgetModel> _budgets = [];
  List<BudgetModel> _alerts = [];
  bool _isLoading = false;
  String? _error;

  List<BudgetModel> get budgets => _budgets;
  List<BudgetModel> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load budgets
  void loadBudgets(String userId) {
    _budgetService
        .getBudgets(userId)
        .listen(
          (budgets) {
            _budgets = budgets;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  // Load group budgets
  void loadGroupBudgets(String groupId) {
    _budgetService
        .getGroupBudgets(groupId)
        .listen(
          (budgets) {
            _budgets = budgets;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  // Create budget
  Future<void> createBudget(BudgetModel budget) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _budgetService.createBudget(budget);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update budget
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _budgetService.updateBudget(budget);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _budgetService.deleteBudget(budgetId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update spent amount
  Future<void> updateSpentAmount(String budgetId) async {
    try {
      await _budgetService.updateSpentAmount(budgetId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check budget alerts
  Future<void> checkAlerts(String userId) async {
    try {
      _alerts = await _budgetService.checkBudgetAlerts(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get budget by ID
  Future<BudgetModel?> getBudgetById(String budgetId) async {
    try {
      return await _budgetService.getBudgetById(budgetId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
