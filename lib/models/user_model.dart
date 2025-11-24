import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? profilePicture;
  final String? phone;
  final String currency; // default currency
  final String language; // default language
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.profilePicture,
    this.phone,
    this.currency = 'USD',
    this.language = 'en',
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'profilePicture': profilePicture,
      'phone': phone,
      'currency': currency,
      'language': language,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
      phone: json['phone'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      language: json['language'] as String? ?? 'en',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create copy with modified fields
  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? profilePicture,
    String? phone,
    String? currency,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      phone: phone ?? this.phone,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
