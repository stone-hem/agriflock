import 'dart:convert';

class UpdateProfileRequest {
  final String fullName;
  final String phoneNumber;
  final Location location;
  final int yearsOfExperience;
  final String poultryType;
  final int chickenHouseCapacity;
  final int currentNumberOfChickens;
  final String preferredAgrovetName;
  final String preferredFeedCompany;

  UpdateProfileRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.location,
    required this.yearsOfExperience,
    required this.poultryType,
    required this.chickenHouseCapacity,
    required this.currentNumberOfChickens,
    required this.preferredAgrovetName,
    required this.preferredFeedCompany,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'location': location.toJson(),
      'years_of_experience': yearsOfExperience,
      'poultry_type': poultryType,
      'chicken_house_capacity': chickenHouseCapacity,
      'current_number_of_chickens': currentNumberOfChickens,
      'preferred_agrovet_name': preferredAgrovetName,
      'preferred_feed_company': preferredFeedCompany,
    };
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

  factory Location.fromJson(Map<String, dynamic> json) {
    // Handle nested address structure from the API
    String address = '';
    double latitude = 0.0;
    double longitude = 0.0;

    if (json.containsKey('address')) {
      // If address is a Map (nested structure)
      if (json['address'] is Map) {
        final addressMap = json['address'] as Map<String, dynamic>;
        address = addressMap['formatted_address'] ?? addressMap['name'] ?? '';

        // Extract lat/lng from geometry
        if (addressMap.containsKey('geometry') && addressMap['geometry'] is Map) {
          final geometry = addressMap['geometry'] as Map<String, dynamic>;
          if (geometry.containsKey('location') && geometry['location'] is Map) {
            final location = geometry['location'] as Map<String, dynamic>;
            latitude = (location['lat'] ?? 0.0).toDouble();
            longitude = (location['lng'] ?? 0.0).toDouble();
          }
        }
      } else {
        // If address is a String
        address = json['address'].toString();
      }
    }

    // Override with direct lat/lng if present
    if (json.containsKey('latitude')) {
      latitude = (json['latitude'] ?? 0.0).toDouble();
    }
    if (json.containsKey('longitude')) {
      longitude = (json['longitude'] ?? 0.0).toDouble();
    }

    return Location(
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ProfileResponse {
  final bool success;
  final String? message;
  final ProfileData data;

  ProfileResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] as String?,
      data: ProfileData.fromJson(json['data']),
    );
  }
}

class ProfileData {
  final String id;
  final String? userId;
  final String fullName;
  final String? email;  // ⚠️ ADD THIS
  final String? name;   // ⚠️ ADD THIS
  final String? nationalId;
  final String phoneNumber;
  final String? callingCode;  // ⚠️ ADD THIS
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final Location location;
  final String? avatar;
  final String? farmId;
  final Map<String, dynamic>? farm;  // ⚠️ ADD THIS
  final int? yearsOfExperience;
  final String? poultryTypeId;
  final String? poultryType;
  final int? chickenHouseCapacity;
  final int? currentNumberOfChickens;
  final String? preferredAgrovetName;
  final String? preferredFeedCompany;
  final String? preferredChicksCompany;
  final String? preferredOfftakerAgent;
  final String region;
  final String? currency;  // ⚠️ ADD THIS
  final Map<String, dynamic>? currencyInfo;  // ⚠️ ADD THIS
  final Map<String, dynamic>? preferences;  // ⚠️ ADD THIS
  final UserRole? role;  // ⚠️ ADD THIS
  final String? status;  // ⚠️ ADD THIS
  final bool? is2faEnabled;  // ⚠️ ADD THIS
  final String? oauthProvider;  // ⚠️ ADD THIS
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileData({
    required this.id,
    this.userId,
    required this.fullName,
    this.email,
    this.name,
    this.nationalId,
    required this.phoneNumber,
    this.callingCode,
    this.dateOfBirth,
    this.age,
    this.gender,
    required this.location,
    this.avatar,
    this.farmId,
    this.farm,
    this.yearsOfExperience,
    this.poultryTypeId,
    this.poultryType,
    this.chickenHouseCapacity,
    this.currentNumberOfChickens,
    this.preferredAgrovetName,
    this.preferredFeedCompany,
    this.preferredChicksCompany,
    this.preferredOfftakerAgent,
    required this.region,
    this.currency,
    this.currencyInfo,
    this.preferences,
    this.role,
    this.status,
    this.is2faEnabled,
    this.oauthProvider,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    // ⚠️ CRITICAL FIX: Parse location properly
    Map<String, dynamic> locationJson = {};

    if (json['location'] != null) {
      if (json['location'] is String) {
        // Parse the JSON string
        try {
          locationJson = jsonDecode(json['location']) as Map<String, dynamic>;
        } catch (e) {
          print('Error parsing location string: $e');
          locationJson = {};
        }
      } else if (json['location'] is Map) {
        locationJson = json['location'] as Map<String, dynamic>;
      }
    }

    return ProfileData(
      id: json['id'] ?? '',
      userId: json['user_id'] as String?,
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] as String?,
      name: json['name'] as String?,
      nationalId: json['national_id'] as String?,
      phoneNumber: json['phone_number'] ?? '',
      callingCode: json['calling_code'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender'] as String?,
      location: Location.fromJson(locationJson),
      avatar: json['avatar'] as String?,
      farmId: json['farm_id'] as String?,
      farm: json['farm'] as Map<String, dynamic>?,
      yearsOfExperience: json['years_of_experience'] != null
          ? int.tryParse(json['years_of_experience'].toString())
          : null,
      poultryTypeId: json['poultry_type_id'] as String?,
      poultryType: json['poultry_type'] as String?,
      chickenHouseCapacity: json['chicken_house_capacity'] != null
          ? int.tryParse(json['chicken_house_capacity'].toString())
          : null,
      currentNumberOfChickens: json['current_number_of_chickens'] != null
          ? int.tryParse(json['current_number_of_chickens'].toString())
          : null,
      preferredAgrovetName: json['preferred_agrovet_name'] as String?,
      preferredFeedCompany: json['preferred_feed_company'] as String?,
      preferredChicksCompany: json['preferred_chicks_company'] as String?,
      preferredOfftakerAgent: json['preferred_offtaker_agent'] as String?,
      region: json['region'] ?? 'GLOBAL',
      currency: json['currency'] as String?,
      currencyInfo: json['currency_info'] as Map<String, dynamic>?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      role: json['role'] != null ? UserRole.fromJson(json['role']) : null,
      status: json['status'] as String?,
      is2faEnabled: json['is_2fa_enabled'] as bool?,
      oauthProvider: json['oauth_provider'] as String?,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'name': name,
      'national_id': nationalId,
      'phone_number': phoneNumber,
      'calling_code': callingCode,
      'date_of_birth': dateOfBirth,
      'age': age,
      'gender': gender,
      'location': location.toJson(),
      'avatar': avatar,
      'farm_id': farmId,
      'farm': farm,
      'years_of_experience': yearsOfExperience,
      'poultry_type_id': poultryTypeId,
      'poultry_type': poultryType,
      'chicken_house_capacity': chickenHouseCapacity,
      'current_number_of_chickens': currentNumberOfChickens,
      'preferred_agrovet_name': preferredAgrovetName,
      'preferred_feed_company': preferredFeedCompany,
      'preferred_chicks_company': preferredChicksCompany,
      'preferred_offtaker_agent': preferredOfftakerAgent,
      'region': region,
      'currency': currency,
      'currency_info': currencyInfo,
      'preferences': preferences,
      'role': role?.toJson(),
      'status': status,
      'is_2fa_enabled': is2faEnabled,
      'oauth_provider': oauthProvider,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// ⚠️ ADD UserRole model
class UserRole {
  final String id;
  final String name;
  final String description;
  final bool isSystemRole;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserRole({
    required this.id,
    required this.name,
    required this.description,
    required this.isSystemRole,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isSystemRole: json['is_system_role'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_system_role': isSystemRole,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}