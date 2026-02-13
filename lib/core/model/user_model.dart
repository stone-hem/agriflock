import 'package:agriflock360/core/utils/type_safe_utils.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final int expiresIn;
  final User user;
  final String? currency;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.expiresIn,
    required this.user,
    this.currency,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userMap = TypeUtils.toMapSafe(json['user']);

    return LoginResponse(
      accessToken: TypeUtils.toStringSafe(json['access_token']),
      refreshToken: TypeUtils.toStringSafe(json['refresh_token']),
      sessionId: TypeUtils.toStringSafe(json['session_id']),
      expiresIn: TypeUtils.toIntSafe(json['expires_in']),
      user: User.fromJson(userMap ?? {}),
      currency: TypeUtils.toNullableStringSafe(json['currency']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'session_id': sessionId,
      'expires_in': expiresIn,
      'user': user.toJson(),
      'currency': currency,
    };
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final bool is2faEnabled;
  final String? emailVerificationExpiresAt;
  final String? lastVerificationSentAt;
  final String? refreshTokenExpiresAt;
  final String? passwordResetExpiresAt;
  final String status;
  final String? avatar;
  final String? googleId;
  final String? appleId;
  final String oauthProvider;
  final String roleId;
  final Role role;
  final bool isActive;
  final String? lockedUntil;
  final String? firstLogin;
  final String? lastLogin;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final bool agreedToTerms;
  final String? agreedToTermsAt;
  final String? nationalId;
  final String? dateOfBirth;
  final String? gender;
  final String? poultryType;
  final num? chickenHouseCapacity;
  final num? yearsOfExperience;
  final num? currentNumberOfChickens;
  final String? preferredAgrovetName;
  final String? preferredFeedCompany;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.is2faEnabled,
    this.emailVerificationExpiresAt,
    this.lastVerificationSentAt,
    this.refreshTokenExpiresAt,
    this.passwordResetExpiresAt,
    required this.status,
    this.avatar,
    this.googleId,
    this.appleId,
    required this.oauthProvider,
    required this.roleId,
    required this.role,
    required this.isActive,
    this.lockedUntil,
    this.firstLogin,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.agreedToTerms,
    this.agreedToTermsAt,
    this.nationalId,
    this.dateOfBirth,
    this.gender,
    this.poultryType,
    this.chickenHouseCapacity,
    this.yearsOfExperience,
    this.currentNumberOfChickens,
    this.preferredAgrovetName,
    this.preferredFeedCompany,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final roleMap = TypeUtils.toMapSafe(json['role']);

    return User(
      id: TypeUtils.toStringSafe(json['id']),
      email: TypeUtils.toStringSafe(json['email']),
      name: TypeUtils.toStringSafe(json['name'], defaultValue: 'Not Provided'),
      phoneNumber: TypeUtils.toNullableStringSafe(json['phone_number']),
      is2faEnabled: TypeUtils.toBoolSafe(json['is_2fa_enabled']),
      emailVerificationExpiresAt: TypeUtils.toNullableStringSafe(json['email_verification_expires_at']),
      lastVerificationSentAt: TypeUtils.toNullableStringSafe(json['last_verification_sent_at']),
      refreshTokenExpiresAt: TypeUtils.toNullableStringSafe(json['refresh_token_expires_at']),
      passwordResetExpiresAt: TypeUtils.toNullableStringSafe(json['password_reset_expires_at']),
      status: TypeUtils.toStringSafe(json['status'], defaultValue: 'active'),
      avatar: TypeUtils.toNullableStringSafe(json['avatar']),
      googleId: TypeUtils.toNullableStringSafe(json['google_id']),
      appleId: TypeUtils.toNullableStringSafe(json['apple_id']),
      oauthProvider: TypeUtils.toStringSafe(json['oauth_provider'], defaultValue: 'email'),
      roleId: TypeUtils.toStringSafe(json['role_id']),
      role: Role.fromJson(roleMap ?? {}),
      isActive: TypeUtils.toBoolSafe(json['is_active'], defaultValue: true),
      lockedUntil: TypeUtils.toNullableStringSafe(json['locked_until']),
      firstLogin: TypeUtils.toNullableStringSafe(json['first_login']),
      lastLogin: TypeUtils.toNullableStringSafe(json['last_login']),
      createdAt: TypeUtils.toStringSafe(json['created_at']),
      updatedAt: TypeUtils.toStringSafe(json['updated_at']),
      deletedAt: TypeUtils.toNullableStringSafe(json['deleted_at']),
      agreedToTerms: TypeUtils.toBoolSafe(json['agreed_to_terms']),
      agreedToTermsAt: TypeUtils.toNullableStringSafe(json['agreed_to_terms_at']),
      nationalId: TypeUtils.toNullableStringSafe(json['national_id']),
      dateOfBirth: TypeUtils.toNullableStringSafe(json['date_of_birth']),
      gender: TypeUtils.toNullableStringSafe(json['gender']),
      poultryType: TypeUtils.toNullableStringSafe(json['poultry_type']),
      chickenHouseCapacity: json['chicken_house_capacity'], // Keep as num
      yearsOfExperience: json['years_of_experience'], // Keep as num
      currentNumberOfChickens: json['current_number_of_chickens'], // Keep as num
      preferredAgrovetName: TypeUtils.toNullableStringSafe(json['preferred_agrovet_name']),
      preferredFeedCompany: TypeUtils.toNullableStringSafe(json['preferred_feed_company']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'is_2fa_enabled': is2faEnabled,
      'email_verification_expires_at': emailVerificationExpiresAt,
      'last_verification_sent_at': lastVerificationSentAt,
      'refresh_token_expires_at': refreshTokenExpiresAt,
      'password_reset_expires_at': passwordResetExpiresAt,
      'status': status,
      'avatar': avatar,
      'google_id': googleId,
      'apple_id': appleId,
      'oauth_provider': oauthProvider,
      'role_id': roleId,
      'role': role.toJson(),
      'is_active': isActive,
      'locked_until': lockedUntil,
      'first_login': firstLogin,
      'last_login': lastLogin,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'agreed_to_terms': agreedToTerms,
      'agreed_to_terms_at': agreedToTermsAt,
      'national_id': nationalId,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'poultry_type': poultryType,
      'chicken_house_capacity': chickenHouseCapacity,
      'years_of_experience': yearsOfExperience,
      'current_number_of_chickens': currentNumberOfChickens,
      'preferred_agrovet_name': preferredAgrovetName,
      'preferred_feed_company': preferredFeedCompany,
    };
  }

  // Add copyWith method
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    bool? is2faEnabled,
    String? emailVerificationExpiresAt,
    String? lastVerificationSentAt,
    String? refreshTokenExpiresAt,
    String? passwordResetExpiresAt,
    String? status,
    String? avatar,
    String? googleId,
    String? appleId,
    String? oauthProvider,
    String? roleId,
    Role? role,
    bool? isActive,
    String? lockedUntil,
    String? firstLogin,
    String? lastLogin,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    bool? agreedToTerms,
    String? agreedToTermsAt,
    String? nationalId,
    String? dateOfBirth,
    String? gender,
    String? poultryType,
    num? chickenHouseCapacity,
    num? yearsOfExperience,
    num? currentNumberOfChickens,
    String? preferredAgrovetName,
    String? preferredFeedCompany,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      is2faEnabled: is2faEnabled ?? this.is2faEnabled,
      emailVerificationExpiresAt: emailVerificationExpiresAt ?? this.emailVerificationExpiresAt,
      lastVerificationSentAt: lastVerificationSentAt ?? this.lastVerificationSentAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
      passwordResetExpiresAt: passwordResetExpiresAt ?? this.passwordResetExpiresAt,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      googleId: googleId ?? this.googleId,
      appleId: appleId ?? this.appleId,
      oauthProvider: oauthProvider ?? this.oauthProvider,
      roleId: roleId ?? this.roleId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      firstLogin: firstLogin ?? this.firstLogin,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      agreedToTermsAt: agreedToTermsAt ?? this.agreedToTermsAt,
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      poultryType: poultryType ?? this.poultryType,
      chickenHouseCapacity: chickenHouseCapacity ?? this.chickenHouseCapacity,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      currentNumberOfChickens: currentNumberOfChickens ?? this.currentNumberOfChickens,
      preferredAgrovetName: preferredAgrovetName ?? this.preferredAgrovetName,
      preferredFeedCompany: preferredFeedCompany ?? this.preferredFeedCompany,
    );
  }
}

class Role {
  final String id;
  final String name;
  final String description;
  final bool isSystemRole;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.isSystemRole,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      description: TypeUtils.toStringSafe(json['description']),
      isSystemRole: TypeUtils.toBoolSafe(json['is_system_role']),
      isActive: TypeUtils.toBoolSafe(json['is_active']),
      createdAt: TypeUtils.toStringSafe(json['created_at']),
      updatedAt: TypeUtils.toStringSafe(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_system_role': isSystemRole,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}