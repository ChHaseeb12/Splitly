import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendStatus { pending, accepted, blocked }

class FriendModel {
  final String friendId;
  final String userId1;
  final String userId2;
  final FriendStatus status;
  final DateTime createdAt;

  FriendModel({
    required this.friendId,
    required this.userId1,
    required this.userId2,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'userId1': userId1,
      'userId2': userId2,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
    };
  }

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      friendId: json['friendId'] as String,
      userId1: json['userId1'] as String,
      userId2: json['userId2'] as String,
      status: FriendStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => FriendStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  FriendModel copyWith({
    String? friendId,
    String? userId1,
    String? userId2,
    FriendStatus? status,
    DateTime? createdAt,
  }) {
    return FriendModel(
      friendId: friendId ?? this.friendId,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
