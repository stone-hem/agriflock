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
  final double estimatedCost;
  final double consultationFee;
  final double serviceFee;
  final double mileageFee;
  final double prioritySurcharge;
  final String currency;
  final String? breakdown;
  final String? notes;

  VetEstimateResponse({
    required this.estimatedCost,
    required this.consultationFee,
    required this.serviceFee,
    required this.mileageFee,
    required this.prioritySurcharge,
    this.currency = 'KES',
    this.breakdown,
    this.notes,
  });

  factory VetEstimateResponse.fromJson(Map<String, dynamic> json) {
    return VetEstimateResponse(
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      consultationFee: (json['consultation_fee'] as num).toDouble(),
      serviceFee: (json['service_fee'] as num).toDouble(),
      mileageFee: (json['mileage_fee'] as num).toDouble(),
      prioritySurcharge: (json['priority_surcharge'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      breakdown: json['breakdown'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class VetOrderResponse {
  final String orderId;
  final String status;
  final String message;
  final double totalCost;
  final String currency;
  final String? referenceNumber;
  final DateTime createdAt;

  VetOrderResponse({
    required this.orderId,
    required this.status,
    required this.message,
    required this.totalCost,
    this.currency = 'KES',
    this.referenceNumber,
    required this.createdAt,
  });

  factory VetOrderResponse.fromJson(Map<String, dynamic> json) {
    return VetOrderResponse(
      orderId: json['order_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      totalCost: (json['total_cost'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      referenceNumber: json['reference_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}