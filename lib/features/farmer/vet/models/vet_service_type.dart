// vet_service_type.dart
class VetServiceType {
  final String id;
  final String serviceCode;
  final String serviceName;
  final String description;
  final double basePrice;
  final String region;
  final String currency;
  final String category;
  final bool active;
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory VetServiceType.fromJson(Map<String, dynamic> json) {
    return VetServiceType(
      id: json['id'] as String,
      serviceCode: json['service_code'] as String,
      serviceName: json['service_name'] as String,
      description: json['description'] as String,
      basePrice: double.tryParse(json['base_price'] as String) ?? 0.0,
      region: json['region'] as String,
      currency: json['currency'] as String,
      category: json['category'] as String,
      active: json['active'] as bool,
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
      'base_price': basePrice.toStringAsFixed(2),
      'region': region,
      'currency': currency,
      'category': category,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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
}