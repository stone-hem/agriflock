// vet_order_list_item.dart
import 'dart:convert';

class MyOrderListItem {
  final String id;
  final String orderNumber;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final dynamic farmerLocation; // Changed to dynamic since it's a JSON string
  final String vetId;
  final String vetName;
  final dynamic vetLocation; // Changed to dynamic
  final String? vetCenter;
  final String houseId;
  final String houseName;
  final String batchId;
  final String batchName;
  final int birdCount;
  final String serviceId;
  final String serviceType; // Changed from serviceName
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
  final bool isPaid; // Added this field

  MyOrderListItem({
    required this.id,
    required this.orderNumber,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerLocation,
    required this.vetId,
    required this.vetName,
    required this.vetLocation,
    this.vetCenter,
    required this.houseId,
    required this.houseName,
    required this.batchId,
    required this.batchName,
    required this.birdCount,
    required this.serviceId,
    required this.serviceType,
    required this.serviceCode,
    required this.priorityLevel,
    required this.preferredDate,
    required this.preferredTime,
    required this.reasonForVisit,
    this.additionalNotes,
    required this.consultationFee,
    required this.serviceFee,
    required this.mileageFee,
    required this.distanceKm,
    required this.prioritySurcharge,
    required this.totalEstimatedCost,
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
      farmerLocation: json['farmer_location'], // Could be String or Map
      vetId: json['vet_id'] as String,
      vetName: json['vet_name'] as String,
      vetLocation: json['vet_location'], // Could be Map<String, dynamic>
      vetCenter: json['vet_center'] as String?,
      houseId: json['house_id'] as String,
      houseName: json['house_name'] as String,
      batchId: json['batch_id'] as String,
      batchName: json['batch_name'] as String,
      birdCount: json['bird_count'] as int,
      serviceId: json['service_id'] as String,
      serviceType: json['service_type'] as String, // Changed key
      serviceCode: json['service_code'] as String,
      priorityLevel: json['priority_level'] as String,
      preferredDate: DateTime.parse(json['preferred_date'] as String),
      preferredTime: json['preferred_time'] as String,
      reasonForVisit: json['reason_for_visit'] as String,
      additionalNotes: json['additional_notes'] as String?,
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
      cancellationReason: json['cancellation_reason'] as String?,
      termsAgreed: json['terms_agreed'] as bool,
      isPaid: json['is_paid'] as bool, // Added this
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
      'vet_location': vetLocation,
      'vet_center': vetCenter,
      'house_id': houseId,
      'house_name': houseName,
      'batch_id': batchId,
      'batch_name': batchName,
      'bird_count': birdCount,
      'service_id': serviceId,
      'service_type': serviceType, // Changed key
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
      'is_paid': isPaid, // Added this
    };
  }

  // Helper methods to parse location data
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

  // Parse vet location (should already be a Map based on your JSON)
  Map<String, dynamic>? get parsedVetLocation {
    if (vetLocation is Map) {
      return vetLocation as Map<String, dynamic>;
    }
    return null;
  }

  String? get vetAddress {
    final location = parsedVetLocation;
    if (location != null && location.containsKey('address')) {
      return location['address'] as String;
    }
    return null;
  }
}