
class Visit {
  final String id;
  final String orderNumber;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String farmerLocation;
  final String vetId;
  final String vetName;
  final List<String> vetSpecialization;
  final VetLocation vetLocation;
  final List<House> houses;
  final List<Batch> batches;
  final int birdsCount;
  final String birdTypeId;
  final List<dynamic> services; // Based on your data, this appears to be empty array
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
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool termsAgreed;
  final bool isPaid;

  Visit({
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
    required this.services,
    required this.serviceCosts,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.reasonForVisit,
    required this.additionalNotes,
    required this.serviceFee,
    required this.mileageFee,
    required this.distanceKm,
    required this.prioritySurcharge,
    required this.totalEstimatedCost,
    required this.officerEarnings,
    required this.platformCommission,
    required this.status,
    required this.submittedAt,
    required this.reviewedAt,
    required this.scheduledAt,
    required this.completedAt,
    required this.cancelledAt,
    required this.cancellationReason,
    required this.termsAgreed,
    required this.isPaid,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      farmerId: json['farmer_id'] as String,
      farmerName: json['farmer_name'] as String,
      farmerPhone: json['farmer_phone'] as String,
      farmerLocation: json['farmer_location'] as String,
      vetId: json['vet_id'] as String,
      vetName: json['vet_name'] as String,
      vetSpecialization: List<String>.from(json['vet_specialization'] ?? []),
      vetLocation: VetLocation.fromJson(json['vet_location'] ?? {}),
      houses: List<House>.from((json['houses'] ?? []).map((x) => House.fromJson(x))),
      batches: List<Batch>.from((json['batches'] ?? []).map((x) => Batch.fromJson(x))),
      birdsCount: (json['birds_count'] as num).toInt(),
      birdTypeId: json['bird_type_id'] as String,
      services: json['services'] ?? [],
      serviceCosts: List<ServiceCost>.from((json['service_costs'] ?? []).map((x) => ServiceCost.fromJson(x))),
      priorityLevel: json['priority_level'] as String,
      preferredDate: json['preferred_date'] as String,
      preferredTime: json['preferred_time'] as String,
      reasonForVisit: json['reason_for_visit'] as String,
      additionalNotes: json['additional_notes'],
      serviceFee: (json['serviceFee'] as num).toDouble(),
      mileageFee: (json['mileageFee'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      prioritySurcharge: (json['prioritySurcharge'] as num).toDouble(),
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      officerEarnings: (json['officerEarnings'] as num).toDouble(),
      platformCommission: (json['platformCommission'] as num).toDouble(),
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at']),
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      cancellationReason: json['cancellation_reason'],
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
      'vet_location': vetLocation.toJson(),
      'houses': houses.map((x) => x.toJson()).toList(),
      'batches': batches.map((x) => x.toJson()).toList(),
      'birds_count': birdsCount,
      'bird_type_id': birdTypeId,
      'services': services,
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
}

class VetLocation {
  final Address address;
  final double latitude;
  final double longitude;

  VetLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory VetLocation.fromJson(Map<String, dynamic> json) {
    return VetLocation(
      address: Address.fromJson(json['address'] ?? {}),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address.toJson(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Address {
  final String city;
  final String county;
  final String subCounty;
  final String formattedAddress;

  Address({
    required this.city,
    required this.county,
    required this.subCounty,
    required this.formattedAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'] ?? '',
      county: json['county'] ?? '',
      subCounty: json['sub_county'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'county': county,
      'sub_county': subCounty,
      'formatted_address': formattedAddress,
    };
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
      birdsCount: (json['birds_count'] as num).toInt(),
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
  final String batchId;
  final String houseId;
  final String batchName;
  final String houseName;
  final int birdsCount;
  final String birdTypeId;
  final String birdTypeName;

  Batch({
    required this.batchId,
    required this.houseId,
    required this.batchName,
    required this.houseName,
    required this.birdsCount,
    required this.birdTypeId,
    required this.birdTypeName,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      batchId: json['batch_id'] as String,
      houseId: json['house_id'] as String,
      batchName: json['batch_name'] as String,
      houseName: json['house_name'] as String,
      birdsCount: (json['birds_count'] as num).toInt(),
      birdTypeId: json['bird_type_id'] as String,
      birdTypeName: json['bird_type_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'house_id': houseId,
      'batch_name': batchName,
      'house_name': houseName,
      'birds_count': birdsCount,
      'bird_type_id': birdTypeId,
      'bird_type_name': birdTypeName,
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

class VisitListResponse {
  final List<Visit> visits;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  VisitListResponse({
    required this.visits,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory VisitListResponse.fromJson(Map<String, dynamic> json) {
    return VisitListResponse(
      visits: List<Visit>.from((json['data'] ?? []).map((x) => Visit.fromJson(x))),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': visits.map((x) => x.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'total_pages': totalPages,
    };
  }
}

// Enum for visit status
enum VisitStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  accepted('accepted'),
  declined('declined'),
  cancelled('cancelled');

  final String value;
  const VisitStatus(this.value);

  static VisitStatus fromString(String value) {
    return VisitStatus.values.firstWhere(
          (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => VisitStatus.pending,
    );
  }

  // Helper method to get display label
  String get displayLabel {
    switch (this) {
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.inProgress:
        return 'In Progress';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.accepted:
        return 'Accepted';
      case VisitStatus.declined:
        return 'Declined';
      case VisitStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Check if status is an active status (can perform actions)
  bool get isActive {
    return this == VisitStatus.pending ||
        this == VisitStatus.accepted ||
        this == VisitStatus.inProgress;
  }

  // Check if status is a final status (read-only)
  bool get isFinal {
    return this == VisitStatus.completed ||
        this == VisitStatus.declined ||
        this == VisitStatus.cancelled;
  }

  // Get next possible status transitions
  List<VisitStatus> get possibleTransitions {
    switch (this) {
      case VisitStatus.pending:
        return [VisitStatus.accepted, VisitStatus.declined];
      case VisitStatus.accepted:
        return [VisitStatus.inProgress, VisitStatus.cancelled];
      case VisitStatus.inProgress:
        return [VisitStatus.completed, VisitStatus.cancelled];
      case VisitStatus.completed:
      case VisitStatus.declined:
      case VisitStatus.cancelled:
        return []; // No transitions from final states
    }
  }
}

// Enum for priority level
enum PriorityLevel {
  normal('NORMAL'),
  urgent('URGENT'),
  emergency('EMERGENCY');

  final String value;
  const PriorityLevel(this.value);

  static PriorityLevel fromString(String value) {
    return PriorityLevel.values.firstWhere(
          (priority) => priority.value == value,
      orElse: () => PriorityLevel.normal,
    );
  }
}