import 'package:cloud_firestore/cloud_firestore.dart';

class SavedSplitModel {
  final String savedSplitId;
  final String userId;
  final String name;
  final String splitType; // EQUAL, UNEQUAL, PERCENTAGE, SHARES
  final List<String> participantIds;
  final Map<String, double> splitData; // userId -> amount/percentage/shares
  final Timestamp createdAt;

  SavedSplitModel({
    required this.savedSplitId,
    required this.userId,
    required this.name,
    required this.splitType,
    required this.participantIds,
    required this.splitData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'savedSplitId': savedSplitId,
      'userId': userId,
      'name': name,
      'splitType': splitType,
      'participantIds': participantIds,
      'splitData': splitData,
      'createdAt': createdAt,
    };
  }

  factory SavedSplitModel.fromJson(Map<String, dynamic> json) {
    return SavedSplitModel(
      savedSplitId: json['savedSplitId'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      splitType: json['splitType'] ?? 'EQUAL',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      splitData: Map<String, double>.from(
        (json['splitData'] ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  SavedSplitModel copyWith({
    String? savedSplitId,
    String? userId,
    String? name,
    String? splitType,
    List<String>? participantIds,
    Map<String, double>? splitData,
    Timestamp? createdAt,
  }) {
    return SavedSplitModel(
      savedSplitId: savedSplitId ?? this.savedSplitId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      splitType: splitType ?? this.splitType,
      participantIds: participantIds ?? this.participantIds,
      splitData: splitData ?? this.splitData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
