import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../services/balance_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  final BalanceService _balanceService = BalanceService();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Add expense
  Future<String?> addExpense({
    required String groupId,
    required String payerId,
    required String payerName,
    required double amount,
    required String currency,
    required String category,
    String? description,
    required DateTime date,
    required List<Map<String, dynamic>> participants,
    required SplitType splitType,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final expenseId = await _expenseService.addExpense(
        groupId: groupId,
        payerId: payerId,
        payerName: payerName,
        amount: amount,
        currency: currency,
        category: category,
        description: description,
        date: date,
        participants: participants,
        splitType: splitType,
      );

      // Update debts
      final expense = await _expenseService.getExpense(expenseId);
      if (expense != null) {
        await _balanceService.updateDebtsFromExpense(expense);
      }

      _isLoading = false;
      notifyListeners();
      return expenseId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update expense
  Future<bool> updateExpense({
    required String expenseId,
    double? amount,
    String? currency,
    String? category,
    String? description,
    DateTime? date,
    List<Map<String, dynamic>>? participants,
    SplitType? splitType,
    ExpenseStatus? status,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _expenseService.updateExpense(
        expenseId: expenseId,
        amount: amount,
        currency: currency,
        category: category,
        description: description,
        date: date,
        participants: participants,
        splitType: splitType,
        status: status,
      );

      // Update debts if expense changed
      final expense = await _expenseService.getExpense(expenseId);
      if (expense != null) {
        await _balanceService.updateDebtsFromExpense(expense);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _expenseService.deleteExpense(expenseId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load expenses by group
  void loadExpensesByGroup(String groupId) {
    _expenseService
        .getExpensesByGroup(groupId)
        .listen(
          (expenses) {
            _expenses = expenses;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // Load expenses by user
  void loadExpensesByUser(String userId) {
    _expenseService
        .getExpensesByUser(userId)
        .listen(
          (expenses) {
            _expenses = expenses;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required String groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _expenseService.getExpensesByDateRange(
        groupId: groupId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Load expenses by category
  void loadExpensesByCategory({
    required String groupId,
    required String category,
  }) {
    _expenseService
        .getExpensesByCategory(groupId: groupId, category: category)
        .listen(
          (expenses) {
            _expenses = expenses;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
