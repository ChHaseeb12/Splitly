import 'package:cloud_firestore/cloud_firestore.dart';

class DebtModel {
  final String debtId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String currency;
  final List<String> expenseIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  DebtModel({
    required this.debtId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    this.currency = 'USD',
    required this.expenseIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'debtId': debtId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'amount': amount,
      'currency': currency,
      'expenseIds': expenseIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      debtId: json['debtId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      expenseIds: List<String>.from(json['expenseIds'] as List<dynamic>? ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  DebtModel copyWith({
    String? debtId,
    String? fromUserId,
    String? toUserId,
    double? amount,
    String? currency,
    List<String>? expenseIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DebtModel(
      debtId: debtId ?? this.debtId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      expenseIds: expenseIds ?? this.expenseIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
