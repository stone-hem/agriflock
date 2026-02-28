// vet_service_type.dart
import 'package:agriflock/core/utils/type_safe_utils.dart';

class VetServiceType {
  final String id;
  final String serviceCode;
  final String serviceName;
  final String description;
  final double? basePrice;
  final String region;
  final String currency;
  final String category;
  final bool active;
  final String pricingType;
  final double? perBirdRate;
  final double? perPersonRate;
  final bool requiresTransport;
  final bool requiresUpfrontPayment;
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
      id: TypeUtils.toStringSafe(json['id']),
      serviceCode: TypeUtils.toStringSafe(json['service_code']),
      serviceName: TypeUtils.toStringSafe(json['service_name']),
      description: TypeUtils.toStringSafe(json['description']),
      basePrice: TypeUtils.toNullableDoubleSafe(json['base_price']),
      region: TypeUtils.toStringSafe(json['region']),
      currency: TypeUtils.toStringSafe(json['currency']),
      category: TypeUtils.toStringSafe(json['category']),
      active: TypeUtils.toBoolSafe(json['active']),
      pricingType: TypeUtils.toStringSafe(json['pricing_type']),
      perBirdRate: TypeUtils.toNullableDoubleSafe(json['per_bird_rate']),
      perPersonRate: TypeUtils.toNullableDoubleSafe(json['per_person_rate']),
      requiresTransport: TypeUtils.toBoolSafe(json['requires_transport']),
      requiresUpfrontPayment: TypeUtils.toBoolSafe(json['requires_upfront_payment']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
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
    final safeList = TypeUtils.toListSafe<dynamic>(jsonList);

    return VetServiceTypesResponse(
      serviceTypes: safeList
          .map((item) => VetServiceType.fromJson(
          item is Map<String, dynamic> ? item : {}))
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