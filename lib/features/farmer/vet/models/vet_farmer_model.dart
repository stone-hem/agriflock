
class VetFarmer {
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
  final String idPhotoUrl;
  final String faceSelfieUrl;
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
  final dynamic specializations;
  final dynamic coverageAreas;
  final String averageRating;
  final int totalAppraisals;
  final dynamic contactInfo;
  final dynamic metadata;
  final String createdAt;
  final String updatedAt;
  final User? user;
  final List<dynamic>? appraisals;

  VetFarmer({
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
    required this.idPhotoUrl,
    required this.faceSelfieUrl,
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
    required this.averageRating,
    required this.totalAppraisals,
    this.contactInfo,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.appraisals,
  });

  factory VetFarmer.fromJson(Map<String, dynamic> json) {
    return VetFarmer(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      officerType: json['officer_type'] as String,
      educationLevel: json['education_level'] as String,
      region: json['region'] as String?,
      dateOfBirth: json['date_of_birth'] as String,
      location: Location.fromJson(json['location']),
      age: json['age'] as int,
      gender: json['gender'] as String,
      yearsOfExperience: json['years_of_experience'] as int,
      profileBio: json['profile_bio'] as String,
      idPhotoUrl: json['id_photo_url'] as String,
      faceSelfieUrl: json['face_selfie_url'] as String,
      certificateUrls: List<String>.from(json['certificate_urls'] ?? []),
      additionalCertificateUrls:
      List<String>.from(json['additional_certificate_urls'] ?? []),
      licenseNumber: json['license_number'] as String?,
      licenseExpiryDate: json['license_expiry_date'] as String?,
      status: json['status'] as String,
      isVerified: json['is_verified'] as bool,
      verifiedAt: json['verified_at'] as String?,
      verifiedBy: json['verified_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      suspensionReason: json['suspension_reason'] as String?,
      specializations: json['specializations'],
      coverageAreas: json['coverage_areas'],
      averageRating: json['average_rating'] as String,
      totalAppraisals: json['total_appraisals'] as int,
      contactInfo: json['contact_info'],
      metadata: json['metadata'],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      appraisals: json['appraisals'] as List<dynamic>?,
    );
  }

}

class Location {
  final String address;
  final double latitude;
  final double longitude;

  Location({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(dynamic json) {
    // Handle different location formats from API
    if (json is Map<String, dynamic>) {
      // Format 1: Direct location object with address, latitude, longitude
      if (json.containsKey('address') &&
          json.containsKey('latitude') &&
          json.containsKey('longitude')) {
        return Location(
          address: _extractAddress(json['address']),
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
        );
      }
      // Format 2: Nested location object
      else if (json.containsKey('location')) {
        final locationData = json['location'] as Map<String, dynamic>;
        if (locationData.containsKey('address')) {
          final addressData = locationData['address'];
          return Location(
            address: _extractAddress(addressData),
            latitude: (locationData['latitude'] as num).toDouble(),
            longitude: (locationData['longitude'] as num).toDouble(),
          );
        }
      }
    }

    // Default fallback
    return Location(
      address: 'Unknown Location',
      latitude: 0.0,
      longitude: 0.0,
    );
  }

  static String _extractAddress(dynamic addressData) {
    if (addressData is String) {
      return addressData;
    } else if (addressData is Map<String, dynamic>) {
      if (addressData.containsKey('formatted_address')) {
        return addressData['formatted_address'] as String;
      } else if (addressData.containsKey('name')) {
        return addressData['name'] as String;
      }
    }
    return 'Unknown Location';
  }

}

class User {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String status;
  final String? avatar;
  final String roleId;
  final bool isActive;
  final String? firstLogin;
  final String? lastLogin;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.status,
    this.avatar,
    required this.roleId,
    required this.isActive,
    this.firstLogin,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      status: json['status'] as String,
      avatar: json['avatar'] as String?,
      roleId: json['role_id'] as String,
      isActive: json['is_active'] as bool,
      firstLogin: json['first_login'] as String?,
      lastLogin: json['last_login'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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
      data: List<VetFarmer>.from(
        (json['data'] as List).map((x) => VetFarmer.fromJson(x)),
      ),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
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
  final String idPhotoUrl;
  final String faceSelfieUrl;
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
  final dynamic specializations;
  final dynamic coverageAreas;
  final String averageRating;
  final int totalAppraisals;
  final dynamic contactInfo;
  final dynamic metadata;
  final String createdAt;
  final String updatedAt;

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
    required this.idPhotoUrl,
    required this.faceSelfieUrl,
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
    required this.averageRating,
    required this.totalAppraisals,
    this.contactInfo,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VetFarmerRecommendation.fromJson(Map<String, dynamic> json) {
    return VetFarmerRecommendation(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      officerType: json['officer_type'] as String,
      educationLevel: json['education_level'] as String,
      region: json['region'] as String?,
      dateOfBirth: json['date_of_birth'] as String,
      location: Location.fromJson(json['location']),
      age: json['age'] as int,
      gender: json['gender'] as String,
      yearsOfExperience: json['years_of_experience'] as int,
      profileBio: json['profile_bio'] as String,
      idPhotoUrl: json['id_photo_url'] as String,
      faceSelfieUrl: json['face_selfie_url'] as String,
      certificateUrls: List<String>.from(json['certificate_urls'] ?? []),
      additionalCertificateUrls:
      List<String>.from(json['additional_certificate_urls'] ?? []),
      licenseNumber: json['license_number'] as String?,
      licenseExpiryDate: json['license_expiry_date'] as String?,
      status: json['status'] as String,
      isVerified: json['is_verified'] as bool,
      verifiedAt: json['verified_at'] as String?,
      verifiedBy: json['verified_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      suspensionReason: json['suspension_reason'] as String?,
      specializations: json['specializations'],
      coverageAreas: json['coverage_areas'],
      averageRating: json['average_rating'] as String,
      totalAppraisals: json['total_appraisals'] as int,
      contactInfo: json['contact_info'],
      metadata: json['metadata'],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

}