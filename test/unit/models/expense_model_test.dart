import 'package:flutter_test/flutter_test.dart';
import 'package:splitly/models/expense_model.dart';

void main() {
  group('ExpenseModel', () {
    test('should create expense participant', () {
      final participant = ExpenseParticipant(
        userId: 'user1',
        splitAmount: 50.0,
      );

      expect(participant.userId, 'user1');
      expect(participant.splitAmount, 50.0);
    });

    test('should convert participant to JSON', () {
      final participant = ExpenseParticipant(
        userId: 'user1',
        splitAmount: 50.0,
      );

      final json = participant.toJson();

      expect(json['userId'], 'user1');
      expect(json['splitAmount'], 50.0);
    });

    test('should create participant from JSON', () {
      final json = {'userId': 'user1', 'splitAmount': 50.0};

      final participant = ExpenseParticipant.fromJson(json);

      expect(participant.userId, 'user1');
      expect(participant.splitAmount, 50.0);
    });

    test('should validate expense status enum', () {
      expect(ExpenseStatus.pending, isNotNull);
      expect(ExpenseStatus.settled, isNotNull);
      expect(ExpenseStatus.archived, isNotNull);
    });

    test('should validate split type enum', () {
      expect(SplitType.equal, isNotNull);
      expect(SplitType.unequal, isNotNull);
      expect(SplitType.percentage, isNotNull);
      expect(SplitType.shares, isNotNull);
    });
  });
}
