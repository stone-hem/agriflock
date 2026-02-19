import 'package:agriflock360/core/utils/type_safe_utils.dart';

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
    final userMap = TypeUtils.toMapSafe(json['user']);
    final locationMap = TypeUtils.toMapSafe(json['location']);
    final specializationsMap = TypeUtils.toMapSafe(json['specializations']);
    final coverageAreasMap = TypeUtils.toMapSafe(json['coverage_areas']);
    final contactInfoMap = TypeUtils.toMapSafe(json['contact_info']);
    final metadataMap = TypeUtils.toMapSafe(json['metadata']);

    final certificateUrlsList = TypeUtils.toListSafe<dynamic>(json['certificate_urls']);
    final additionalCertificateUrlsList = TypeUtils.toListSafe<dynamic>(json['additional_certificate_urls']);
    final vaccinationRecordsList = TypeUtils.toListSafe<dynamic>(json['vaccination_records']);
    final appraisalsList = TypeUtils.toListSafe<dynamic>(json['appraisals']);

    return VetFarmer(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      user: userMap != null ? User.fromJson(userMap) : null,
      officerType: TypeUtils.toStringSafe(json['officer_type']),
      educationLevel: TypeUtils.toStringSafe(json['education_level']),
      region: TypeUtils.toNullableStringSafe(json['region']),
      dateOfBirth: TypeUtils.toStringSafe(json['date_of_birth']),
      location: Location.fromJson(locationMap ?? {}),
      age: TypeUtils.toIntSafe(json['age']),
      gender: TypeUtils.toStringSafe(json['gender']),
      yearsOfExperience: TypeUtils.toIntSafe(json['years_of_experience']),
      profileBio: TypeUtils.toStringSafe(json['profile_bio']),
      idPhotoUrl: TypeUtils.toNullableStringSafe(json['id_photo_url']),
      faceSelfieUrl: TypeUtils.toNullableStringSafe(json['face_selfie_url']),
      certificateUrls: certificateUrlsList
          .map((e) => TypeUtils.toStringSafe(e))
          .toList(),
      additionalCertificateUrls: additionalCertificateUrlsList
          .map((e) => TypeUtils.toStringSafe(e))
          .toList(),
      licenseNumber: TypeUtils.toNullableStringSafe(json['license_number']),
      licenseExpiryDate: TypeUtils.toNullableStringSafe(json['license_expiry_date']),
      status: TypeUtils.toStringSafe(json['status']),
      isVerified: TypeUtils.toBoolSafe(json['is_verified']),
      verifiedAt: TypeUtils.toNullableStringSafe(json['verified_at']),
      verifiedBy: TypeUtils.toNullableStringSafe(json['verified_by']),
      rejectionReason: TypeUtils.toNullableStringSafe(json['rejection_reason']),
      suspensionReason: TypeUtils.toNullableStringSafe(json['suspension_reason']),
      specializations: specializationsMap != null
          ? Specializations.fromJson(specializationsMap)
          : null,
      coverageAreas: coverageAreasMap != null
          ? CoverageAreas.fromJson(coverageAreasMap)
          : null,
      isAvailable: TypeUtils.toBoolSafe(json['is_available']),
      averageRating: TypeUtils.toStringSafe(json['average_rating'], defaultValue: '0.0'),
      tier: TypeUtils.toStringSafe(json['tier']),
      totalJobsCompleted: TypeUtils.toIntSafe(json['total_jobs_completed']),
      totalRatingsCount: TypeUtils.toIntSafe(json['total_ratings_count']),
      totalEarnings: TypeUtils.toStringSafe(json['total_earnings'], defaultValue: '0.00'),
      currentMonthEarnings: TypeUtils.toStringSafe(json['current_month_earnings'], defaultValue: '0.00'),
      vaccinationRecords: vaccinationRecordsList
          .map((e) => VaccinationRecord.fromJson(
          e is Map<String, dynamic> ? e : {}))
          .toList(),
      totalAppraisals: TypeUtils.toIntSafe(json['total_appraisals']),
      contactInfo: contactInfoMap != null
          ? ContactInfo.fromJson(contactInfoMap)
          : null,
      metadata: metadataMap != null
          ? Metadata.fromJson(metadataMap)
          : null,
      appraisals: appraisalsList,
      createdAt: TypeUtils.toStringSafe(json['created_at']),
      updatedAt: TypeUtils.toStringSafe(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'user': user?.toJson(),
      'officer_type': officerType,
      'education_level': educationLevel,
      'region': region,
      'date_of_birth': dateOfBirth,
      'location': location.toJson(),
      'age': age,
      'gender': gender,
      'years_of_experience': yearsOfExperience,
      'profile_bio': profileBio,
      'id_photo_url': idPhotoUrl,
      'face_selfie_url': faceSelfieUrl,
      'certificate_urls': certificateUrls,
      'additional_certificate_urls': additionalCertificateUrls,
      'license_number': licenseNumber,
      'license_expiry_date': licenseExpiryDate,
      'status': status,
      'is_verified': isVerified,
      'verified_at': verifiedAt,
      'verified_by': verifiedBy,
      'rejection_reason': rejectionReason,
      'suspension_reason': suspensionReason,
      'specializations': specializations?.toJson(),
      'coverage_areas': coverageAreas?.toJson(),
      'is_available': isAvailable,
      'average_rating': averageRating,
      'tier': tier,
      'total_jobs_completed': totalJobsCompleted,
      'total_ratings_count': totalRatingsCount,
      'total_earnings': totalEarnings,
      'current_month_earnings': currentMonthEarnings,
      'vaccination_records': vaccinationRecords.map((e) => e.toJson()).toList(),
      'total_appraisals': totalAppraisals,
      'contact_info': contactInfo?.toJson(),
      'metadata': metadata?.toJson(),
      'appraisals': appraisals,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Location {
  final Address? address;
  final double latitude;
  final double longitude;

  Location({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    Address? address;
    final addressValue = json['address'];

    // Handle both cases: when address is a Map or a String
    if (addressValue is Map<String, dynamic>) {
      address = Address.fromJson(addressValue);
    } else if (addressValue is String) {
      // Create an Address object with the string as formatted_address
      address = Address(
        city: null,
        county: null,
        subCounty: null,
        formattedAddress: addressValue,
      );
    }

    return Location(
      address: address,
      latitude: TypeUtils.toDoubleSafe(json['latitude']),
      longitude: TypeUtils.toDoubleSafe(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
    };
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
      city: TypeUtils.toNullableStringSafe(json['city']),
      county: TypeUtils.toNullableStringSafe(json['county']),
      subCounty: TypeUtils.toNullableStringSafe(json['sub_county']),
      formattedAddress: TypeUtils.toStringSafe(json['formatted_address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'county': county,
      'sub_county': subCounty,
      'formatted_address': formattedAddress,
    };
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
      id: TypeUtils.toStringSafe(json['id']),
      email: TypeUtils.toStringSafe(json['email']),
      name: TypeUtils.toStringSafe(json['name']),
      phoneNumber: TypeUtils.toStringSafe(json['phone_number']),
      is2faEnabled: TypeUtils.toBoolSafe(json['is_2fa_enabled']),
      emailVerificationExpiresAt: TypeUtils.toNullableStringSafe(json['email_verification_expires_at']),
      lastVerificationSentAt: TypeUtils.toNullableStringSafe(json['last_verification_sent_at']),
      refreshTokenExpiresAt: TypeUtils.toNullableStringSafe(json['refresh_token_expires_at']),
      passwordResetExpiresAt: TypeUtils.toNullableStringSafe(json['password_reset_expires_at']),
      status: TypeUtils.toStringSafe(json['status']),
      avatar: TypeUtils.toNullableStringSafe(json['avatar']),
      googleId: TypeUtils.toNullableStringSafe(json['google_id']),
      appleId: TypeUtils.toNullableStringSafe(json['apple_id']),
      oauthProvider: TypeUtils.toNullableStringSafe(json['oauth_provider']),
      roleId: TypeUtils.toStringSafe(json['role_id']),
      isActive: TypeUtils.toBoolSafe(json['is_active']),
      lockedUntil: TypeUtils.toNullableStringSafe(json['locked_until']),
      firstLogin: TypeUtils.toNullableStringSafe(json['first_login']),
      lastLogin: TypeUtils.toNullableStringSafe(json['last_login']),
      createdAt: TypeUtils.toStringSafe(json['created_at']),
      updatedAt: TypeUtils.toStringSafe(json['updated_at']),
      deletedAt: TypeUtils.toNullableStringSafe(json['deleted_at']),
      agreedToTerms: TypeUtils.toBoolSafe(json['agreed_to_terms']),
      agreedToTermsAt: TypeUtils.toNullableStringSafe(json['agreed_to_terms_at']),
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

class Specializations {
  final List<String> areas;
  final List<String> certifications;

  Specializations({
    required this.areas,
    required this.certifications,
  });

  factory Specializations.fromJson(Map<String, dynamic> json) {
    final areasList = TypeUtils.toListSafe<dynamic>(json['areas']);
    final certificationsList = TypeUtils.toListSafe<dynamic>(json['certifications']);

    return Specializations(
      areas: areasList.map((e) => TypeUtils.toStringSafe(e)).toList(),
      certifications: certificationsList.map((e) => TypeUtils.toStringSafe(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'areas': areas,
      'certifications': certifications,
    };
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
    final countiesList = TypeUtils.toListSafe<dynamic>(json['counties']);
    final subCountiesList = TypeUtils.toListSafe<dynamic>(json['sub_counties']);

    return CoverageAreas(
      counties: countiesList.map((e) => TypeUtils.toStringSafe(e)).toList(),
      subCounties: subCountiesList.map((e) => TypeUtils.toStringSafe(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'counties': counties,
      'sub_counties': subCounties,
    };
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
      date: TypeUtils.toStringSafe(json['date']),
      vaccine: TypeUtils.toStringSafe(json['vaccine']),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'vaccine': vaccine,
      'birds_count': birdsCount,
    };
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
      whatsapp: TypeUtils.toStringSafe(json['whatsapp']),
      alternativePhone: TypeUtils.toStringSafe(json['alternative_phone']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsapp': whatsapp,
      'alternative_phone': alternativePhone,
    };
  }
}

class Metadata {
  final String organization;

  Metadata({
    required this.organization,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      organization: TypeUtils.toStringSafe(json['organization']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization': organization,
    };
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
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    return VetFarmerListResponse(
      data: dataList
          .map((x) => VetFarmer.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      total: TypeUtils.toIntSafe(json['total']),
      page: TypeUtils.toIntSafe(json['page'], defaultValue: 1),
      limit: TypeUtils.toIntSafe(json['limit'], defaultValue: 10),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
    };
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
    final locationMap = TypeUtils.toMapSafe(json['location']);
    final specializationsMap = TypeUtils.toMapSafe(json['specializations']);
    final coverageAreasMap = TypeUtils.toMapSafe(json['coverage_areas']);
    final contactInfoMap = TypeUtils.toMapSafe(json['contact_info']);
    final metadataMap = TypeUtils.toMapSafe(json['metadata']);

    final certificateUrlsList = TypeUtils.toListSafe<dynamic>(json['certificate_urls']);
    final additionalCertificateUrlsList = TypeUtils.toListSafe<dynamic>(json['additional_certificate_urls']);
    final vaccinationRecordsList = TypeUtils.toListSafe<dynamic>(json['vaccination_records']);

    return VetFarmerRecommendation(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      officerType: TypeUtils.toStringSafe(json['officer_type']),
      educationLevel: TypeUtils.toStringSafe(json['education_level']),
      region: TypeUtils.toNullableStringSafe(json['region']),
      dateOfBirth: TypeUtils.toStringSafe(json['date_of_birth']),
      location: Location.fromJson(locationMap ?? {}),
      age: TypeUtils.toIntSafe(json['age']),
      gender: TypeUtils.toStringSafe(json['gender']),
      yearsOfExperience: TypeUtils.toIntSafe(json['years_of_experience']),
      profileBio: TypeUtils.toStringSafe(json['profile_bio']),
      idPhotoUrl: TypeUtils.toNullableStringSafe(json['id_photo_url']),
      faceSelfieUrl: TypeUtils.toNullableStringSafe(json['face_selfie_url']),
      certificateUrls: certificateUrlsList
          .map((e) => TypeUtils.toStringSafe(e))
          .toList(),
      additionalCertificateUrls: additionalCertificateUrlsList
          .map((e) => TypeUtils.toStringSafe(e))
          .toList(),
      licenseNumber: TypeUtils.toNullableStringSafe(json['license_number']),
      licenseExpiryDate: TypeUtils.toNullableStringSafe(json['license_expiry_date']),
      status: TypeUtils.toStringSafe(json['status']),
      isVerified: TypeUtils.toBoolSafe(json['is_verified']),
      verifiedAt: TypeUtils.toNullableStringSafe(json['verified_at']),
      verifiedBy: TypeUtils.toNullableStringSafe(json['verified_by']),
      rejectionReason: TypeUtils.toNullableStringSafe(json['rejection_reason']),
      suspensionReason: TypeUtils.toNullableStringSafe(json['suspension_reason']),
      specializations: specializationsMap != null
          ? Specializations.fromJson(specializationsMap)
          : null,
      coverageAreas: coverageAreasMap != null
          ? CoverageAreas.fromJson(coverageAreasMap)
          : null,
      isAvailable: TypeUtils.toBoolSafe(json['is_available']),
      averageRating: TypeUtils.toStringSafe(json['average_rating'], defaultValue: '0.0'),
      tier: TypeUtils.toStringSafe(json['tier']),
      totalJobsCompleted: TypeUtils.toIntSafe(json['total_jobs_completed']),
      totalRatingsCount: TypeUtils.toIntSafe(json['total_ratings_count']),
      totalEarnings: TypeUtils.toStringSafe(json['total_earnings'], defaultValue: '0.00'),
      currentMonthEarnings: TypeUtils.toStringSafe(json['current_month_earnings'], defaultValue: '0.00'),
      vaccinationRecords: vaccinationRecordsList
          .map((e) => VaccinationRecord.fromJson(
          e is Map<String, dynamic> ? e : {}))
          .toList(),
      totalAppraisals: TypeUtils.toIntSafe(json['total_appraisals']),
      contactInfo: contactInfoMap != null
          ? ContactInfo.fromJson(contactInfoMap)
          : null,
      metadata: metadataMap != null
          ? Metadata.fromJson(metadataMap)
          : null,
      createdAt: TypeUtils.toStringSafe(json['created_at']),
      updatedAt: TypeUtils.toStringSafe(json['updated_at']),
      matchType: TypeUtils.toStringSafe(json['match_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'officer_type': officerType,
      'education_level': educationLevel,
      'region': region,
      'date_of_birth': dateOfBirth,
      'location': location.toJson(),
      'age': age,
      'gender': gender,
      'years_of_experience': yearsOfExperience,
      'profile_bio': profileBio,
      'id_photo_url': idPhotoUrl,
      'face_selfie_url': faceSelfieUrl,
      'certificate_urls': certificateUrls,
      'additional_certificate_urls': additionalCertificateUrls,
      'license_number': licenseNumber,
      'license_expiry_date': licenseExpiryDate,
      'status': status,
      'is_verified': isVerified,
      'verified_at': verifiedAt,
      'verified_by': verifiedBy,
      'rejection_reason': rejectionReason,
      'suspension_reason': suspensionReason,
      'specializations': specializations?.toJson(),
      'coverage_areas': coverageAreas?.toJson(),
      'is_available': isAvailable,
      'average_rating': averageRating,
      'tier': tier,
      'total_jobs_completed': totalJobsCompleted,
      'total_ratings_count': totalRatingsCount,
      'total_earnings': totalEarnings,
      'current_month_earnings': currentMonthEarnings,
      'vaccination_records': vaccinationRecords.map((e) => e.toJson()).toList(),
      'total_appraisals': totalAppraisals,
      'contact_info': contactInfo?.toJson(),
      'metadata': metadata?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'match_type': matchType,
    };
  }

  VetFarmer toVetFarmer() {
    return VetFarmer(
      id: id,
      name: name,
      userId: userId,
      user: null,
      officerType: officerType,
      educationLevel: educationLevel,
      region: region,
      dateOfBirth: dateOfBirth,
      location: location,
      age: age,
      gender: gender,
      yearsOfExperience: yearsOfExperience,
      profileBio: profileBio,
      idPhotoUrl: idPhotoUrl,
      faceSelfieUrl: faceSelfieUrl,
      certificateUrls: certificateUrls,
      additionalCertificateUrls: additionalCertificateUrls,
      licenseNumber: licenseNumber,
      licenseExpiryDate: licenseExpiryDate,
      status: status,
      isVerified: isVerified,
      verifiedAt: verifiedAt,
      verifiedBy: verifiedBy,
      rejectionReason: rejectionReason,
      suspensionReason: suspensionReason,
      specializations: specializations,
      coverageAreas: coverageAreas,
      isAvailable: isAvailable,
      averageRating: averageRating,
      tier: tier,
      totalJobsCompleted: totalJobsCompleted,
      totalRatingsCount: totalRatingsCount,
      totalEarnings: totalEarnings,
      currentMonthEarnings: currentMonthEarnings,
      vaccinationRecords: vaccinationRecords,
      totalAppraisals: totalAppraisals,
      contactInfo: contactInfo,
      metadata: metadata,
      appraisals: null,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}