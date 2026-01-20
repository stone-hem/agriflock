import 'dart:convert';

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
    return MyOrderListItem(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      farmerId: json['farmer_id'] as String,
      farmerName: json['farmer_name'] as String,
      farmerPhone: json['farmer_phone'] as String,
      farmerLocation: json['farmer_location'],
      vetId: json['vet_id'] as String,
      vetName: json['vet_name'] as String,
      vetSpecialization: List<String>.from(json['vet_specialization'] ?? []),
      vetLocation: json['vet_location'],
      houses: (json['houses'] as List<dynamic>?)
          ?.map((house) => House.fromJson(house as Map<String, dynamic>))
          .toList() ??
          [],
      batches: (json['batches'] as List<dynamic>?)
          ?.map((batch) => Batch.fromJson(batch as Map<String, dynamic>))
          .toList() ??
          [],
      birdsCount: json['birds_count'] as int? ?? 0,
      birdTypeId: json['bird_type_id'] as String?,
      birdTypeName: json['bird_type_name'] as String?,
      services: (json['services'] as List<dynamic>?)
          ?.map((service) => Service.fromJson(service as Map<String, dynamic>))
          .toList() ??
          [],
      serviceCosts: (json['service_costs'] as List<dynamic>?)
          ?.map((cost) => ServiceCost.fromJson(cost as Map<String, dynamic>))
          .toList() ??
          [],
      priorityLevel: json['priority_level'] as String,
      preferredDate: DateTime.parse(json['preferred_date'] as String),
      preferredTime: json['preferred_time'] as String,
      reasonForVisit: json['reason_for_visit'] as String,
      additionalNotes: json['additional_notes'] as String?,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0.0,
      mileageFee: (json['mileageFee'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      prioritySurcharge: (json['prioritySurcharge'] as num?)?.toDouble() ?? 0.0,
      totalEstimatedCost: (json['totalEstimatedCost'] as num?)?.toDouble() ?? 0.0,
      officerEarnings: (json['officerEarnings'] as num?)?.toDouble() ?? 0.0,
      platformCommission: (json['platformCommission'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      termsAgreed: json['terms_agreed'] as bool,
      isPaid: json['is_paid'] as bool,
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
        return jsonDecode(farmerLocation as String) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    } else if (farmerLocation is Map) {
      return farmerLocation as Map<String, dynamic>;
    }
    return null;
  }

  String? get farmerAddress {
    final location = parsedFarmerLocation;
    if (location != null && location.containsKey('address')) {
      return location['address'] as String;
    }
    return null;
  }

  Map<String, dynamic>? get parsedVetLocation {
    if (vetLocation is Map) {
      return vetLocation as Map<String, dynamic>;
    }
    return null;
  }

  String? get vetAddress {
    final location = parsedVetLocation;
    if (location != null && location.containsKey('address')) {
      if (location['address'] is Map) {
        final addressMap = location['address'] as Map<String, dynamic>;
        return addressMap['formatted_address'] as String?;
      } else if (location['address'] is String) {
        return location['address'] as String;
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
      id: json['id'] as String,
      name: json['name'] as String,
      birdsCount: json['birds_count'] as int,
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
      id: json['id'] as String,
      name: json['name'] as String,
      houseId: json['house_id'] as String,
      houseName: json['house_name'] as String,
      birdsCount: json['birds_count'] as int,
      birdTypeId: json['bird_type_id'] as String,
      birdTypeName: json['bird_type_name'] as String,
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
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      cost: (json['cost'] as num).toDouble(),
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
      cost: (json['cost'] as num).toDouble(),
      serviceId: json['service_id'] as String,
      serviceCode: json['service_code'] as String,
      serviceName: json['service_name'] as String,
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