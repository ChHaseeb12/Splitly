import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseStatus { pending, settled, archived }

enum SplitType { equal, unequal, percentage, shares }

class ExpenseParticipant {
  final String userId;
  final double splitAmount;

  ExpenseParticipant({required this.userId, required this.splitAmount});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'splitAmount': splitAmount};
  }

  factory ExpenseParticipant.fromJson(Map<String, dynamic> json) {
    return ExpenseParticipant(
      userId: json['userId'] as String,
      splitAmount: (json['splitAmount'] as num).toDouble(),
    );
  }
}

class ExpenseModel {
  final String expenseId;
  final String groupId;
  final String payerId;
  final double amount;
  final String currency;
  final String category;
  final String? description;
  final DateTime date;
  final List<ExpenseParticipant> participants;
  final SplitType splitType;
  final ExpenseStatus status;
  final List<String> attachments; // URLs to receipt images
  final String? notes; // Detailed notes
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.expenseId,
    required this.groupId,
    required this.payerId,
    required this.amount,
    this.currency = 'USD',
    required this.category,
    this.description,
    required this.date,
    required this.participants,
    this.splitType = SplitType.equal,
    this.status = ExpenseStatus.pending,
    this.attachments = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'groupId': groupId,
      'payerId': payerId,
      'amount': amount,
      'currency': currency,
      'category': category,
      'description': description,
      'date': date,
      'participants': participants.map((p) => p.toJson()).toList(),
      'splitType': splitType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'attachments': attachments,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    var participantList =
        (json['participants'] as List<dynamic>?)
            ?.map((p) => ExpenseParticipant.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return ExpenseModel(
      expenseId: json['expenseId'] as String,
      groupId: json['groupId'] as String,
      payerId: json['payerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      category: json['category'] as String,
      description: json['description'] as String?,
      date: (json['date'] as Timestamp).toDate(),
      participants: participantList,
      splitType: SplitType.values.firstWhere(
        (e) => e.toString().split('.').last == json['splitType'],
        orElse: () => SplitType.equal,
      ),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      attachments: List<String>.from(json['attachments'] ?? []),
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  ExpenseModel copyWith({
    String? expenseId,
    String? groupId,
    String? payerId,
    double? amount,
    String? currency,
    String? category,
    String? description,
    DateTime? date,
    List<ExpenseParticipant>? participants,
    SplitType? splitType,
    ExpenseStatus? status,
    List<String>? attachments,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      expenseId: expenseId ?? this.expenseId,
      groupId: groupId ?? this.groupId,
      payerId: payerId ?? this.payerId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      participants: participants ?? this.participants,
      splitType: splitType ?? this.splitType,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
