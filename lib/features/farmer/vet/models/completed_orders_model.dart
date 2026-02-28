import 'dart:convert';
import 'package:agriflock/core/utils/type_safe_utils.dart';

class CompletedOrder {
  final String id;
  final String orderNumber;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final FarmerLocation farmerLocation;
  final String vetId;
  final String vetName;
  final List<String> vetSpecialization;
  final VetLocation vetLocation;
  final List<House> houses;
  final List<Batch> batches;
  final int birdsCount;
  final String birdTypeId;
  final String birdTypeName;
  final List<Service> services;
  final List<ServiceCost> serviceCosts;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
  final String reasonForVisit;
  final String? additionalNotes;
  final double serviceFee;
  final double mileageFee;
  final double distanceKm;
  final double prioritySurcharge;
  final double totalEstimatedCost;
  final double officerEarnings;
  final double platformCommission;
  final double actualCost;
  final String currency;
  final String status;
  final String submittedAt;
  final String reviewedAt;
  final String scheduledAt;
  final String completedAt;
  final String? cancelledAt;
  final String vetNotes;
  final String? cancellationReason;
  final bool termsAgreed;
  final bool isPaid;

  const CompletedOrder({
    required this.id,
    required this.orderNumber,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerLocation,
    required this.vetId,
    required this.vetName,
    required this.vetSpecialization,
    required this.vetLocation,
    required this.houses,
    required this.batches,
    required this.birdsCount,
    required this.birdTypeId,
    required this.birdTypeName,
    required this.services,
    required this.serviceCosts,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.reasonForVisit,
    this.additionalNotes,
    required this.serviceFee,
    required this.mileageFee,
    required this.distanceKm,
    required this.prioritySurcharge,
    required this.totalEstimatedCost,
    required this.officerEarnings,
    required this.platformCommission,
    required this.actualCost,
    required this.currency,
    required this.status,
    required this.submittedAt,
    required this.reviewedAt,
    required this.scheduledAt,
    required this.completedAt,
    this.cancelledAt,
    required this.vetNotes,
    this.cancellationReason,
    required this.termsAgreed,
    required this.isPaid,
  });

  factory CompletedOrder.fromJson(Map<String, dynamic> json) {
    // Parse farmer_location which could be a string or map
    dynamic farmerLocationJson = json['farmer_location'];
    Map<String, dynamic> farmerLocationMap = {};
    if (farmerLocationJson is String) {
      try {
        final decoded = jsonDecode(farmerLocationJson);
        if (decoded is Map) {
          farmerLocationMap = Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        // Fallback to empty map
      }
    } else if (farmerLocationJson is Map) {
      farmerLocationMap = Map<String, dynamic>.from(farmerLocationJson);
    }

    final vetLocationMap = TypeUtils.toMapSafe(json['vet_location']);
    final housesList = TypeUtils.toListSafe<dynamic>(json['houses']);
    final batchesList = TypeUtils.toListSafe<dynamic>(json['batches']);
    final servicesList = TypeUtils.toListSafe<dynamic>(json['services']);
    final serviceCostsList = TypeUtils.toListSafe<dynamic>(json['service_costs']);
    final vetSpecializationList = TypeUtils.toListSafe<dynamic>(json['vet_specialization']);

    return CompletedOrder(
      id: TypeUtils.toStringSafe(json['id']),
      orderNumber: TypeUtils.toStringSafe(json['order_number']),
      farmerId: TypeUtils.toStringSafe(json['farmer_id']),
      farmerName: TypeUtils.toStringSafe(json['farmer_name']),
      farmerPhone: TypeUtils.toStringSafe(json['farmer_phone']),
      farmerLocation: FarmerLocation.fromJson(farmerLocationMap),
      vetId: TypeUtils.toStringSafe(json['vet_id']),
      vetName: TypeUtils.toStringSafe(json['vet_name']),
      vetSpecialization: vetSpecializationList
          .map((item) => TypeUtils.toStringSafe(item))
          .toList(),
      vetLocation: VetLocation.fromJson(vetLocationMap ?? {}),
      houses: housesList
          .map((x) => House.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      batches: batchesList
          .map((x) => Batch.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
      birdTypeId: TypeUtils.toStringSafe(json['bird_type_id']),
      birdTypeName: TypeUtils.toStringSafe(json['bird_type_name']),
      services: servicesList
          .map((x) => Service.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      serviceCosts: serviceCostsList
          .map((x) => ServiceCost.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      priorityLevel: TypeUtils.toStringSafe(json['priority_level']),
      preferredDate: TypeUtils.toStringSafe(json['preferred_date']),
      preferredTime: TypeUtils.toStringSafe(json['preferred_time']),
      reasonForVisit: TypeUtils.toStringSafe(json['reason_for_visit']),
      additionalNotes: TypeUtils.toNullableStringSafe(json['additional_notes']),
      serviceFee: TypeUtils.toDoubleSafe(json['serviceFee']),
      mileageFee: TypeUtils.toDoubleSafe(json['mileageFee']),
      distanceKm: TypeUtils.toDoubleSafe(json['distanceKm']),
      prioritySurcharge: TypeUtils.toDoubleSafe(json['prioritySurcharge']),
      totalEstimatedCost: TypeUtils.toDoubleSafe(json['totalEstimatedCost']),
      officerEarnings: TypeUtils.toDoubleSafe(json['officerEarnings']),
      platformCommission: TypeUtils.toDoubleSafe(json['platformCommission']),
      actualCost: TypeUtils.toDoubleSafe(json['actualCost']),
      currency: TypeUtils.toStringSafe(json['currency']),
      status: TypeUtils.toStringSafe(json['status']),
      submittedAt: TypeUtils.toStringSafe(json['submitted_at']),
      reviewedAt: TypeUtils.toStringSafe(json['reviewed_at']),
      scheduledAt: TypeUtils.toStringSafe(json['scheduled_at']),
      completedAt: TypeUtils.toStringSafe(json['completed_at']),
      cancelledAt: TypeUtils.toNullableStringSafe(json['cancelled_at']),
      vetNotes: TypeUtils.toStringSafe(json['vet_notes']),
      cancellationReason: TypeUtils.toNullableStringSafe(json['cancellation_reason']),
      termsAgreed: TypeUtils.toBoolSafe(json['terms_agreed']),
      isPaid: TypeUtils.toBoolSafe(json['is_paid']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'farmer_id': farmerId,
    'farmer_name': farmerName,
    'farmer_phone': farmerPhone,
    'farmer_location': farmerLocation.toJson(),
    'vet_id': vetId,
    'vet_name': vetName,
    'vet_specialization': vetSpecialization,
    'vet_location': vetLocation.toJson(),
    'houses': houses.map((x) => x.toJson()).toList(),
    'batches': batches.map((x) => x.toJson()).toList(),
    'birds_count': birdsCount,
    'bird_type_id': birdTypeId,
    'bird_type_name': birdTypeName,
    'services': services.map((x) => x.toJson()).toList(),
    'service_costs': serviceCosts.map((x) => x.toJson()).toList(),
    'priority_level': priorityLevel,
    'preferred_date': preferredDate,
    'preferred_time': preferredTime,
    'reason_for_visit': reasonForVisit,
    'additional_notes': additionalNotes,
    'serviceFee': serviceFee,
    'mileageFee': mileageFee,
    'distanceKm': distanceKm,
    'prioritySurcharge': prioritySurcharge,
    'totalEstimatedCost': totalEstimatedCost,
    'officerEarnings': officerEarnings,
    'platformCommission': platformCommission,
    'actualCost': actualCost,
    'currency': currency,
    'status': status,
    'submitted_at': submittedAt,
    'reviewed_at': reviewedAt,
    'scheduled_at': scheduledAt,
    'completed_at': completedAt,
    'cancelled_at': cancelledAt,
    'vet_notes': vetNotes,
    'cancellation_reason': cancellationReason,
    'terms_agreed': termsAgreed,
    'is_paid': isPaid,
  };
}

class FarmerLocation {
  final String address;
  final double latitude;
  final double longitude;

  const FarmerLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory FarmerLocation.fromJson(Map<String, dynamic> json) {
    return FarmerLocation(
      address: TypeUtils.toStringSafe(json['address']),
      latitude: TypeUtils.toDoubleSafe(json['latitude']),
      longitude: TypeUtils.toDoubleSafe(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class VetLocation {
  final Address address;
  final double latitude;
  final double longitude;

  const VetLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory VetLocation.fromJson(Map<String, dynamic> json) {
    final addressMap = TypeUtils.toMapSafe(json['address']);

    return VetLocation(
      address: Address.fromJson(addressMap ?? {}),
      latitude: TypeUtils.toDoubleSafe(json['latitude']),
      longitude: TypeUtils.toDoubleSafe(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address.toJson(),
    'latitude': latitude,
    'longitude': longitude,
  };
}

class Address {
  final String city;
  final String county;
  final String subCounty;
  final String formattedAddress;

  const Address({
    required this.city,
    required this.county,
    required this.subCounty,
    required this.formattedAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: TypeUtils.toStringSafe(json['city']),
      county: TypeUtils.toStringSafe(json['county']),
      subCounty: TypeUtils.toStringSafe(json['sub_county']),
      formattedAddress: TypeUtils.toStringSafe(json['formatted_address']),
    );
  }

  Map<String, dynamic> toJson() => {
    'city': city,
    'county': county,
    'sub_county': subCounty,
    'formatted_address': formattedAddress,
  };
}

class House {
  final String id;
  final String name;
  final int birdsCount;

  const House({
    required this.id,
    required this.name,
    required this.birdsCount,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birds_count': birdsCount,
  };
}

class Batch {
  final String id;
  final String name;
  final String houseId;
  final String houseName;
  final int birdsCount;
  final String birdTypeId;
  final String birdTypeName;

  const Batch({
    required this.id,
    required this.name,
    required this.houseId,
    required this.houseName,
    required this.birdsCount,
    required this.birdTypeId,
    required this.birdTypeName,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      houseId: TypeUtils.toStringSafe(json['house_id']),
      houseName: TypeUtils.toStringSafe(json['house_name']),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
      birdTypeId: TypeUtils.toStringSafe(json['bird_type_id']),
      birdTypeName: TypeUtils.toStringSafe(json['bird_type_name']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'house_id': houseId,
    'house_name': houseName,
    'birds_count': birdsCount,
    'bird_type_id': birdTypeId,
    'bird_type_name': birdTypeName,
  };
}

class Service {
  final String id;
  final String name;
  final String code;
  final double cost;

  const Service({
    required this.id,
    required this.name,
    required this.code,
    required this.cost,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      code: TypeUtils.toStringSafe(json['code']),
      cost: TypeUtils.toDoubleSafe(json['cost']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'cost': cost,
  };
}

class ServiceCost {
  final double cost;
  final String serviceId;
  final String serviceCode;
  final String serviceName;

  const ServiceCost({
    required this.cost,
    required this.serviceId,
    required this.serviceCode,
    required this.serviceName,
  });

  factory ServiceCost.fromJson(Map<String, dynamic> json) {
    return ServiceCost(
      cost: TypeUtils.toDoubleSafe(json['cost']),
      serviceId: TypeUtils.toStringSafe(json['service_id']),
      serviceCode: TypeUtils.toStringSafe(json['service_code']),
      serviceName: TypeUtils.toStringSafe(json['service_name']),
    );
  }

  Map<String, dynamic> toJson() => {
    'cost': cost,
    'service_id': serviceId,
    'service_code': serviceCode,
    'service_name': serviceName,
  };
}