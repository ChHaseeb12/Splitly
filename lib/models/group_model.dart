import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMember {
  final String userId;
  final DateTime joinDate;

  GroupMember({
    required this.userId,
    required this.joinDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'joinDate': joinDate,
    };
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['userId'] as String,
      joinDate: (json['joinDate'] as Timestamp).toDate(),
    );
  }
}

class GroupModel {
  final String groupId;
  final String name;
  final String? description;
  final String createdBy;
  final List<GroupMember> members;
  final String currency;
  final bool simplificationEnabled;
  final bool notificationsEnabled;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupModel({
    required this.groupId,
    required this.name,
    this.description,
    required this.createdBy,
    required this.members,
    this.currency = 'USD',
    this.simplificationEnabled = true,
    this.notificationsEnabled = true,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'members': members.map((m) => m.toJson()).toList(),
      'currency': currency,
      'simplificationEnabled': simplificationEnabled,
      'notificationsEnabled': notificationsEnabled,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    var memberList = (json['members'] as List<dynamic>?)
            ?.map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return GroupModel(
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdBy: json['createdBy'] as String,
      members: memberList,
      currency: json['currency'] as String? ?? 'USD',
      simplificationEnabled: json['simplificationEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      profileImage: json['profileImage'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  GroupModel copyWith({
    String? groupId,
    String? name,
    String? description,
    String? createdBy,
    List<GroupMember>? members,
    String? currency,
    bool? simplificationEnabled,
    bool? notificationsEnabled,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      currency: currency ?? this.currency,
      simplificationEnabled:
          simplificationEnabled ?? this.simplificationEnabled,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
