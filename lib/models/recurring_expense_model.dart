import 'package:cloud_firestore/cloud_firestore.dart';

enum RecurringFrequency { DAILY, WEEKLY, MONTHLY, YEARLY }

class RecurringExpenseModel {
  final String recurringId;
  final String baseExpenseId;
  final String groupId;
  final String payerId;
  final double amount;
  final String currency;
  final String category;
  final String description;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final bool isActive;
  final bool autoCreate;
  final Map<String, dynamic>
  splitConfig; // Stores split type and participant info
  final Timestamp createdAt;
  final Timestamp updatedAt;

  RecurringExpenseModel({
    required this.recurringId,
    required this.baseExpenseId,
    required this.groupId,
    required this.payerId,
    required this.amount,
    required this.currency,
    required this.category,
    required this.description,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    required this.isActive,
    required this.autoCreate,
    required this.splitConfig,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'recurringId': recurringId,
      'baseExpenseId': baseExpenseId,
      'groupId': groupId,
      'payerId': payerId,
      'amount': amount,
      'currency': currency,
      'category': category,
      'description': description,
      'frequency': frequency.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'isActive': isActive,
      'autoCreate': autoCreate,
      'splitConfig': splitConfig,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseModel(
      recurringId: json['recurringId'] ?? '',
      baseExpenseId: json['baseExpenseId'] ?? '',
      groupId: json['groupId'] ?? '',
      payerId: json['payerId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      category: json['category'] ?? 'OTHER',
      description: json['description'] ?? '',
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => RecurringFrequency.MONTHLY,
      ),
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: json['endDate'] != null
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      nextDueDate: (json['nextDueDate'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? true,
      autoCreate: json['autoCreate'] ?? false,
      splitConfig: json['splitConfig'] ?? {},
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  RecurringExpenseModel copyWith({
    String? recurringId,
    String? baseExpenseId,
    String? groupId,
    String? payerId,
    double? amount,
    String? currency,
    String? category,
    String? description,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? isActive,
    bool? autoCreate,
    Map<String, dynamic>? splitConfig,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return RecurringExpenseModel(
      recurringId: recurringId ?? this.recurringId,
      baseExpenseId: baseExpenseId ?? this.baseExpenseId,
      groupId: groupId ?? this.groupId,
      payerId: payerId ?? this.payerId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      autoCreate: autoCreate ?? this.autoCreate,
      splitConfig: splitConfig ?? this.splitConfig,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
