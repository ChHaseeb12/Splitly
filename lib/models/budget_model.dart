// Budget Model for Advanced Budgeting
class BudgetModel {
  final String id;
  final String userId;
  final String? groupId;
  final String name;
  final double amount;
  final String currency;
  final BudgetPeriod period;
  final String? category;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final double spent;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.userId,
    this.groupId,
    required this.name,
    required this.amount,
    required this.currency,
    required this.period,
    this.category,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.spent = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remaining => amount - spent;
  double get percentageUsed => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;
  bool get isNearLimit => percentageUsed >= 80 && percentageUsed < 100;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      groupId: json['groupId'] as String?,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString() == 'BudgetPeriod.${json['period']}',
        orElse: () => BudgetPeriod.MONTHLY,
      ),
      category: json['category'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'groupId': groupId,
      'name': name,
      'amount': amount,
      'currency': currency,
      'period': period.toString().split('.').last,
      'category': category,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'spent': spent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? groupId,
    String? name,
    double? amount,
    String? currency,
    BudgetPeriod? period,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? spent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      spent: spent ?? this.spent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum BudgetPeriod { DAILY, WEEKLY, MONTHLY, QUARTERLY, YEARLY, CUSTOM }
