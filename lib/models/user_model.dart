// ============================================================================
// QUIRZY - PROPRIETARY AND CONFIDENTIAL
// ============================================================================
// Copyright (c) 2025 Quirzy. All Rights Reserved.
//
// This source code is licensed under the Quirzy Proprietary License.
// See the LICENSE file in the root directory for full terms.
//
// UNAUTHORIZED COPYING, MODIFICATION, DISTRIBUTION, OR USE IS STRICTLY
// -PROHIBITED. This code is provided for VIEWING PURPOSES ONLY.
// ============================================================================

import 'package:image_picker/image_picker.dart';

/// User model representing the authenticated user data
class UserModel {
  final String? id;
  final String? email;
  final String? username;
  final String? token;
  final String? photoUrl;
  final XFile? profileImage;

  const UserModel({
    this.id,
    this.email,
    this.username,
    this.token,
    this.photoUrl,
    this.profileImage,
  });

  /// Create UserModel from JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email'] as String?,
      username: json['name'] as String? ?? json['username'] as String?,
      token: json['token'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'token': token,
      'photoUrl': photoUrl,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? token,
    String? photoUrl,
    XFile? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      token: token ?? this.token,
      photoUrl: photoUrl ?? this.photoUrl,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  /// Check if user is valid/authenticated
  bool get isValid => token != null && token!.isNotEmpty;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, photoUrl: $photoUrl, hasToken: ${token != null})';
  }
}
