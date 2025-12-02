// Comment Model for Social Features
class CommentModel {
  final String id;
  final String expenseId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommentModel({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      expenseId: json['expenseId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseId': expenseId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? expenseId,
    String? userId,
    String? userName,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Activity Feed Item Model
class ActivityFeedItem {
  final String id;
  final String userId;
  final String userName;
  final ActivityType type;
  final String description;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  ActivityFeedItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.description,
    required this.data,
    required this.createdAt,
  });

  factory ActivityFeedItem.fromJson(Map<String, dynamic> json) {
    return ActivityFeedItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
        orElse: () => ActivityType.OTHER,
      ),
      description: json['description'] as String,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type.toString().split('.').last,
      'description': description,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum ActivityType {
  EXPENSE_ADDED,
  EXPENSE_UPDATED,
  EXPENSE_DELETED,
  PAYMENT_MADE,
  COMMENT_ADDED,
  FRIEND_JOINED,
  GROUP_CREATED,
  OTHER,
}
