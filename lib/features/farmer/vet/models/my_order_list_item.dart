import 'dart:convert';
import 'package:agriflock360/core/utils/type_safe_utils.dart';

class MyOrderListItem {
  final String id;
  final String orderNumber;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final dynamic farmerLocation;
  final String vetId;
  final String vetName;
  final List<String> vetSpecialization;
  final dynamic vetLocation;
  final List<House> houses;
  final List<Batch> batches;
  final int birdsCount;
  final String? birdTypeId;
  final String? birdTypeName;
  final List<Service> services;
  final List<ServiceCost> serviceCosts;
  final String priorityLevel;
  final DateTime preferredDate;
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
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool termsAgreed;
  final bool isPaid;

  MyOrderListItem({
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
    this.birdTypeId,
    this.birdTypeName,
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
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.scheduledAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.termsAgreed,
    required this.isPaid,
  });

  factory MyOrderListItem.fromJson(Map<String, dynamic> json) {
    final housesList = TypeUtils.toListSafe<dynamic>(json['houses']);
    final batchesList = TypeUtils.toListSafe<dynamic>(json['batches']);
    final servicesList = TypeUtils.toListSafe<dynamic>(json['services']);
    final serviceCostsList = TypeUtils.toListSafe<dynamic>(json['service_costs']);
    final vetSpecializationList = TypeUtils.toListSafe<dynamic>(json['vet_specialization']);

    return MyOrderListItem(
      id: TypeUtils.toStringSafe(json['id']),
      orderNumber: TypeUtils.toStringSafe(json['order_number']),
      farmerId: TypeUtils.toStringSafe(json['farmer_id']),
      farmerName: TypeUtils.toStringSafe(json['farmer_name']),
      farmerPhone: TypeUtils.toStringSafe(json['farmer_phone']),
      farmerLocation: json['farmer_location'], // Keep as dynamic
      vetId: TypeUtils.toStringSafe(json['vet_id']),
      vetName: TypeUtils.toStringSafe(json['vet_name']),
      vetSpecialization: vetSpecializationList
          .map((item) => TypeUtils.toStringSafe(item))
          .toList(),
      vetLocation: json['vet_location'], // Keep as dynamic
      houses: housesList
          .map((house) => House.fromJson(house is Map<String, dynamic> ? house : {}))
          .toList(),
      batches: batchesList
          .map((batch) => Batch.fromJson(batch is Map<String, dynamic> ? batch : {}))
          .toList(),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
      birdTypeId: TypeUtils.toNullableStringSafe(json['bird_type_id']),
      birdTypeName: TypeUtils.toNullableStringSafe(json['bird_type_name']),
      services: servicesList
          .map((service) => Service.fromJson(service is Map<String, dynamic> ? service : {}))
          .toList(),
      serviceCosts: serviceCostsList
          .map((cost) => ServiceCost.fromJson(cost is Map<String, dynamic> ? cost : {}))
          .toList(),
      priorityLevel: TypeUtils.toStringSafe(json['priority_level']),
      preferredDate: TypeUtils.toDateTimeSafe(json['preferred_date']) ?? DateTime.now(),
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
      status: TypeUtils.toStringSafe(json['status']),
      submittedAt: TypeUtils.toDateTimeSafe(json['submitted_at']) ?? DateTime.now(),
      reviewedAt: TypeUtils.toDateTimeSafe(json['reviewed_at']),
      scheduledAt: TypeUtils.toDateTimeSafe(json['scheduled_at']),
      completedAt: TypeUtils.toDateTimeSafe(json['completed_at']),
      cancelledAt: TypeUtils.toDateTimeSafe(json['cancelled_at']),
      cancellationReason: TypeUtils.toNullableStringSafe(json['cancellation_reason']),
      termsAgreed: TypeUtils.toBoolSafe(json['terms_agreed']),
      isPaid: TypeUtils.toBoolSafe(json['is_paid']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'farmer_phone': farmerPhone,
      'farmer_location': farmerLocation,
      'vet_id': vetId,
      'vet_name': vetName,
      'vet_specialization': vetSpecialization,
      'vet_location': vetLocation,
      'houses': houses.map((house) => house.toJson()).toList(),
      'batches': batches.map((batch) => batch.toJson()).toList(),
      'birds_count': birdsCount,
      'bird_type_id': birdTypeId,
      'bird_type_name': birdTypeName,
      'services': services.map((service) => service.toJson()).toList(),
      'service_costs': serviceCosts.map((cost) => cost.toJson()).toList(),
      'priority_level': priorityLevel,
      'preferred_date': preferredDate.toIso8601String().split('T')[0],
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
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'terms_agreed': termsAgreed,
      'is_paid': isPaid,
    };
  }

  // Helper methods
  Map<String, dynamic>? get parsedFarmerLocation {
    if (farmerLocation is String) {
      try {
        final decoded = jsonDecode(farmerLocation as String);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        return null;
      }
    } else if (farmerLocation is Map) {
      return Map<String, dynamic>.from(farmerLocation as Map);
    }
    return null;
  }

  String? get farmerAddress {
    final location = parsedFarmerLocation;
    if (location != null && location.containsKey('address')) {
      return TypeUtils.toStringSafe(location['address']);
    }
    return null;
  }

  Map<String, dynamic>? get parsedVetLocation {
    if (vetLocation is Map) {
      return Map<String, dynamic>.from(vetLocation as Map);
    }
    return null;
  }

  String? get vetAddress {
    final location = parsedVetLocation;
    if (location != null && location.containsKey('address')) {
      final address = location['address'];
      if (address is Map) {
        final addressMap = Map<String, dynamic>.from(address);
        return TypeUtils.toStringSafe(addressMap['formatted_address']);
      } else if (address is String) {
        return TypeUtils.toStringSafe(address);
      }
    }
    return null;
  }

  // Get first house and batch for backward compatibility
  House? get firstHouse => houses.isNotEmpty ? houses.first : null;
  Batch? get firstBatch => batches.isNotEmpty ? batches.first : null;

  // Get total service cost
  double get totalServiceCost {
    return serviceCosts.fold(0.0, (sum, cost) => sum + cost.cost);
  }
}

class House {
  final String id;
  final String name;
  final int birdsCount;

  House({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birds_count': birdsCount,
    };
  }
}

class Batch {
  final String id;
  final String name;
  final String houseId;
  final String houseName;
  final int birdsCount;
  final String birdTypeId;
  final String birdTypeName;

  Batch({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'house_id': houseId,
      'house_name': houseName,
      'birds_count': birdsCount,
      'bird_type_id': birdTypeId,
      'bird_type_name': birdTypeName,
    };
  }
}

class Service {
  final String id;
  final String name;
  final String code;
  final double cost;

  Service({
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'cost': cost,
    };
  }
}

class ServiceCost {
  final double cost;
  final String serviceId;
  final String serviceCode;
  final String serviceName;

  ServiceCost({
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

  Map<String, dynamic> toJson() {
    return {
      'cost': cost,
      'service_id': serviceId,
      'service_code': serviceCode,
      'service_name': serviceName,
    };
  }
}