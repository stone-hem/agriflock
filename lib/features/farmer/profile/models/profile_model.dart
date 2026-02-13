import 'dart:convert';
import 'package:agriflock360/core/utils/type_safe_utils.dart';

// Request class - NOT using TypeUtils as per rules
class UpdateProfileRequest {
  final String fullName;
  final String phoneNumber;
  final Location location;
  final int yearsOfExperience;
  final String poultryTypeId;
  final int chickenHouseCapacity;
  final int currentNumberOfChickens;
  final String preferredAgrovetName;
  final String preferredFeedCompany;

  UpdateProfileRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.location,
    required this.yearsOfExperience,
    required this.poultryTypeId,
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
      'poultry_type_id': poultryTypeId,
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
        final addressMap = TypeUtils.toMapSafe(json['address']) ?? {};
        address = TypeUtils.toStringSafe(addressMap['formatted_address']) ??
            TypeUtils.toStringSafe(addressMap['name']) ?? '';

        // Extract lat/lng from geometry
        if (addressMap.containsKey('geometry') && addressMap['geometry'] is Map) {
          final geometry = TypeUtils.toMapSafe(addressMap['geometry']) ?? {};
          if (geometry.containsKey('location') && geometry['location'] is Map) {
            final location = TypeUtils.toMapSafe(geometry['location']) ?? {};
            latitude = TypeUtils.toDoubleSafe(location['lat']);
            longitude = TypeUtils.toDoubleSafe(location['lng']);
          }
        }
      } else {
        // If address is a String
        address = TypeUtils.toStringSafe(json['address']);
      }
    }

    // Override with direct lat/lng if present
    latitude = TypeUtils.toDoubleSafe(json['latitude'], defaultValue: latitude);
    longitude = TypeUtils.toDoubleSafe(json['longitude'], defaultValue: longitude);

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
    final dataMap = TypeUtils.toMapSafe(json['data']);

    return ProfileResponse(
      success: TypeUtils.toBoolSafe(json['success']),
      message: TypeUtils.toNullableStringSafe(json['message']),
      data: ProfileData.fromJson(dataMap ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ProfileData {
  final String id;
  final String? userId;
  final String fullName;
  final String? email;
  final String? name;
  final String? nationalId;
  final String phoneNumber;
  final String? callingCode;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final Location location;
  final String? avatar;
  final String? farmId;
  final Map<String, dynamic>? farm;
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
  final String? currency;
  final Map<String, dynamic>? currencyInfo;
  final Map<String, dynamic>? preferences;
  final UserRole? role;
  final String? status;
  final bool? is2faEnabled;
  final String? oauthProvider;
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
    // Parse location properly - handle both String and Map
    Map<String, dynamic> locationJson = {};
    final locationValue = json['location'];

    if (locationValue != null) {
      if (locationValue is String) {
        // Parse the JSON string
        try {
          final decoded = jsonDecode(locationValue);
          if (decoded is Map) {
            locationJson = Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          print('Error parsing location string: $e');
        }
      } else if (locationValue is Map) {
        locationJson = Map<String, dynamic>.from(locationValue);
      }
    }

    final roleMap = TypeUtils.toMapSafe(json['role']);
    final farmMap = TypeUtils.toMapSafe(json['farm']);
    final currencyInfoMap = TypeUtils.toMapSafe(json['currency_info']);
    final preferencesMap = TypeUtils.toMapSafe(json['preferences']);

    return ProfileData(
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toNullableStringSafe(json['user_id']),
      fullName: TypeUtils.toStringSafe(json['full_name']) ??
          TypeUtils.toStringSafe(json['name']) ?? '',
      email: TypeUtils.toNullableStringSafe(json['email']),
      name: TypeUtils.toNullableStringSafe(json['name']),
      nationalId: TypeUtils.toNullableStringSafe(json['national_id']),
      phoneNumber: TypeUtils.toStringSafe(json['phone_number']),
      callingCode: TypeUtils.toNullableStringSafe(json['calling_code']),
      dateOfBirth: TypeUtils.toNullableStringSafe(json['date_of_birth']),
      age: TypeUtils.toNullableIntSafe(json['age']),
      gender: TypeUtils.toNullableStringSafe(json['gender']),
      location: Location.fromJson(locationJson),
      avatar: TypeUtils.toNullableStringSafe(json['avatar']),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      farm: farmMap,
      yearsOfExperience: TypeUtils.toNullableIntSafe(json['years_of_experience']),
      poultryTypeId: TypeUtils.toNullableStringSafe(json['poultry_type_id']),
      poultryType: TypeUtils.toNullableStringSafe(json['poultry_type']),
      chickenHouseCapacity: TypeUtils.toNullableIntSafe(json['chicken_house_capacity']),
      currentNumberOfChickens: TypeUtils.toNullableIntSafe(json['current_number_of_chickens']),
      preferredAgrovetName: TypeUtils.toNullableStringSafe(json['preferred_agrovet_name']),
      preferredFeedCompany: TypeUtils.toNullableStringSafe(json['preferred_feed_company']),
      preferredChicksCompany: TypeUtils.toNullableStringSafe(json['preferred_chicks_company']),
      preferredOfftakerAgent: TypeUtils.toNullableStringSafe(json['preferred_offtaker_agent']),
      region: TypeUtils.toStringSafe(json['region'], defaultValue: 'GLOBAL'),
      currency: TypeUtils.toNullableStringSafe(json['currency']),
      currencyInfo: currencyInfoMap,
      preferences: preferencesMap,
      role: roleMap != null ? UserRole.fromJson(roleMap) : null,
      status: TypeUtils.toNullableStringSafe(json['status']),
      is2faEnabled: TypeUtils.toNullableBoolSafe(json['is_2fa_enabled']),
      oauthProvider: TypeUtils.toNullableStringSafe(json['oauth_provider']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
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
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      description: TypeUtils.toStringSafe(json['description']),
      isSystemRole: TypeUtils.toBoolSafe(json['is_system_role']),
      isActive: TypeUtils.toBoolSafe(json['is_active'], defaultValue: true),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
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