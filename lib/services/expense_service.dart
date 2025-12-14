import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new expense
  Future<String> addExpense({
    required String groupId,
    required String payerId,
    required double amount,
    required String currency,
    required String category,
    String? description,
    required DateTime date,
    required List<Map<String, dynamic>> participants,
    required SplitType splitType,
  }) async {
    try {
      // Calculate split amounts based on split type
      List<ExpenseParticipant> calculatedParticipants = _calculateSplitAmounts(
        amount,
        participants,
        splitType,
      );

      // Validate split amounts
      _validateSplitAmounts(amount, calculatedParticipants);

      // Create expense document
      final expenseRef = _firestore.collection('expenses').doc();
      final now = DateTime.now();

      final expense = ExpenseModel(
        expenseId: expenseRef.id,
        groupId: groupId,
        payerId: payerId,
        amount: amount,
        currency: currency,
        category: category,
        description: description,
        date: date,
        participants: calculatedParticipants,
        splitType: splitType,
        status: ExpenseStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await expenseRef.set(expense.toJson());
      return expenseRef.id;
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Calculate split amounts based on split type
  List<ExpenseParticipant> _calculateSplitAmounts(
    double totalAmount,
    List<Map<String, dynamic>> participants,
    SplitType splitType,
  ) {
    switch (splitType) {
      case SplitType.equal:
        return _calculateEqualSplit(totalAmount, participants);
      case SplitType.unequal:
        return _calculateUnequalSplit(participants);
      case SplitType.percentage:
        return _calculatePercentageSplit(totalAmount, participants);
    }
  }

  // Equal split: divide amount equally among participants
  List<ExpenseParticipant> _calculateEqualSplit(
    double totalAmount,
    List<Map<String, dynamic>> participants,
  ) {
    final count = participants.length;
    if (count == 0) throw Exception('No participants provided');

    // Use banker's rounding for fair distribution
    final baseAmount = (totalAmount / count * 100).floor() / 100;
    final remainder = totalAmount - (baseAmount * count);

    return List.generate(participants.length, (index) {
      final userId = participants[index]['userId'] as String;
      // Distribute remainder to first participants
      final splitAmount =
          baseAmount + (index < (remainder * 100).round() ? 0.01 : 0);
      return ExpenseParticipant(userId: userId, splitAmount: splitAmount);
    });
  }

  // Unequal split: custom amounts per person
  List<ExpenseParticipant> _calculateUnequalSplit(
    List<Map<String, dynamic>> participants,
  ) {
    return participants.map((p) {
      return ExpenseParticipant(
        userId: p['userId'] as String,
        splitAmount: (p['amount'] as num).toDouble(),
      );
    }).toList();
  }

  // Percentage split: distribute based on percentages
  List<ExpenseParticipant> _calculatePercentageSplit(
    double totalAmount,
    List<Map<String, dynamic>> participants,
  ) {
    // Validate percentages sum to 100
    final totalPercentage = participants.fold<double>(
      0,
      (acc, p) => acc + (p['percentage'] as num).toDouble(),
    );

    if ((totalPercentage - 100).abs() > 0.01) {
      throw Exception('Percentages must sum to 100%');
    }

    return participants.map((p) {
      final percentage = (p['percentage'] as num).toDouble();
      final splitAmount = (totalAmount * percentage / 100 * 100).round() / 100;
      return ExpenseParticipant(
        userId: p['userId'] as String,
        splitAmount: splitAmount,
      );
    }).toList();
  }

  // Validate that split amounts sum to total amount
  void _validateSplitAmounts(
    double totalAmount,
    List<ExpenseParticipant> participants,
  ) {
    final total = participants.fold<double>(0, (acc, p) => acc + p.splitAmount);

    // Allow small rounding differences (1 cent)
    if ((total - totalAmount).abs() > 0.01) {
      throw Exception(
        'Split amounts (\$$total) do not match total amount (\$$totalAmount)',
      );
    }

    // Check for negative amounts
    for (var participant in participants) {
      if (participant.splitAmount < 0) {
        throw Exception('Split amounts cannot be negative');
      }
    }
  }

  // Update an existing expense
  Future<void> updateExpense({
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
      final expenseRef = _firestore.collection('expenses').doc(expenseId);
      final expenseDoc = await expenseRef.get();

      if (!expenseDoc.exists) {
        throw Exception('Expense not found');
      }

      final currentExpense = ExpenseModel.fromJson(expenseDoc.data()!);
      final updateData = <String, dynamic>{'updatedAt': DateTime.now()};

      if (amount != null) updateData['amount'] = amount;
      if (currency != null) updateData['currency'] = currency;
      if (category != null) updateData['category'] = category;
      if (description != null) updateData['description'] = description;
      if (date != null) updateData['date'] = date;
      if (status != null) {
        updateData['status'] = status.toString().split('.').last;
      }

      // Recalculate split if amount or participants changed
      if (participants != null || amount != null || splitType != null) {
        final newAmount = amount ?? currentExpense.amount;
        final newSplitType = splitType ?? currentExpense.splitType;
        final newParticipants =
            participants ??
            currentExpense.participants
                .map((p) => {'userId': p.userId, 'amount': p.splitAmount})
                .toList();

        final calculatedParticipants = _calculateSplitAmounts(
          newAmount,
          newParticipants,
          newSplitType,
        );
        _validateSplitAmounts(newAmount, calculatedParticipants);

        updateData['participants'] = calculatedParticipants
            .map((p) => p.toJson())
            .toList();
        if (splitType != null) {
          updateData['splitType'] = splitType.toString().split('.').last;
        }
      }

      await expenseRef.update(updateData);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  // Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  // Get expense by ID
  Future<ExpenseModel?> getExpense(String expenseId) async {
    try {
      final doc = await _firestore.collection('expenses').doc(expenseId).get();
      if (!doc.exists) return null;
      return ExpenseModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  // Get expenses by group
  Stream<List<ExpenseModel>> getExpensesByGroup(String groupId) {
    return _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get expenses by user (where user is payer or participant)
  Stream<List<ExpenseModel>> getExpensesByUser(String userId) {
    return _firestore
        .collection('expenses')
        .where('payerId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required String groupId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('groupId', isEqualTo: groupId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expenses by date range: $e');
    }
  }

  // Filter expenses by category
  Stream<List<ExpenseModel>> getExpensesByCategory({
    required String groupId,
    required String category,
  }) {
    return _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromJson(doc.data()))
              .toList(),
        );
  }
}
