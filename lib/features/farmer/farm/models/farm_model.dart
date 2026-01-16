// lib/features/farmer/farm/models/farm_model.dart

import 'dart:convert';

class FarmModel {
  final String id;
  final String farmName;
  final String? location;
  final double? totalArea;
  final String? farmType;
  final String? description;
  final GpsCoordinates? gpsCoordinates;
  final int? totalBirds;
  final int? activeBatches;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final num? batchCount;

  const FarmModel({
    required this.id,
    required this.farmName,
    this.location,
    this.totalArea,
    this.farmType,
    this.description,
    this.gpsCoordinates,
    this.totalBirds,
    this.activeBatches,
    this.imageUrl,
    this.createdAt,
    this.updatedAt, this.batchCount,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    // Parse location - handle JSON string or direct object
    String? locationStr;
    GpsCoordinates? gpsCoords;

    if (json['location'] != null) {
      if (json['location'] is String) {
        try {
          // Try to parse as JSON string
          final locationData = jsonDecode(json['location']);

          // Extract formatted address
          if (locationData['address'] != null &&
              locationData['address']['formatted_address'] != null) {
            locationStr = locationData['address']['formatted_address'];
          }

          // Extract GPS coordinates
          if (locationData['latitude'] != null &&
              locationData['longitude'] != null) {
            gpsCoords = GpsCoordinates(
              latitude: _parseDouble(locationData['latitude']),
              longitude: _parseDouble(locationData['longitude']),
              address: locationData['address'] != null
                  ? AddressDetails.fromJson(locationData['address'])
                  : null,
            );
          }
        } catch (e) {
          // If parsing fails, use the string as is
          locationStr = json['location'];
        }
      } else if (json['location'] is Map) {
        // Location is already a Map/object
        final locationData = json['location'] as Map<String, dynamic>;

        // Extract formatted address
        if (locationData['address'] != null &&
            locationData['address']['formatted_address'] != null) {
          locationStr = locationData['address']['formatted_address'];
        }

        // Extract GPS coordinates
        if (locationData['latitude'] != null &&
            locationData['longitude'] != null) {
          gpsCoords = GpsCoordinates(
            latitude: _parseDouble(locationData['latitude']),
            longitude: _parseDouble(locationData['longitude']),
            address: locationData['address'] != null
                ? AddressDetails.fromJson(locationData['address'])
                : null,
          );
        }
      }
    }

    return FarmModel(
      id: json['id']?.toString() ?? '',
      farmName: json['farm_name'] ?? '',
      location: locationStr,
      totalArea: _parseDouble(json['total_area']),
      farmType: json['farm_type'],
      description: json['description'],
      batchCount: json['batch_count'],
      gpsCoordinates: gpsCoords,
      totalBirds: json['total_birds'] is int ? json['total_birds'] : null,
      activeBatches: json['active_batches'] is int ? json['active_batches'] : null,
      imageUrl: json['farm_photo'] ?? json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'farm_name': farmName,
      'location': location,
      'total_area': totalArea,
      'farm_type': farmType,
      'description': description,
      'gps_coordinates': gpsCoordinates?.toJson(),
      'total_birds': totalBirds,
      'active_batches': activeBatches,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }

  FarmModel copyWith({
    String? id,
    String? farmName,
    String? location,
    double? totalArea,
    String? farmType,
    String? description,
    GpsCoordinates? gpsCoordinates,
    int? totalBirds,
    int? activeBatches,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmModel(
      id: id ?? this.id,
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
      totalArea: totalArea ?? this.totalArea,
      farmType: farmType ?? this.farmType,
      description: description ?? this.description,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      totalBirds: totalBirds ?? this.totalBirds,
      activeBatches: activeBatches ?? this.activeBatches,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GpsCoordinates {
  final AddressDetails? address;
  final double latitude;
  final double longitude;

  const GpsCoordinates({
    this.address,
    required this.latitude,
    required this.longitude,
  });

  factory GpsCoordinates.fromJson(Map<String, dynamic> json) {
    return GpsCoordinates(
      address: json['address'] != null
          ? AddressDetails.fromJson(json['address'])
          : null,
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
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

class AddressDetails {
  final String? placeId;
  final String? name;
  final String? formattedAddress;
  final Geometry? geometry;
  final List<AddressComponent>? addressComponents;

  const AddressDetails({
    this.placeId,
    this.name,
    this.formattedAddress,
    this.geometry,
    this.addressComponents,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      placeId: json['place_id'],
      name: json['name'],
      formattedAddress: json['formatted_address'],
      geometry: json['geometry'] != null
          ? Geometry.fromJson(json['geometry'])
          : null,
      addressComponents: json['address_components'] != null
          ? (json['address_components'] as List)
          .map((e) => AddressComponent.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'formatted_address': formattedAddress,
      'geometry': geometry?.toJson(),
      'address_components':
      addressComponents?.map((e) => e.toJson()).toList(),
    };
  }
}

class Geometry {
  final Location location;

  const Geometry({required this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: Location.fromJson(json['location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
    };
  }
}

class Location {
  final double lat;
  final double lng;

  const Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  const AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'] ?? '',
      shortName: json['short_name'] ?? '',
      types: (json['types'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'long_name': longName,
      'short_name': shortName,
      'types': types,
    };
  }
}