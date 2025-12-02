// Notification Model for Push Notifications
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.OTHER,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  EXPENSE_ADDED,
  EXPENSE_UPDATED,
  EXPENSE_DELETED,
  FRIEND_REQUEST,
  FRIEND_ACCEPTED,
  PAYMENT_RECEIVED,
  PAYMENT_SENT,
  DEBT_REMINDER,
  GROUP_INVITE,
  GROUP_EXPENSE,
  COMMENT_ADDED,
  BUDGET_ALERT,
  OTHER,
}

// Notification Preferences Model
class NotificationPreferences {
  final String userId;
  final bool expenseNotifications;
  final bool friendNotifications;
  final bool paymentNotifications;
  final bool groupNotifications;
  final bool budgetNotifications;
  final bool emailNotifications;
  final bool pushNotifications;

  NotificationPreferences({
    required this.userId,
    this.expenseNotifications = true,
    this.friendNotifications = true,
    this.paymentNotifications = true,
    this.groupNotifications = true,
    this.budgetNotifications = true,
    this.emailNotifications = false,
    this.pushNotifications = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      userId: json['userId'] as String,
      expenseNotifications: json['expenseNotifications'] as bool? ?? true,
      friendNotifications: json['friendNotifications'] as bool? ?? true,
      paymentNotifications: json['paymentNotifications'] as bool? ?? true,
      groupNotifications: json['groupNotifications'] as bool? ?? true,
      budgetNotifications: json['budgetNotifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'expenseNotifications': expenseNotifications,
      'friendNotifications': friendNotifications,
      'paymentNotifications': paymentNotifications,
      'groupNotifications': groupNotifications,
      'budgetNotifications': budgetNotifications,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
    };
  }

  NotificationPreferences copyWith({
    String? userId,
    bool? expenseNotifications,
    bool? friendNotifications,
    bool? paymentNotifications,
    bool? groupNotifications,
    bool? budgetNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return NotificationPreferences(
      userId: userId ?? this.userId,
      expenseNotifications: expenseNotifications ?? this.expenseNotifications,
      friendNotifications: friendNotifications ?? this.friendNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      groupNotifications: groupNotifications ?? this.groupNotifications,
      budgetNotifications: budgetNotifications ?? this.budgetNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}
