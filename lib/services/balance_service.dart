import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debt_model.dart';
import '../models/expense_model.dart';

class BalanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Calculate net balance between two users
  Future<double> calculateNetBalance({
    required String userId1,
    required String userId2,
    String? groupId,
  }) async {
    try {
      // Get all expenses involving both users
      Query query = _firestore.collection('expenses');

      if (groupId != null) {
        query = query.where('groupId', isEqualTo: groupId);
      }

      final snapshot = await query.get();
      double balance = 0;

      for (var doc in snapshot.docs) {
        final expense = ExpenseModel.fromJson(
          doc.data() as Map<String, dynamic>,
        );

        // Check if both users are involved
        final user1Participant = expense.participants.firstWhere(
          (p) => p.userId == userId1,
          orElse: () => ExpenseParticipant(userId: '', splitAmount: 0),
        );
        final user2Participant = expense.participants.firstWhere(
          (p) => p.userId == userId2,
          orElse: () => ExpenseParticipant(userId: '', splitAmount: 0),
        );

        if (user1Participant.userId.isEmpty &&
            user2Participant.userId.isEmpty) {
          continue;
        }

        // Calculate balance based on who paid and who owes
        if (expense.payerId == userId1) {
          // User1 paid, User2 owes
          balance += user2Participant.splitAmount;
        } else if (expense.payerId == userId2) {
          // User2 paid, User1 owes
          balance -= user1Participant.splitAmount;
        }
      }

      return balance;
    } catch (e) {
      throw Exception('Failed to calculate net balance: $e');
    }
  }

  // Get all debts for a user
  Future<List<DebtModel>> getDebtsForUser(String userId) async {
    try {
      // Get debts where user owes money
      final owedByUserSnapshot = await _firestore
          .collection('debts')
          .where('fromUserId', isEqualTo: userId)
          .get();

      // Get debts where user is owed money
      final owedToUserSnapshot = await _firestore
          .collection('debts')
          .where('toUserId', isEqualTo: userId)
          .get();

      final debts = <DebtModel>[];

      for (var doc in owedByUserSnapshot.docs) {
        debts.add(DebtModel.fromJson(doc.data()));
      }

      for (var doc in owedToUserSnapshot.docs) {
        debts.add(DebtModel.fromJson(doc.data()));
      }

      return debts;
    } catch (e) {
      throw Exception('Failed to get debts for user: $e');
    }
  }

  // Get all debts for a group
  Future<List<DebtModel>> getDebtsForGroup(String groupId) async {
    try {
      // Get all expenses in the group
      final expensesSnapshot = await _firestore
          .collection('expenses')
          .where('groupId', isEqualTo: groupId)
          .get();

      final expenseIds = expensesSnapshot.docs.map((doc) => doc.id).toList();

      if (expenseIds.isEmpty) return [];

      // Get debts related to these expenses
      final debtsSnapshot = await _firestore
          .collection('debts')
          .where('expenseIds', arrayContainsAny: expenseIds)
          .get();

      return debtsSnapshot.docs
          .map((doc) => DebtModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get debts for group: $e');
    }
  }

  // Get summary balances (who owes what)
  Future<Map<String, double>> getSummaryBalances(String userId) async {
    try {
      final debts = await getDebtsForUser(userId);
      final balances = <String, double>{};

      for (var debt in debts) {
        if (debt.fromUserId == userId) {
          // User owes money
          balances[debt.toUserId] =
              (balances[debt.toUserId] ?? 0) - debt.amount;
        } else {
          // User is owed money
          balances[debt.fromUserId] =
              (balances[debt.fromUserId] ?? 0) + debt.amount;
        }
      }

      return balances;
    } catch (e) {
      throw Exception('Failed to get summary balances: $e');
    }
  }

  // Create or update debt record
  Future<void> createOrUpdateDebt({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
    required String expenseId,
  }) async {
    try {
      // Check if debt already exists between these users
      final existingDebtSnapshot = await _firestore
          .collection('debts')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('currency', isEqualTo: currency)
          .get();

      if (existingDebtSnapshot.docs.isNotEmpty) {
        // Update existing debt
        final debtDoc = existingDebtSnapshot.docs.first;
        final existingDebt = DebtModel.fromJson(debtDoc.data());

        final updatedExpenseIds = [...existingDebt.expenseIds];
        if (!updatedExpenseIds.contains(expenseId)) {
          updatedExpenseIds.add(expenseId);
        }

        await debtDoc.reference.update({
          'amount': existingDebt.amount + amount,
          'expenseIds': updatedExpenseIds,
          'updatedAt': DateTime.now(),
        });
      } else {
        // Create new debt
        final debtRef = _firestore.collection('debts').doc();
        final now = DateTime.now();

        final debt = DebtModel(
          debtId: debtRef.id,
          fromUserId: fromUserId,
          toUserId: toUserId,
          amount: amount,
          currency: currency,
          expenseIds: [expenseId],
          createdAt: now,
          updatedAt: now,
        );

        await debtRef.set(debt.toJson());
      }
    } catch (e) {
      throw Exception('Failed to create or update debt: $e');
    }
  }

  // Update debts based on expense
  Future<void> updateDebtsFromExpense(ExpenseModel expense) async {
    try {
      for (var participant in expense.participants) {
        if (participant.userId != expense.payerId) {
          // Participant owes money to payer
          await createOrUpdateDebt(
            fromUserId: participant.userId,
            toUserId: expense.payerId,
            amount: participant.splitAmount,
            currency: expense.currency,
            expenseId: expense.expenseId,
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to update debts from expense: $e');
    }
  }

  // Settle debt between two users
  Future<void> settleDebt({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
  }) async {
    try {
      // Find debt record
      final debtSnapshot = await _firestore
          .collection('debts')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('currency', isEqualTo: currency)
          .get();

      if (debtSnapshot.docs.isEmpty) {
        throw Exception('Debt not found');
      }

      final debtDoc = debtSnapshot.docs.first;
      final debt = DebtModel.fromJson(debtDoc.data());

      if (amount >= debt.amount) {
        // Fully settled, delete debt
        await debtDoc.reference.delete();
      } else {
        // Partially settled, update amount
        await debtDoc.reference.update({
          'amount': debt.amount - amount,
          'updatedAt': DateTime.now(),
        });
      }

      // Create settlement record
      await _createSettlementRecord(
        fromUserId: fromUserId,
        toUserId: toUserId,
        amount: amount,
        currency: currency,
        debtId: debt.debtId,
      );
    } catch (e) {
      throw Exception('Failed to settle debt: $e');
    }
  }

  // Create settlement record
  Future<void> _createSettlementRecord({
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
    required String debtId,
  }) async {
    final settlementRef = _firestore.collection('settlements').doc();
    final now = DateTime.now();

    await settlementRef.set({
      'settlementId': settlementRef.id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'currency': currency,
      'debtId': debtId,
      'settledAt': now,
      'createdAt': now,
    });
  }

  // Get settlement history for a user
  Future<List<Map<String, dynamic>>> getSettlementHistory(String userId) async {
    try {
      final sentSnapshot = await _firestore
          .collection('settlements')
          .where('fromUserId', isEqualTo: userId)
          .orderBy('settledAt', descending: true)
          .get();

      final receivedSnapshot = await _firestore
          .collection('settlements')
          .where('toUserId', isEqualTo: userId)
          .orderBy('settledAt', descending: true)
          .get();

      final settlements = <Map<String, dynamic>>[];

      for (var doc in sentSnapshot.docs) {
        settlements.add(doc.data());
      }

      for (var doc in receivedSnapshot.docs) {
        settlements.add(doc.data());
      }

      // Sort by settledAt
      settlements.sort((a, b) {
        final aDate = (a['settledAt'] as Timestamp).toDate();
        final bDate = (b['settledAt'] as Timestamp).toDate();
        return bDate.compareTo(aDate);
      });

      return settlements;
    } catch (e) {
      throw Exception('Failed to get settlement history: $e');
    }
  }
}
