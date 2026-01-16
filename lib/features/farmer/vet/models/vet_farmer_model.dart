class VetFarmer {
  final String id;
  final String name;
  final String userId;
  final User? user;
  final String officerType;
  final String educationLevel;
  final String? region;
  final String dateOfBirth;
  final Location location;
  final int age;
  final String gender;
  final int yearsOfExperience;
  final String profileBio;
  final String? idPhotoUrl;
  final String? faceSelfieUrl;
  final List<String> certificateUrls;
  final List<String> additionalCertificateUrls;
  final String? licenseNumber;
  final String? licenseExpiryDate;
  final String status;
  final bool isVerified;
  final String? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;
  final String? suspensionReason;
  final Specializations? specializations;
  final CoverageAreas? coverageAreas;
  final bool isAvailable;
  final String averageRating;
  final String tier;
  final int totalJobsCompleted;
  final int totalRatingsCount;
  final String totalEarnings;
  final String currentMonthEarnings;
  final List<VaccinationRecord> vaccinationRecords;
  final int totalAppraisals;
  final ContactInfo? contactInfo;
  final Metadata? metadata;
  final List<dynamic>? appraisals;
  final String createdAt;
  final String updatedAt;

  VetFarmer({
    required this.id,
    required this.name,
    required this.userId,
    this.user,
    required this.officerType,
    required this.educationLevel,
    this.region,
    required this.dateOfBirth,
    required this.location,
    required this.age,
    required this.gender,
    required this.yearsOfExperience,
    required this.profileBio,
    this.idPhotoUrl,
    this.faceSelfieUrl,
    required this.certificateUrls,
    required this.additionalCertificateUrls,
    this.licenseNumber,
    this.licenseExpiryDate,
    required this.status,
    required this.isVerified,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
    this.suspensionReason,
    this.specializations,
    this.coverageAreas,
    required this.isAvailable,
    required this.averageRating,
    required this.tier,
    required this.totalJobsCompleted,
    required this.totalRatingsCount,
    required this.totalEarnings,
    required this.currentMonthEarnings,
    required this.vaccinationRecords,
    required this.totalAppraisals,
    this.contactInfo,
    this.metadata,
    this.appraisals,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VetFarmer.fromJson(Map<String, dynamic> json) {
    return VetFarmer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      officerType: json['officer_type'] as String? ?? '',
      educationLevel: json['education_level'] as String? ?? '',
      region: json['region'] as String?,
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      location: Location.fromJson(json['location']),
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 0,
      profileBio: json['profile_bio'] as String? ?? '',
      idPhotoUrl: json['id_photo_url'] as String?,
      faceSelfieUrl: json['face_selfie_url'] as String?,
      certificateUrls: (json['certificate_urls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      additionalCertificateUrls:
      (json['additional_certificate_urls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      licenseNumber: json['license_number'] as String?,
      licenseExpiryDate: json['license_expiry_date'] as String?,
      status: json['status'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: json['verified_at'] as String?,
      verifiedBy: json['verified_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      suspensionReason: json['suspension_reason'] as String?,
      specializations: json['specializations'] != null
          ? Specializations.fromJson(json['specializations'])
          : null,
      coverageAreas: json['coverage_areas'] != null
          ? CoverageAreas.fromJson(json['coverage_areas'])
          : null,
      isAvailable: json['is_available'] as bool? ?? false,
      averageRating: json['average_rating'] as String? ?? '0.0',
      tier: json['tier'] as String? ?? '',
      totalJobsCompleted: (json['total_jobs_completed'] as num?)?.toInt() ?? 0,
      totalRatingsCount: (json['total_ratings_count'] as num?)?.toInt() ?? 0,
      totalEarnings: json['total_earnings'] as String? ?? '0.00',
      currentMonthEarnings:
      json['current_month_earnings'] as String? ?? '0.00',
      vaccinationRecords: (json['vaccination_records'] as List<dynamic>?)
          ?.map((e) => VaccinationRecord.fromJson(e))
          .toList() ??
          [],
      totalAppraisals: (json['total_appraisals'] as num?)?.toInt() ?? 0,
      contactInfo: json['contact_info'] != null
          ? ContactInfo.fromJson(json['contact_info'])
          : null,
      metadata:
      json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      appraisals: json['appraisals'] as List<dynamic>?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class Location {
  final Address address;
  final double latitude;
  final double longitude;

  Location({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: Address.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Address {
  final String? city;
  final String? county;
  final String? subCounty;
  final String formattedAddress;

  Address({
    this.city,
    this.county,
    this.subCounty,
    required this.formattedAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'] as String?,
      county: json['county'] as String?,
      subCounty: json['sub_county'] as String?,
      formattedAddress: json['formatted_address'] as String? ?? '',
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final bool is2faEnabled;
  final String? emailVerificationExpiresAt;
  final String? lastVerificationSentAt;
  final String? refreshTokenExpiresAt;
  final String? passwordResetExpiresAt;
  final String status;
  final String? avatar;
  final String? googleId;
  final String? appleId;
  final String? oauthProvider;
  final String roleId;
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
    required this.phoneNumber,
    required this.is2faEnabled,
    this.emailVerificationExpiresAt,
    this.lastVerificationSentAt,
    this.refreshTokenExpiresAt,
    this.passwordResetExpiresAt,
    required this.status,
    this.avatar,
    this.googleId,
    this.appleId,
    this.oauthProvider,
    required this.roleId,
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
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      is2faEnabled: json['is_2fa_enabled'] as bool? ?? false,
      emailVerificationExpiresAt:
      json['email_verification_expires_at'] as String?,
      lastVerificationSentAt: json['last_verification_sent_at'] as String?,
      refreshTokenExpiresAt: json['refresh_token_expires_at'] as String?,
      passwordResetExpiresAt: json['password_reset_expires_at'] as String?,
      status: json['status'] as String? ?? '',
      avatar: json['avatar'] as String?,
      googleId: json['google_id'] as String?,
      appleId: json['apple_id'] as String?,
      oauthProvider: json['oauth_provider'] as String?,
      roleId: json['role_id'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      lockedUntil: json['locked_until'] as String?,
      firstLogin: json['first_login'] as String?,
      lastLogin: json['last_login'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      deletedAt: json['deleted_at'] as String?,
      agreedToTerms: json['agreed_to_terms'] as bool? ?? false,
      agreedToTermsAt: json['agreed_to_terms_at'] as String?,
    );
  }
}

class Specializations {
  final List<String> areas;
  final List<String> certifications;

  Specializations({
    required this.areas,
    required this.certifications,
  });

  factory Specializations.fromJson(Map<String, dynamic> json) {
    return Specializations(
      areas: (json['areas'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

class CoverageAreas {
  final List<String> counties;
  final List<String> subCounties;

  CoverageAreas({
    required this.counties,
    required this.subCounties,
  });

  factory CoverageAreas.fromJson(Map<String, dynamic> json) {
    return CoverageAreas(
      counties: (json['counties'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      subCounties: (json['sub_counties'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

class VaccinationRecord {
  final String date;
  final String vaccine;
  final int birdsCount;

  VaccinationRecord({
    required this.date,
    required this.vaccine,
    required this.birdsCount,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      date: json['date'] as String? ?? '',
      vaccine: json['vaccine'] as String? ?? '',
      birdsCount: (json['birds_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ContactInfo {
  final String whatsapp;
  final String alternativePhone;

  ContactInfo({
    required this.whatsapp,
    required this.alternativePhone,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      whatsapp: json['whatsapp'] as String? ?? '',
      alternativePhone: json['alternative_phone'] as String? ?? '',
    );
  }
}

class Metadata {
  final String organization;

  Metadata({
    required this.organization,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      organization: json['organization'] as String? ?? '',
    );
  }
}

class VetFarmerListResponse {
  final List<VetFarmer> data;
  final int total;
  final int page;
  final int limit;

  VetFarmerListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory VetFarmerListResponse.fromJson(Map<String, dynamic> json) {
    return VetFarmerListResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((x) => VetFarmer.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );
  }
}



class VetFarmerRecommendation {
  final String id;
  final String name;
  final String userId;
  final String officerType;
  final String educationLevel;
  final String? region;
  final String dateOfBirth;
  final Location location;
  final int age;
  final String gender;
  final int yearsOfExperience;
  final String profileBio;
  final String? idPhotoUrl;
  final String? faceSelfieUrl;
  final List<String> certificateUrls;
  final List<String> additionalCertificateUrls;
  final String? licenseNumber;
  final String? licenseExpiryDate;
  final String status;
  final bool isVerified;
  final String? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;
  final String? suspensionReason;
  final Specializations? specializations;
  final CoverageAreas? coverageAreas;
  final bool isAvailable;
  final String averageRating;
  final String tier;
  final int totalJobsCompleted;
  final int totalRatingsCount;
  final String totalEarnings;
  final String currentMonthEarnings;
  final List<VaccinationRecord> vaccinationRecords;
  final int totalAppraisals;
  final ContactInfo? contactInfo;
  final Metadata? metadata;
  final String createdAt;
  final String updatedAt;
  final String matchType;

  VetFarmerRecommendation({
    required this.id,
    required this.name,
    required this.userId,
    required this.officerType,
    required this.educationLevel,
    this.region,
    required this.dateOfBirth,
    required this.location,
    required this.age,
    required this.gender,
    required this.yearsOfExperience,
    required this.profileBio,
    this.idPhotoUrl,
    this.faceSelfieUrl,
    required this.certificateUrls,
    required this.additionalCertificateUrls,
    this.licenseNumber,
    this.licenseExpiryDate,
    required this.status,
    required this.isVerified,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
    this.suspensionReason,
    this.specializations,
    this.coverageAreas,
    required this.isAvailable,
    required this.averageRating,
    required this.tier,
    required this.totalJobsCompleted,
    required this.totalRatingsCount,
    required this.totalEarnings,
    required this.currentMonthEarnings,
    required this.vaccinationRecords,
    required this.totalAppraisals,
    this.contactInfo,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.matchType,
  });

  factory VetFarmerRecommendation.fromJson(Map<String, dynamic> json) {
    return VetFarmerRecommendation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      officerType: json['officer_type'] as String? ?? '',
      educationLevel: json['education_level'] as String? ?? '',
      region: json['region'] as String?,
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      location: Location.fromJson(json['location']),
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 0,
      profileBio: json['profile_bio'] as String? ?? '',
      idPhotoUrl: json['id_photo_url'] as String?,
      faceSelfieUrl: json['face_selfie_url'] as String?,
      certificateUrls: (json['certificate_urls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      additionalCertificateUrls:
      (json['additional_certificate_urls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      licenseNumber: json['license_number'] as String?,
      licenseExpiryDate: json['license_expiry_date'] as String?,
      status: json['status'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedAt: json['verified_at'] as String?,
      verifiedBy: json['verified_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      suspensionReason: json['suspension_reason'] as String?,
      specializations: json['specializations'] != null
          ? Specializations.fromJson(json['specializations'])
          : null,
      coverageAreas: json['coverage_areas'] != null
          ? CoverageAreas.fromJson(json['coverage_areas'])
          : null,
      isAvailable: json['is_available'] as bool? ?? false,
      averageRating: json['average_rating'] as String? ?? '0.0',
      tier: json['tier'] as String? ?? '',
      totalJobsCompleted: (json['total_jobs_completed'] as num?)?.toInt() ?? 0,
      totalRatingsCount: (json['total_ratings_count'] as num?)?.toInt() ?? 0,
      totalEarnings: json['total_earnings'] as String? ?? '0.00',
      currentMonthEarnings:
      json['current_month_earnings'] as String? ?? '0.00',
      vaccinationRecords: (json['vaccination_records'] as List<dynamic>?)
          ?.map((e) => VaccinationRecord.fromJson(e))
          .toList() ??
          [],
      totalAppraisals: (json['total_appraisals'] as num?)?.toInt() ?? 0,
      contactInfo: json['contact_info'] != null
          ? ContactInfo.fromJson(json['contact_info'])
          : null,
      metadata:
      json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      matchType: json['match_type'] as String? ?? '',
    );
  }
}
