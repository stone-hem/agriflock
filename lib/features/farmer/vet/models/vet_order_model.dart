class VetOrderRequest {
  final String vetId;
  final String? houseId;
  final String? batchId;
  final String? serviceId;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
  final String reasonForVisit;
  final String? additionalNotes;
  final bool termsAgreed;

  VetOrderRequest({
    required this.vetId,
    this.houseId,
    this.batchId,
    this.serviceId,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.reasonForVisit,
    this.additionalNotes,
    required this.termsAgreed,
  });

  Map<String, dynamic> toJson() {
    return {
      'vet_id': vetId,
      'house_id': houseId,
      'batch_id': batchId,
      'service_id': serviceId,
      'priority_level': priorityLevel,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'reason_for_visit': reasonForVisit,
      'additional_notes': additionalNotes,
      'terms_agreed': termsAgreed,
    };
  }
}

class VetEstimateRequest {
  final String vetId;
  final String? houseId;
  final String? batchId;
  final String? serviceId;
  final String priorityLevel;
  final String preferredDate;
  final String preferredTime;
  final String reasonForVisit;
  final String? additionalNotes;
  final bool termsAgreed;

  VetEstimateRequest({
    required this.vetId,
    this.houseId,
    this.batchId,
    this.serviceId,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.reasonForVisit,
    this.additionalNotes,
    required this.termsAgreed,
  });

  Map<String, dynamic> toJson() {
    return {
      'vet_id': vetId,
      'house_id': houseId,
      'batch_id': batchId,
      'service_id': serviceId,
      'priority_level': priorityLevel,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'reason_for_visit': reasonForVisit,
      'additional_notes': additionalNotes,
      'terms_agreed': termsAgreed,
    };
  }
}

class VetEstimateResponse {
  final double totalEstimatedCost;
  final double consultationFee;
  final double serviceFee;
  final double mileageFee;
  final double distanceKm;
  final double prioritySurcharge;
  final String currency;
  final String? breakdown;
  final String? notes;
  final String? serviceCode;
  final String? mileageDetails;

  VetEstimateResponse({
    required this.totalEstimatedCost,
    required this.consultationFee,
    required this.serviceFee,
    required this.mileageFee,
    required this.distanceKm,
    required this.prioritySurcharge,
    this.currency = 'KES',
    this.breakdown,
    this.notes,
    this.serviceCode,
    this.mileageDetails,
  });

  factory VetEstimateResponse.fromJson(Map<String, dynamic> json) {
    return VetEstimateResponse(
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
      consultationFee: (json['consultationFee'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      mileageFee: (json['mileageFee'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      prioritySurcharge: (json['prioritySurcharge'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      breakdown: json['breakdown'] as String?,
      notes: json['notes'] as String?,
      serviceCode: json['serviceCode'] as String?,
      mileageDetails: json['mileageDetails'] as String?,
    );
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
      id: json['id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      farmerId: json['farmer_id'] ?? '',
      farmerName: json['farmer_name'] ?? '',
      farmerPhone: json['farmer_phone'] ?? '',
      vetId: json['vet_id'] ?? '',
      vetName: json['vet_name'] ?? '',
      vetCenter: json['vet_center'],
      houseId: json['house_id'] ?? '',
      houseName: json['house_name'] ?? '',
      batchId: json['batch_id'] ?? '',
      batchName: json['batch_name'] ?? '',
      birdCount: json['bird_count'] ?? 0,
      serviceId: json['service_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      serviceCode: json['service_code'] ?? '',
      priorityLevel: json['priority_level'] ?? '',
      preferredDate: json['preferred_date'] ?? '',
      preferredTime: json['preferred_time'] ?? '',
      reasonForVisit: json['reason_for_visit'] ?? '',
      additionalNotes: json['additional_notes'],
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      serviceFee: (json['serviceFee'] ?? 0).toDouble(),
      mileageFee: (json['mileageFee'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      prioritySurcharge: (json['prioritySurcharge'] ?? 0).toDouble(),
      totalEstimatedCost: (json['totalEstimatedCost'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      submittedAt: DateTime.parse(json['submitted_at'] ?? DateTime.now().toIso8601String()),
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      cancellationReason: json['cancellation_reason'],
      termsAgreed: json['terms_agreed'] ?? false,
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
  String get currency => 'Ksh'; // Assuming Kenyan Shillings based on phone number
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