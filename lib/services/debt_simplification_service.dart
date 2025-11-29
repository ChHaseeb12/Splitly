import '../models/debt_model.dart';

class SimplifiedTransaction {
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String currency;

  SimplifiedTransaction({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.currency,
  });

  @override
  String toString() {
    return '$fromUserId pays $toUserId: \$$amount $currency';
  }
}

class DebtSimplificationService {
  // Simplify debts using greedy algorithm
  List<SimplifiedTransaction> simplifyDebts(List<DebtModel> debts) {
    if (debts.isEmpty) return [];

    // Group debts by currency
    final debtsByCurrency = <String, List<DebtModel>>{};
    for (var debt in debts) {
      debtsByCurrency.putIfAbsent(debt.currency, () => []).add(debt);
    }

    // Simplify debts for each currency
    final simplifiedTransactions = <SimplifiedTransaction>[];
    for (var entry in debtsByCurrency.entries) {
      final currency = entry.key;
      final currencyDebts = entry.value;
      simplifiedTransactions.addAll(
        _simplifyDebtsByCurrency(currencyDebts, currency),
      );
    }

    return simplifiedTransactions;
  }

  // Simplify debts for a single currency using greedy algorithm
  List<SimplifiedTransaction> _simplifyDebtsByCurrency(
    List<DebtModel> debts,
    String currency,
  ) {
    // Calculate net balance for each user
    final balances = <String, double>{};

    for (var debt in debts) {
      balances[debt.fromUserId] =
          (balances[debt.fromUserId] ?? 0) - debt.amount;
      balances[debt.toUserId] = (balances[debt.toUserId] ?? 0) + debt.amount;
    }

    // Separate creditors (positive balance) and debtors (negative balance)
    final creditors = <String, double>{};
    final debtors = <String, double>{};

    for (var entry in balances.entries) {
      if (entry.value > 0.01) {
        // Owed money (creditor)
        creditors[entry.key] = entry.value;
      } else if (entry.value < -0.01) {
        // Owes money (debtor)
        debtors[entry.key] = -entry.value;
      }
    }

    // Greedy algorithm: match largest debtor with largest creditor
    final transactions = <SimplifiedTransaction>[];

    while (creditors.isNotEmpty && debtors.isNotEmpty) {
      // Find largest creditor and debtor
      final maxCreditor = creditors.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final maxDebtor = debtors.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      // Calculate transaction amount
      final amount = maxCreditor.value < maxDebtor.value
          ? maxCreditor.value
          : maxDebtor.value;

      // Create transaction
      transactions.add(
        SimplifiedTransaction(
          fromUserId: maxDebtor.key,
          toUserId: maxCreditor.key,
          amount: (amount * 100).round() / 100, // Round to 2 decimal places
          currency: currency,
        ),
      );

      // Update balances
      creditors[maxCreditor.key] = maxCreditor.value - amount;
      debtors[maxDebtor.key] = maxDebtor.value - amount;

      // Remove if settled
      if (creditors[maxCreditor.key]! < 0.01) {
        creditors.remove(maxCreditor.key);
      }
      if (debtors[maxDebtor.key]! < 0.01) {
        debtors.remove(maxDebtor.key);
      }
    }

    return transactions;
  }

  // Calculate potential savings from simplification
  Map<String, dynamic> calculateSimplificationSavings(
    List<DebtModel> originalDebts,
    List<SimplifiedTransaction> simplifiedTransactions,
  ) {
    final originalCount = originalDebts.length;
    final simplifiedCount = simplifiedTransactions.length;
    final saved = originalCount - simplifiedCount;
    final savingsPercentage = originalCount > 0
        ? ((saved / originalCount) * 100).round()
        : 0;

    return {
      'originalTransactions': originalCount,
      'simplifiedTransactions': simplifiedCount,
      'transactionsSaved': saved,
      'savingsPercentage': savingsPercentage,
    };
  }

  // Get detailed view of debts (non-simplified)
  List<Map<String, dynamic>> getDetailedDebts(List<DebtModel> debts) {
    return debts.map((debt) {
      return {
        'fromUserId': debt.fromUserId,
        'toUserId': debt.toUserId,
        'amount': debt.amount,
        'currency': debt.currency,
        'expenseIds': debt.expenseIds,
      };
    }).toList();
  }

  // Get settlement suggestions for a group
  List<SimplifiedTransaction> getSettlementSuggestions({
    required List<DebtModel> debts,
    String? forUserId,
  }) {
    final simplified = simplifyDebts(debts);

    // Filter suggestions for specific user if provided
    if (forUserId != null) {
      return simplified.where((transaction) {
        return transaction.fromUserId == forUserId ||
            transaction.toUserId == forUserId;
      }).toList();
    }

    return simplified;
  }

  // Validate debt simplification (for testing)
  bool validateSimplification(
    List<DebtModel> originalDebts,
    List<SimplifiedTransaction> simplifiedTransactions,
  ) {
    // Calculate net balances from original debts
    final originalBalances = <String, double>{};
    for (var debt in originalDebts) {
      originalBalances[debt.fromUserId] =
          (originalBalances[debt.fromUserId] ?? 0) - debt.amount;
      originalBalances[debt.toUserId] =
          (originalBalances[debt.toUserId] ?? 0) + debt.amount;
    }

    // Calculate net balances from simplified transactions
    final simplifiedBalances = <String, double>{};
    for (var transaction in simplifiedTransactions) {
      simplifiedBalances[transaction.fromUserId] =
          (simplifiedBalances[transaction.fromUserId] ?? 0) -
          transaction.amount;
      simplifiedBalances[transaction.toUserId] =
          (simplifiedBalances[transaction.toUserId] ?? 0) + transaction.amount;
    }

    // Compare balances (allowing small rounding differences)
    for (var userId in originalBalances.keys) {
      final originalBalance = originalBalances[userId] ?? 0;
      final simplifiedBalance = simplifiedBalances[userId] ?? 0;

      if ((originalBalance - simplifiedBalance).abs() > 0.01) {
        return false;
      }
    }

    return true;
  }
}
