import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

/// User model supporting farmer, buyer, and admin roles.
@immutable
class UserModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String role; // 'farmer' | 'buyer' | 'admin'
  final bool isVerified;
  final String? village;
  final String? district;
  final String? organization;
  final String? profileImageUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    this.email,
    this.village,
    this.district,
    this.organization,
    this.profileImageUrl,
  });

  bool get isFarmer => role == AppConstants.roleFarmer;
  bool get isBuyer => role == AppConstants.roleBuyer;
  bool get isAdmin => role == AppConstants.roleAdmin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? AppConstants.roleBuyer,
      isVerified: json['is_verified'] as bool? ?? false,
      village: json['village']?.toString(),
      district: json['district']?.toString(),
      organization: json['org']?.toString() ?? json['organization']?.toString(),
      profileImageUrl: json['profile_image']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'role': role,
        'is_verified': isVerified,
        if (village != null) 'village': village,
        if (district != null) 'district': district,
        if (organization != null) 'org': organization,
        if (profileImageUrl != null) 'profile_image': profileImageUrl,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? email,
    bool? isVerified,
    String? village,
    String? district,
    String? organization,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone,
      email: email ?? this.email,
      role: role,
      isVerified: isVerified ?? this.isVerified,
      village: village ?? this.village,
      district: district ?? this.district,
      organization: organization ?? this.organization,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
    );
  }
}
