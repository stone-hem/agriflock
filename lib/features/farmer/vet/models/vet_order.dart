import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  enRoute,
  arrived,
  inService,
  completed,
  cancelled,
}

class VetLocation {
  final double latitude;
  final double longitude;
  final String address;

  VetLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class FarmerLocation {
  final double latitude;
  final double longitude;
  final String address;

  FarmerLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class VetOrder {
  final String id;
  final String vetId;
  final String vetName;
  final String serviceType;
  final String priority;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final OrderStatus status;
  final double totalCost;
  final double consultationFee;
  final double serviceFee;
  final double mileageFee;
  final double prioritySurcharge;
  final String houseName;
  final String batchName;
  final String reason;
  final String notes;
  final VetLocation vetLocation;
  final FarmerLocation farmerLocation;
  final DateTime estimatedArrivalTime;
  final DateTime? serviceCompletedDate;

  VetOrder({
    required this.id,
    required this.vetId,
    required this.vetName,
    required this.serviceType,
    required this.priority,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.totalCost,
    required this.consultationFee,
    required this.serviceFee,
    required this.mileageFee,
    required this.prioritySurcharge,
    required this.houseName,
    required this.batchName,
    required this.reason,
    required this.notes,
    required this.vetLocation,
    required this.farmerLocation,
    required this.estimatedArrivalTime,
    this.serviceCompletedDate,
  });

  bool get isWithinOneHourOfArrival {
    final now = DateTime.now();
    final difference = estimatedArrivalTime.difference(now);
    return difference.inHours <= 1 && difference.inMinutes > 0;
  }
}