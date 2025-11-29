import 'package:flutter/foundation.dart';
import '../models/debt_model.dart';
import '../services/balance_service.dart';
import '../services/debt_simplification_service.dart';

class BalanceProvider with ChangeNotifier {
  final BalanceService _balanceService = BalanceService();
  final DebtSimplificationService _simplificationService =
      DebtSimplificationService();

  List<DebtModel> _debts = [];
  Map<String, double> _summaryBalances = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _simplificationEnabled = true;

  List<DebtModel> get debts => _debts;
  Map<String, double> get summaryBalances => _summaryBalances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get simplificationEnabled => _simplificationEnabled;

  // Toggle simplification
  void toggleSimplification() {
    _simplificationEnabled = !_simplificationEnabled;
    notifyListeners();
  }

  // Calculate net balance between two users
  Future<double> calculateNetBalance({
    required String userId1,
    required String userId2,
    String? groupId,
  }) async {
    try {
      return await _balanceService.calculateNetBalance(
        userId1: userId1,
        userId2: userId2,
        groupId: groupId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return 0;
    }
  }

  // Load debts for user
  Future<void> loadDebtsForUser(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _debts = await _balanceService.getDebtsForUser(userId);
      _summaryBalances = await _balanceService.getSummaryBalances(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load debts for group
  Future<void> loadDebtsForGroup(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _debts = await _balanceService.getDebtsForGroup(groupId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get simplified transactions
  List<SimplifiedTransaction> getSimplifiedTransactions() {
    if (!_simplificationEnabled) {
      return [];
    }
    return _simplificationService.simplifyDebts(_debts);
  }

  // Get settlement suggestions
  List<SimplifiedTransaction> getSettlementSuggestions({String? forUserId}) {
    return _simplificationService.getSettlementSuggestions(
      debts: _debts,
      forUserId: forUserId,
    );
  }

  // Get simplification savings
  Map<String, dynamic> getSimplificationSavings() {
    final simplified = getSimplifiedTransactions();
    return _simplificationService.calculateSimplificationSavings(
      _debts,
      simplified,
    );
  }

  // Settle debt
  Future<bool> settleDebt({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _balanceService.settleDebt(
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
        currency: currency,
      );

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

  // Get settlement history
  Future<List<Map<String, dynamic>>> getSettlementHistory(String userId) async {
    try {
      return await _balanceService.getSettlementHistory(userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
