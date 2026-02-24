import 'package:agriflock360/core/utils/type_safe_utils.dart';


class VetOrderRequest {
  final String vetId;
  final List<String>? houseIds;
  final List<String>? batchIds;
  final List<String> serviceIds;
  final int birdsCount;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
  final bool termsAgreed;
  final int? participantsCount;


  VetOrderRequest({
    required this.vetId,
    this.houseIds,
    this.batchIds,
    required this.serviceIds,
    required this.birdsCount,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.termsAgreed, this.participantsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'vet_id': vetId,
      'house_ids': houseIds,
      'batch_ids': batchIds,
      'service_ids': serviceIds,
      'birds_count': birdsCount,
      'priority_level': priorityLevel,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'terms_agreed': termsAgreed,
      'participants_count': participantsCount,
    };
  }
}

class VetEstimateRequest {
  final String vetId;
  final List<String>? houseIds;
  final List<String>? batchIds;
  final List<String> serviceIds;
  final int? participantsCount;
  final int birdsCount;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
  final bool termsAgreed;

  VetEstimateRequest({
    required this.vetId,
    this.houseIds,
    this.batchIds,
    required this.serviceIds,
    required this.birdsCount,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.termsAgreed, this.participantsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'vet_id': vetId,
      'house_ids': houseIds,
      'batch_ids': batchIds,
      'service_ids': serviceIds,
      'birds_count': birdsCount,
      'priority_level': priorityLevel,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'terms_agreed': termsAgreed,
      'participants_count': participantsCount,
    };
  }
}


class VetEstimateResponse {
  final double totalEstimatedCost;
  final double serviceFee;
  final double mileageFee;
  final double distanceKm;
  final double prioritySurcharge;
  final double officerEarnings;
  final double platformCommission;
  final String currency;
  final String? breakdown;
  final String? notes;
  final String? serviceCode;
  final String? mileageDetails;
  final String? birdType;
  final int birdsCount;
  final int housesCount;
  final int batchesCount;
  final Pricing pricing;
  final List<ServiceCost> serviceCosts;
  final List<HouseDetail> houseDetails;
  final List<BatchDetail> batchDetails;

  VetEstimateResponse({
    required this.totalEstimatedCost,
    required this.serviceFee,
    required this.mileageFee,
    required this.distanceKm,
    required this.prioritySurcharge,
    required this.officerEarnings,
    required this.platformCommission,
    required this.birdsCount,
    required this.housesCount,
    required this.batchesCount,
    this.currency = 'KES',
    this.breakdown,
    this.notes,
    this.serviceCode,
    this.mileageDetails,
    this.birdType,
    required this.pricing,
    required this.serviceCosts,
    required this.houseDetails,
    required this.batchDetails,
  });

  factory VetEstimateResponse.fromJson(Map<String, dynamic> json) {
    final pricingMap = TypeUtils.toMapSafe(json['pricing']);
    final serviceCostsList = TypeUtils.toListSafe<dynamic>(json['serviceCosts']);
    final houseDetailsList = TypeUtils.toListSafe<dynamic>(json['houseDetails']);
    final batchDetailsList = TypeUtils.toListSafe<dynamic>(json['batchDetails']);

    return VetEstimateResponse(
      totalEstimatedCost: TypeUtils.toDoubleSafe(json['totalEstimatedCost']),
      serviceFee: TypeUtils.toDoubleSafe(json['serviceFee']),
      mileageFee: TypeUtils.toDoubleSafe(json['mileageFee']),
      distanceKm: TypeUtils.toDoubleSafe(json['distanceKm']),
      prioritySurcharge: TypeUtils.toDoubleSafe(json['prioritySurcharge']),
      officerEarnings: TypeUtils.toDoubleSafe(json['officerEarnings']),
      platformCommission: TypeUtils.toDoubleSafe(json['platformCommission']),
      birdsCount: TypeUtils.toIntSafe(json['birdsCount']),
      housesCount: TypeUtils.toIntSafe(json['housesCount']),
      batchesCount: TypeUtils.toIntSafe(json['batchesCount']),
      currency: TypeUtils.toStringSafe(json['currency'], defaultValue: 'KES'),
      breakdown: TypeUtils.toNullableStringSafe(json['breakdown']),
      notes: TypeUtils.toNullableStringSafe(json['notes']),
      serviceCode: TypeUtils.toNullableStringSafe(json['serviceCode']),
      mileageDetails: TypeUtils.toNullableStringSafe(json['mileageDetails']),
      birdType: TypeUtils.toNullableStringSafe(json['birdType']),
      pricing: Pricing.fromJson(pricingMap ?? {}),
      serviceCosts: serviceCostsList
          .map((e) => ServiceCost.fromJson(e is Map<String, dynamic> ? e : {}))
          .toList(),
      houseDetails: houseDetailsList
          .map((e) => HouseDetail.fromJson(e is Map<String, dynamic> ? e : {}))
          .toList(),
      batchDetails: batchDetailsList
          .map((e) => BatchDetail.fromJson(e is Map<String, dynamic> ? e : {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEstimatedCost': totalEstimatedCost,
      'serviceFee': serviceFee,
      'mileageFee': mileageFee,
      'distanceKm': distanceKm,
      'prioritySurcharge': prioritySurcharge,
      'officerEarnings': officerEarnings,
      'platformCommission': platformCommission,
      'birdsCount': birdsCount,
      'housesCount': housesCount,
      'batchesCount': batchesCount,
      'currency': currency,
      'breakdown': breakdown,
      'notes': notes,
      'serviceCode': serviceCode,
      'mileageDetails': mileageDetails,
      'birdType': birdType,
      'pricing': pricing.toJson(),
      'serviceCosts': serviceCosts.map((e) => e.toJson()).toList(),
      'houseDetails': houseDetails.map((e) => e.toJson()).toList(),
      'batchDetails': batchDetails.map((e) => e.toJson()).toList(),
    };
  }
}

class Pricing {
  final double serviceFee;
  final double mileageFee;
  final double prioritySurcharge;
  final double totalEstimatedCost;
  final double officerEarnings;
  final double platformCommission;
  final String defaultTransportRatePerKm;

  Pricing({
    required this.serviceFee,
    required this.mileageFee,
    required this.prioritySurcharge,
    required this.totalEstimatedCost,
    required this.officerEarnings,
    required this.platformCommission,
    required this.defaultTransportRatePerKm,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      serviceFee: TypeUtils.toDoubleSafe(json['service_fee']),
      mileageFee: TypeUtils.toDoubleSafe(json['mileage_fee']),
      prioritySurcharge: TypeUtils.toDoubleSafe(json['priority_surcharge']),
      totalEstimatedCost: TypeUtils.toDoubleSafe(json['total_estimated_cost']),
      officerEarnings: TypeUtils.toDoubleSafe(json['officer_earnings']),
      platformCommission: TypeUtils.toDoubleSafe(json['platform_commission']),
      defaultTransportRatePerKm: TypeUtils.toStringSafe(json['default_transport_rate_per_km']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_fee': serviceFee,
      'mileage_fee': mileageFee,
      'priority_surcharge': prioritySurcharge,
      'total_estimated_cost': totalEstimatedCost,
      'officer_earnings': officerEarnings,
      'platform_commission': platformCommission,
      'default_transport_rate_per_km': defaultTransportRatePerKm,
    };
  }
}

class ServiceCost {
  final String serviceId;
  final String serviceName;
  final String serviceCode;
  final double cost;

  ServiceCost({
    required this.serviceId,
    required this.serviceName,
    required this.serviceCode,
    required this.cost,
  });

  factory ServiceCost.fromJson(Map<String, dynamic> json) {
    return ServiceCost(
      serviceId: TypeUtils.toStringSafe(json['service_id']),
      serviceName: TypeUtils.toStringSafe(json['service_name']),
      serviceCode: TypeUtils.toStringSafe(json['service_code']),
      cost: TypeUtils.toDoubleSafe(json['cost']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'service_code': serviceCode,
      'cost': cost,
    };
  }
}

class HouseDetail {
  final String houseId;
  final String houseName;
  final int birdsCount;

  HouseDetail({
    required this.houseId,
    required this.houseName,
    required this.birdsCount,
  });

  factory HouseDetail.fromJson(Map<String, dynamic> json) {
    return HouseDetail(
      houseId: TypeUtils.toStringSafe(json['house_id']),
      houseName: TypeUtils.toStringSafe(json['house_name']),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'house_id': houseId,
      'house_name': houseName,
      'birds_count': birdsCount,
    };
  }
}

class BatchDetail {
  final String batchId;
  final String batchName;
  final String houseId;
  final String houseName;
  final int birdsCount;
  final String birdTypeId;
  final String birdTypeName;

  BatchDetail({
    required this.batchId,
    required this.batchName,
    required this.houseId,
    required this.houseName,
    required this.birdsCount,
    required this.birdTypeId,
    required this.birdTypeName,
  });

  factory BatchDetail.fromJson(Map<String, dynamic> json) {
    return BatchDetail(
      batchId: TypeUtils.toStringSafe(json['batch_id']),
      batchName: TypeUtils.toStringSafe(json['batch_name']),
      houseId: TypeUtils.toStringSafe(json['house_id']),
      houseName: TypeUtils.toStringSafe(json['house_name']),
      birdsCount: TypeUtils.toIntSafe(json['birds_count']),
      birdTypeId: TypeUtils.toStringSafe(json['bird_type_id']),
      birdTypeName: TypeUtils.toStringSafe(json['bird_type_name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'batch_name': batchName,
      'house_id': houseId,
      'house_name': houseName,
      'birds_count': birdsCount,
      'bird_type_id': birdTypeId,
      'bird_type_name': birdTypeName,
    };
  }
}

class VetOrderResponse {
  final String id;
  final String orderNumber;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String vetId;
  final String vetName;
  final String? vetCenter;
  final String houseId;
  final String houseName;
  final String batchId;
  final String batchName;
  final int birdCount;
  final String serviceId;
  final String serviceName;
  final String serviceCode;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
  final String reasonForVisit;
  final String? additionalNotes;
  final double consultationFee;
  final double serviceFee;
  final double mileageFee;
  final double distanceKm;
  final double prioritySurcharge;
  final double totalEstimatedCost;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool termsAgreed;

  const VetOrderResponse({
    required this.id,
    required this.orderNumber,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.vetId,
    required this.vetName,
    required this.vetCenter,
    required this.houseId,
    required this.houseName,
    required this.batchId,
    required this.batchName,
    required this.birdCount,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCode,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.reasonForVisit,
    required this.additionalNotes,
    required this.consultationFee,
    required this.serviceFee,
    required this.mileageFee,
    required this.distanceKm,
    required this.prioritySurcharge,
    required this.totalEstimatedCost,
    required this.status,
    required this.submittedAt,
    required this.reviewedAt,
    required this.scheduledAt,
    required this.completedAt,
    required this.cancelledAt,
    required this.cancellationReason,
    required this.termsAgreed,
  });

  factory VetOrderResponse.fromJson(Map<String, dynamic> json) {
    return VetOrderResponse(
      id: TypeUtils.toStringSafe(json['id']),
      orderNumber: TypeUtils.toStringSafe(json['order_number']),
      farmerId: TypeUtils.toStringSafe(json['farmer_id']),
      farmerName: TypeUtils.toStringSafe(json['farmer_name']),
      farmerPhone: TypeUtils.toStringSafe(json['farmer_phone']),
      vetId: TypeUtils.toStringSafe(json['vet_id']),
      vetName: TypeUtils.toStringSafe(json['vet_name']),
      vetCenter: TypeUtils.toNullableStringSafe(json['vet_center']),
      houseId: TypeUtils.toStringSafe(json['house_id']),
      houseName: TypeUtils.toStringSafe(json['house_name']),
      batchId: TypeUtils.toStringSafe(json['batch_id']),
      batchName: TypeUtils.toStringSafe(json['batch_name']),
      birdCount: TypeUtils.toIntSafe(json['bird_count']),
      serviceId: TypeUtils.toStringSafe(json['service_id']),
      serviceName: TypeUtils.toStringSafe(json['service_name']),
      serviceCode: TypeUtils.toStringSafe(json['service_code']),
      priorityLevel: TypeUtils.toStringSafe(json['priority_level']),
      preferredDate: TypeUtils.toStringSafe(json['preferred_date']),
      preferredTime: TypeUtils.toStringSafe(json['preferred_time']),
      reasonForVisit: TypeUtils.toStringSafe(json['reason_for_visit']),
      additionalNotes: TypeUtils.toNullableStringSafe(json['additional_notes']),
      consultationFee: TypeUtils.toDoubleSafe(json['consultationFee']),
      serviceFee: TypeUtils.toDoubleSafe(json['serviceFee']),
      mileageFee: TypeUtils.toDoubleSafe(json['mileageFee']),
      distanceKm: TypeUtils.toDoubleSafe(json['distanceKm']),
      prioritySurcharge: TypeUtils.toDoubleSafe(json['prioritySurcharge']),
      totalEstimatedCost: TypeUtils.toDoubleSafe(json['totalEstimatedCost']),
      status: TypeUtils.toStringSafe(json['status']),
      submittedAt: TypeUtils.toDateTimeSafe(json['submitted_at']) ?? DateTime.now(),
      reviewedAt: TypeUtils.toDateTimeSafe(json['reviewed_at']),
      scheduledAt: TypeUtils.toDateTimeSafe(json['scheduled_at']),
      completedAt: TypeUtils.toDateTimeSafe(json['completed_at']),
      cancelledAt: TypeUtils.toDateTimeSafe(json['cancelled_at']),
      cancellationReason: TypeUtils.toNullableStringSafe(json['cancellation_reason']),
      termsAgreed: TypeUtils.toBoolSafe(json['terms_agreed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'farmer_phone': farmerPhone,
      'vet_id': vetId,
      'vet_name': vetName,
      'vet_center': vetCenter,
      'house_id': houseId,
      'house_name': houseName,
      'batch_id': batchId,
      'batch_name': batchName,
      'bird_count': birdCount,
      'service_id': serviceId,
      'service_name': serviceName,
      'service_code': serviceCode,
      'priority_level': priorityLevel,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'reason_for_visit': reasonForVisit,
      'additional_notes': additionalNotes,
      'consultationFee': consultationFee,
      'serviceFee': serviceFee,
      'mileageFee': mileageFee,
      'distanceKm': distanceKm,
      'prioritySurcharge': prioritySurcharge,
      'totalEstimatedCost': totalEstimatedCost,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'terms_agreed': termsAgreed,
    };
  }

  // Helper getters
  String get referenceNumber => orderNumber;
  String get currency => 'Ksh';
  double get totalCost => totalEstimatedCost;

  String get message {
    return 'Your veterinary service order has been submitted successfully. '
        'The vet will contact you shortly to confirm the appointment.';
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    farmerId,
    vetId,
    houseId,
    batchId,
    serviceId,
    submittedAt,
    status,
  ];
}