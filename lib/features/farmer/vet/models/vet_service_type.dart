// vet_service_type.dart
class VetServiceType {
  final String id;
  final String serviceCode;
  final String serviceName;
  final String description;
  final double? basePrice; // Changed to nullable
  final String region;
  final String currency;
  final String category;
  final bool active;
  final String pricingType; // Added field
  final double? perBirdRate; // Added field, nullable
  final double? perPersonRate; // Added field, nullable
  final bool requiresTransport; // Added field
  final bool requiresUpfrontPayment; // Added field
  final DateTime createdAt;
  final DateTime updatedAt;

  VetServiceType({
    required this.id,
    required this.serviceCode,
    required this.serviceName,
    required this.description,
    required this.basePrice,
    required this.region,
    required this.currency,
    required this.category,
    required this.active,
    required this.pricingType,
    required this.perBirdRate,
    required this.perPersonRate,
    required this.requiresTransport,
    required this.requiresUpfrontPayment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VetServiceType.fromJson(Map<String, dynamic> json) {
    return VetServiceType(
      id: json['id'] as String,
      serviceCode: json['service_code'] as String,
      serviceName: json['service_name'] as String,
      description: json['description'] as String,
      basePrice: json['base_price'] != null
          ? double.tryParse(json['base_price'].toString())
          : null,
      region: json['region'] as String,
      currency: json['currency'] as String,
      category: json['category'] as String,
      active: json['active'] as bool,
      pricingType: json['pricing_type'] as String,
      perBirdRate: json['per_bird_rate'] != null
          ? double.tryParse(json['per_bird_rate'].toString())
          : null,
      perPersonRate: json['per_person_rate'] != null
          ? double.tryParse(json['per_person_rate'].toString())
          : null,
      requiresTransport: json['requires_transport'] as bool,
      requiresUpfrontPayment: json['requires_upfront_payment'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_code': serviceCode,
      'service_name': serviceName,
      'description': description,
      'base_price': basePrice?.toStringAsFixed(2),
      'region': region,
      'currency': currency,
      'category': category,
      'active': active,
      'pricing_type': pricingType,
      'per_bird_rate': perBirdRate?.toStringAsFixed(2),
      'per_person_rate': perPersonRate?.toStringAsFixed(2),
      'requires_transport': requiresTransport,
      'requires_upfront_payment': requiresUpfrontPayment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get the effective price based on pricing type
  double? getEffectivePrice({int? numberOfBirds, int? numberOfPeople}) {
    switch (pricingType) {
      case 'FIXED':
        return basePrice;
      case 'PER_BIRD':
        return perBirdRate != null && numberOfBirds != null
            ? perBirdRate! * numberOfBirds
            : null;
      case 'PER_PERSON':
        return perPersonRate != null && numberOfPeople != null
            ? perPersonRate! * numberOfPeople
            : null;
      default:
        return null;
    }
  }
}

// vet_service_types_response.dart
class VetServiceTypesResponse {
  final List<VetServiceType> serviceTypes;

  VetServiceTypesResponse({
    required this.serviceTypes,
  });

  factory VetServiceTypesResponse.fromJson(List<dynamic> jsonList) {
    return VetServiceTypesResponse(
      serviceTypes: jsonList
          .map((item) => VetServiceType.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return serviceTypes.map((service) => service.toJson()).toList();
  }

  // Helper method to filter services by region
  List<VetServiceType> getServicesByRegion(String region) {
    return serviceTypes.where((service) => service.region == region).toList();
  }

  // Helper method to filter services by category
  List<VetServiceType> getServicesByCategory(String category) {
    return serviceTypes.where((service) => service.category == category).toList();
  }
}