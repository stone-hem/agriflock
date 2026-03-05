import 'dart:convert';
import 'package:agriflock/core/utils/type_safe_utils.dart';

class Visit {
  final String id;
  final String orderNumber;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final FarmerLocation farmerLocation;
  final String farmerCategory;
  final String vetId;
  final String vetName;
  final List<String> vetSpecialization;
  final VetLocation vetLocation;
  final List<House> houses;
  final List<Batch> batches;
  final int birdsCount;
  final String? birdTypeId;
  final String? birdTypeName;
  final List<BirdType> birdTypes;
  final int? mortality;
  final int? ageInDays;
  final String paymentMode;
  final List<Service> services;
  final List<ServiceCost> serviceCosts;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
  final String? reasonForVisit;
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
  final String? vetNotes;
  final double? actualCost;
  final bool termsAgreed;
  final bool isPaid;
  final String currency;
  final String dateRequested;
  final String timeRequested;

  Visit({
    required this.id,
    required this.orderNumber,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerLocation,
    required this.farmerCategory,
    required this.vetId,
    required this.vetName,
    required this.vetSpecialization,
    required this.vetLocation,
    required this.houses,
    required this.batches,
    required this.birdsCount,
    this.birdTypeId,
    this.birdTypeName,
    required this.birdTypes,
    this.mortality,
    this.ageInDays,
    required this.paymentMode,
    required this.services,
    required this.serviceCosts,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    this.reasonForVisit,
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
    this.vetNotes,
    this.actualCost,
    required this.termsAgreed,
    required this.isPaid,
    required this.currency,
    required this.dateRequested,
    required this.timeRequested,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    final vetLocationMap = TypeUtils.toMapSafe(json['vet_location']);
    final housesList = TypeUtils.toListSafe<dynamic>(json['houses']);
    final batchesList = TypeUtils.toListSafe<dynamic>(json['batches']);
    final servicesList = TypeUtils.toListSafe<dynamic>(json['services']);
    final serviceCostsList = TypeUtils.toListSafe<dynamic>(json['service_costs']);
    final vetSpecializationList = TypeUtils.toListSafe<dynamic>(json['vet_specialization']);
    final birdTypesList = TypeUtils.toListSafe<dynamic>(json['bird_types']);

    return Visit(
      id: TypeUtils.toStringSafe(json['id']),
      orderNumber: TypeUtils.toStringSafe(json['order_number']),
      farmerId: TypeUtils.toStringSafe(json['farmer_id']),
      farmerName: TypeUtils.toStringSafe(json['farmer_name']),
      farmerPhone: TypeUtils.toStringSafe(json['farmer_phone']),
      farmerLocation: FarmerLocation.fromJson(json['farmer_location']),
      farmerCategory: TypeUtils.toStringSafe(json['farmer_category']),
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
      birdTypeId: TypeUtils.toNullableStringSafe(json['bird_type_id']),
      birdTypeName: TypeUtils.toNullableStringSafe(json['bird_type_name']),
      birdTypes: birdTypesList
          .map((x) => BirdType.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      mortality: TypeUtils.toNullableIntSafe(json['mortality']),
      ageInDays: TypeUtils.toNullableIntSafe(json['age_in_days']),
      paymentMode: TypeUtils.toStringSafe(json['payment_mode']),
      services: servicesList
          .map((x) => Service.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      serviceCosts: serviceCostsList
          .map((x) => ServiceCost.fromJson(x is Map<String, dynamic> ? x : {}))
          .toList(),
      priorityLevel: TypeUtils.toStringSafe(json['priority_level']),
      preferredDate: TypeUtils.toStringSafe(json['preferred_date']),
      preferredTime: TypeUtils.toStringSafe(json['preferred_time']),
      reasonForVisit: TypeUtils.toNullableStringSafe(json['reason_for_visit']),
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
      vetNotes: TypeUtils.toNullableStringSafe(json['vet_notes']),
      actualCost: TypeUtils.toNullableDoubleSafe(json['actualCost']),
      termsAgreed: TypeUtils.toBoolSafe(json['terms_agreed']),
      isPaid: TypeUtils.toBoolSafe(json['is_paid']),
      currency: TypeUtils.toStringSafe(json['currency']),
      dateRequested: TypeUtils.toStringSafe(json['date_requested']),
      timeRequested: TypeUtils.toStringSafe(json['time_requested']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'farmer_phone': farmerPhone,
      'farmer_location': farmerLocation.toJson(),
      'farmer_category': farmerCategory,
      'vet_id': vetId,
      'vet_name': vetName,
      'vet_specialization': vetSpecialization,
      'vet_location': vetLocation.toJson(),
      'houses': houses.map((x) => x.toJson()).toList(),
      'batches': batches.map((x) => x.toJson()).toList(),
      'birds_count': birdsCount,
      'bird_type_id': birdTypeId,
      'bird_type_name': birdTypeName,
      'bird_types': birdTypes.map((x) => x.toJson()).toList(),
      'mortality': mortality,
      'age_in_days': ageInDays,
      'payment_mode': paymentMode,
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
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'vet_notes': vetNotes,
      'actualCost': actualCost,
      'terms_agreed': termsAgreed,
      'is_paid': isPaid,
      'currency': currency,
      'date_requested': dateRequested,
      'time_requested': timeRequested,
    };
  }
}

class BirdType {
  final String id;
  final String name;

  BirdType({
    required this.id,
    required this.name,
  });

  factory BirdType.fromJson(Map<String, dynamic> json) {
    return BirdType(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
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

class FarmerLocation {
  final String address;
  final double latitude;
  final double longitude;

  FarmerLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory FarmerLocation.fromJson(dynamic json) {
    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        return FarmerLocation(
          address: TypeUtils.toStringSafe(decoded['address']),
          latitude: TypeUtils.toDoubleSafe(decoded['latitude']),
          longitude: TypeUtils.toDoubleSafe(decoded['longitude']),
        );
      } catch (e) {
        return FarmerLocation(address: json, latitude: 0, longitude: 0);
      }
    } else if (json is Map) {
      // Handle the case where address might be a complex object
      String address = '';
      if (json['address'] is Map) {
        // If address is a complex object, we might want to extract formatted_address
        final addressMap = json['address'] as Map;
        address = TypeUtils.toStringSafe(addressMap['formatted_address']);
      } else {
        address = TypeUtils.toStringSafe(json['address']);
      }

      return FarmerLocation(
        address: address,
        latitude: TypeUtils.toDoubleSafe(json['latitude']),
        longitude: TypeUtils.toDoubleSafe(json['longitude']),
      );
    }
    return FarmerLocation(address: '', latitude: 0, longitude: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
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
  final String? city;
  final String? county;
  final String? subCounty;
  final String formattedAddress;

  Address({
    this.city,
    this.county,
    this.subCounty,
    required this.formattedAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: TypeUtils.toNullableStringSafe(json['city']),
      county: TypeUtils.toNullableStringSafe(json['county']),
      subCounty: TypeUtils.toNullableStringSafe(json['sub_county']),
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

class ServiceCost {
  final double cost;
  final String serviceId;
  final String serviceCode;
  final String serviceName;
  final int? birdsCount;
  final int? participantsCount;

  ServiceCost({
    required this.cost,
    required this.serviceId,
    required this.serviceCode,
    required this.serviceName,
    this.birdsCount,
    this.participantsCount,
  });

  factory ServiceCost.fromJson(Map<String, dynamic> json) {
    return ServiceCost(
      cost: TypeUtils.toDoubleSafe(json['cost']),
      serviceId: TypeUtils.toStringSafe(json['service_id']),
      serviceCode: TypeUtils.toStringSafe(json['service_code']),
      serviceName: TypeUtils.toStringSafe(json['service_name']),
      birdsCount: TypeUtils.toNullableIntSafe(json['birds_count']),
      participantsCount: TypeUtils.toNullableIntSafe(json['participants_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cost': cost,
      'service_id': serviceId,
      'service_code': serviceCode,
      'service_name': serviceName,
      'birds_count': birdsCount,
      'participants_count': participantsCount,
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
  accepted('accepted'),
  declined('declined'),
  paid('paid'),
  paymentPending('pending_payments'), // Note: different from enum name
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const VisitStatus(this.value);

  static VisitStatus fromString(String value) {
    return VisitStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => VisitStatus.pending,
    );
  }

  // Helper method to get display label
  String get displayLabel {
    switch (this) {
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.accepted:
        return 'Accepted';
      case VisitStatus.declined:
        return 'Declined';
      case VisitStatus.paid:
        return 'Paid';
      case VisitStatus.paymentPending:
        return 'Pending Payments';
      case VisitStatus.inProgress:
        return 'In Progress';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Add a method to get the enum from display label if needed
  static VisitStatus fromDisplayLabel(String label) {
    switch (label) {
      case 'Pending':
        return VisitStatus.pending;
      case 'Accepted':
        return VisitStatus.accepted;
      case 'Declined':
        return VisitStatus.declined;
      case 'Paid':
        return VisitStatus.paid;
      case 'Pending Payments':
        return VisitStatus.paymentPending;
      case 'In Progress':
        return VisitStatus.inProgress;
      case 'Completed':
        return VisitStatus.completed;
      case 'Cancelled':
        return VisitStatus.cancelled;
      default:
        return VisitStatus.pending;
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

// Enum for payment mode
enum PaymentMode {
  mobileMoney('MOBILE_MONEY'),
  cash('CASH');

  final String value;
  const PaymentMode(this.value);

  static PaymentMode fromString(String value) {
    return PaymentMode.values.firstWhere(
          (mode) => mode.value == value,
      orElse: () => PaymentMode.cash,
    );
  }
}

// Enum for farmer category
enum FarmerCategory {
  starter('STARTER'),
  premium('PREMIUM');

  final String value;
  const FarmerCategory(this.value);

  static FarmerCategory fromString(String value) {
    return FarmerCategory.values.firstWhere(
          (category) => category.value == value,
      orElse: () => FarmerCategory.starter,
    );
  }
}