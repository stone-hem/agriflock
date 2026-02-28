import 'package:agriflock/core/utils/type_safe_utils.dart';

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
  final List<dynamic> services;
  final List<ServiceCost> serviceCosts;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
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
    final vetLocationMap = TypeUtils.toMapSafe(json['vet_location']);
    final housesList = TypeUtils.toListSafe<dynamic>(json['houses']);
    final batchesList = TypeUtils.toListSafe<dynamic>(json['batches']);
    final servicesList = TypeUtils.toListSafe<dynamic>(json['services']);
    final serviceCostsList = TypeUtils.toListSafe<dynamic>(json['service_costs']);
    final vetSpecializationList = TypeUtils.toListSafe<dynamic>(json['vet_specialization']);

    return Visit(
      id: TypeUtils.toStringSafe(json['id']),
      orderNumber: TypeUtils.toStringSafe(json['order_number']),
      farmerId: TypeUtils.toStringSafe(json['farmer_id']),
      farmerName: TypeUtils.toStringSafe(json['farmer_name']),
      farmerPhone: TypeUtils.toStringSafe(json['farmer_phone']),
      farmerLocation: TypeUtils.toStringSafe(json['farmer_location']),
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
      services: servicesList,
      serviceCosts: serviceCostsList
          .map((x) => ServiceCost.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      priorityLevel: TypeUtils.toStringSafe(json['priority_level']),
      preferredDate: TypeUtils.toStringSafe(json['preferred_date']),
      preferredTime: TypeUtils.toStringSafe(json['preferred_time']),
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
    final addressMap = TypeUtils.toMapSafe(json['address']);

    return VetLocation(
      address: Address.fromJson(addressMap ?? {}),
      latitude: TypeUtils.toDoubleSafe(json['latitude']),
      longitude: TypeUtils.toDoubleSafe(json['longitude']),
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
      city: TypeUtils.toStringSafe(json['city']),
      county: TypeUtils.toStringSafe(json['county']),
      subCounty: TypeUtils.toStringSafe(json['sub_county']),
      formattedAddress: TypeUtils.toStringSafe(json['formatted_address']),
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
      batchId: TypeUtils.toStringSafe(json['batch_id']),
      houseId: TypeUtils.toStringSafe(json['house_id']),
      batchName: TypeUtils.toStringSafe(json['batch_name']),
      houseName: TypeUtils.toStringSafe(json['house_name']),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
      birdTypeId: TypeUtils.toStringSafe(json['bird_type_id']),
      birdTypeName: TypeUtils.toStringSafe(json['bird_type_name']),
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
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    return VisitListResponse(
      visits: dataList
          .map((x) => Visit.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      total: TypeUtils.toIntSafe(json['total']),
      page: TypeUtils.toIntSafe(json['page'], defaultValue: 1),
      limit: TypeUtils.toIntSafe(json['limit'], defaultValue: 10),
      totalPages: TypeUtils.toIntSafe(json['total_pages'], defaultValue: 1),
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
  pendingPayments('pending_payments'),
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
        case VisitStatus.pendingPayments:
        return 'Pending Payments';
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
        case VisitStatus.pendingPayments:
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