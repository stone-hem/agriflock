// vet_order_list_item.dart
class MyOrderListItem {
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
  final DateTime preferredDate;
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

  MyOrderListItem({
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

  factory MyOrderListItem.fromJson(Map<String, dynamic> json) {
    return MyOrderListItem(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      farmerId: json['farmer_id'] as String,
      farmerName: json['farmer_name'] as String,
      farmerPhone: json['farmer_phone'] as String,
      vetId: json['vet_id'] as String,
      vetName: json['vet_name'] as String,
      vetCenter: json['vet_center'],
      houseId: json['house_id'] as String,
      houseName: json['house_name'] as String,
      batchId: json['batch_id'] as String,
      batchName: json['batch_name'] as String,
      birdCount: json['bird_count'] as int,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      serviceCode: json['service_code'] as String,
      priorityLevel: json['priority_level'] as String,
      preferredDate: DateTime.parse(json['preferred_date'] as String),
      preferredTime: json['preferred_time'] as String,
      reasonForVisit: json['reason_for_visit'] as String,
      additionalNotes: json['additional_notes'],
      consultationFee: (json['consultationFee'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      mileageFee: (json['mileageFee'] as num).toDouble(),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      prioritySurcharge: (json['prioritySurcharge'] as num).toDouble(),
      totalEstimatedCost: (json['totalEstimatedCost'] as num).toDouble(),
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
      cancellationReason: json['cancellation_reason'],
      termsAgreed: json['terms_agreed'] as bool,
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
      'preferred_date': preferredDate.toIso8601String().split('T')[0],
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
}