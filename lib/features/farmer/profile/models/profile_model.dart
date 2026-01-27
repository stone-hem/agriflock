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
    return Location(
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
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
  final String message;
  final ProfileData data;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ProfileData.fromJson(json['data']),
    );
  }
}

class ProfileData {
  final String id;
  final String userId;
  final String fullName;
  final String? nationalId;
  final String phoneNumber;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final Location location;
  final String? avatar;
  final String? farmId;
  final int yearsOfExperience;
  final String poultryTypeId;
  final String poultryType;
  final int chickenHouseCapacity;
  final int currentNumberOfChickens;
  final String preferredAgrovetName;
  final String preferredFeedCompany;
  final String? preferredChicksCompany;
  final String? preferredOfftakerAgent;
  final String region;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileData({
    required this.id,
    required this.userId,
    required this.fullName,
    this.nationalId,
    required this.phoneNumber,
    this.dateOfBirth,
    this.age,
    this.gender,
    required this.location,
    this.avatar,
    this.farmId,
    required this.yearsOfExperience,
    required this.poultryTypeId,
    required this.poultryType,
    required this.chickenHouseCapacity,
    required this.currentNumberOfChickens,
    required this.preferredAgrovetName,
    required this.preferredFeedCompany,
    this.preferredChicksCompany,
    this.preferredOfftakerAgent,
    required this.region,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    // Parse location string if it's a String, otherwise use the Map directly
    Map<String, dynamic> locationJson;
    if (json['location'] is String) {
      locationJson = jsonDecode(json['location']) ?? {};
    } else {
      locationJson = json['location'] ?? {};
    }

    return ProfileData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      nationalId: json['national_id'],
      phoneNumber: json['phone_number'] ?? '',
      dateOfBirth: json['date_of_birth'],
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      gender: json['gender'],
      location: Location.fromJson(locationJson),
      avatar: json['avatar'],
      farmId: json['farm_id'],
      yearsOfExperience: json['years_of_experience']?.toInt() ?? 0,
      poultryTypeId: json['poultry_type_id'] ?? '',
      poultryType: json['poultry_type'] ?? '',
      chickenHouseCapacity: json['chicken_house_capacity']?.toInt() ?? 0,
      currentNumberOfChickens: json['current_number_of_chickens']?.toInt() ?? 0,
      preferredAgrovetName: json['preferred_agrovet_name'] ?? '',
      preferredFeedCompany: json['preferred_feed_company'] ?? '',
      preferredChicksCompany: json['preferred_chicks_company'],
      preferredOfftakerAgent: json['preferred_offtaker_agent'],
      region: json['region'] ?? 'GLOBAL',
      createdAt: DateTime.parse(json['created_at'] ?? '2025-12-26T08:33:24.207Z'),
      updatedAt: DateTime.parse(json['updated_at'] ?? '2025-12-26T08:33:24.207Z'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'national_id': nationalId,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth,
      'age': age,
      'gender': gender,
      'location': location.toJson(),
      'avatar': avatar,
      'farm_id': farmId,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}