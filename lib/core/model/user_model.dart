class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final int expiresIn;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      sessionId: json['session_id'],
      expiresIn: json['expires_in'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'session_id': sessionId,
      'expires_in': expiresIn,
      'user': user.toJson(),
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
  final String? lastVerificationSentAt; // This was missing
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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'] ?? "Not Provided",
      phoneNumber: json['phone_number'],
      is2faEnabled: json['is_2fa_enabled'] ?? false,
      emailVerificationExpiresAt: json['email_verification_expires_at'],
      lastVerificationSentAt: json['last_verification_sent_at'],
      refreshTokenExpiresAt: json['refresh_token_expires_at'],
      passwordResetExpiresAt: json['password_reset_expires_at'],
      status: json['status'] ?? 'active',
      avatar: json['avatar'],
      googleId: json['google_id'],
      appleId: json['apple_id'],
      oauthProvider: json['oauth_provider'] ?? 'email',
      roleId: json['role_id'],
      role: Role.fromJson(json['role']),
      isActive: json['is_active'] ?? true,
      lockedUntil: json['locked_until'],
      firstLogin: json['first_login'],
      lastLogin: json['last_login'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      agreedToTerms: json['agreed_to_terms'] ?? false,
      agreedToTermsAt: json['agreed_to_terms_at'],
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
    };
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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isSystemRole: json['is_system_role'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
