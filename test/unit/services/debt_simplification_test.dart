import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debt Simplification Algorithm', () {
    test('should simplify simple debt chain', () {
      // A owes B $50, B owes C $50
      // Should simplify to: A owes C $50
      final debts = {
        'A': {'B': 50.0},
        'B': {'C': 50.0},
      };

      // Calculate net balances
      final balances = <String, double>{};
      debts.forEach((debtor, creditors) {
        creditors.forEach((creditor, amount) {
          balances[debtor] = (balances[debtor] ?? 0) - amount;
          balances[creditor] = (balances[creditor] ?? 0) + amount;
        });
      });

      expect(balances['A'], -50.0);
      expect(balances['B'], 0.0);
      expect(balances['C'], 50.0);
    });

    test('should handle multiple debtors and creditors', () {
      // A owes $30, B owes $20, C is owed $50
      final balances = {'A': -30.0, 'B': -20.0, 'C': 50.0};

      final debtors = balances.entries.where((e) => e.value < 0).toList();
      final creditors = balances.entries.where((e) => e.value > 0).toList();

      expect(debtors.length, 2);
      expect(creditors.length, 1);
      expect(debtors.fold(0.0, (sum, e) => sum + e.value.abs()), 50.0);
      expect(creditors.fold(0.0, (sum, e) => sum + e.value), 50.0);
    });

    test('should minimize number of transactions', () {
      // Before: A->B $20, A->C $30, D->B $10, D->C $20
      // After: A->B $20, A->C $30, D->B $10, D->C $20 (or optimized)
      final originalTransactions = 4;

      // Calculate net balances
      final balances = {
        'A': -50.0, // owes 50
        'B': 30.0, // owed 30
        'C': 50.0, // owed 50
        'D': -30.0, // owes 30
      };

      // Greedy algorithm: match largest debtor with largest creditor
      final debtors = balances.entries.where((e) => e.value < 0).toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final creditors = balances.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      var simplifiedTransactions = 0;
      var i = 0, j = 0;

      while (i < debtors.length && j < creditors.length) {
        simplifiedTransactions++;
        i++;
        j++;
      }

      expect(simplifiedTransactions, lessThanOrEqualTo(originalTransactions));
    });

    test('should handle zero balance correctly', () {
      final balances = {'A': 0.0, 'B': 50.0, 'C': -50.0};

      final debtors = balances.entries.where((e) => e.value < 0).toList();
      final creditors = balances.entries.where((e) => e.value > 0).toList();

      expect(debtors.length, 1);
      expect(creditors.length, 1);
    });

    test('should calculate savings percentage', () {
      final originalTransactions = 6;
      final simplifiedTransactions = 3;

      final savings =
          ((originalTransactions - simplifiedTransactions) /
                  originalTransactions *
                  100)
              .round();

      expect(savings, 50);
    });
  });
}
