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

  const VetLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class FarmerLocation {
  final double latitude;
  final double longitude;
  final String address;

  const FarmerLocation({
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
  final int totalCost;
  final int consultationFee;
  final int serviceFee;
  final int mileageFee;
  final int prioritySurcharge;
  final String houseName;
  final String batchName;
  final String reason;
  final String notes;
  final VetLocation vetLocation;
  final FarmerLocation farmerLocation;
  final DateTime estimatedArrivalTime;
  final DateTime? serviceCompletedDate;
  final bool isPaid;
  final int userRating; // 1-5 stars
  final String userComment;

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
    required this.isPaid,
    required this.userRating,
    required this.userComment,
  });

  // Copy with method for updating order properties
  VetOrder copyWith({
    String? id,
    String? vetId,
    String? vetName,
    String? serviceType,
    String? priority,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    OrderStatus? status,
    int? totalCost,
    int? consultationFee,
    int? serviceFee,
    int? mileageFee,
    int? prioritySurcharge,
    String? houseName,
    String? batchName,
    String? reason,
    String? notes,
    VetLocation? vetLocation,
    FarmerLocation? farmerLocation,
    DateTime? estimatedArrivalTime,
    DateTime? serviceCompletedDate,
    bool? isPaid,
    int? userRating,
    String? userComment,
  }) {
    return VetOrder(
      id: id ?? this.id,
      vetId: vetId ?? this.vetId,
      vetName: vetName ?? this.vetName,
      serviceType: serviceType ?? this.serviceType,
      priority: priority ?? this.priority,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      totalCost: totalCost ?? this.totalCost,
      consultationFee: consultationFee ?? this.consultationFee,
      serviceFee: serviceFee ?? this.serviceFee,
      mileageFee: mileageFee ?? this.mileageFee,
      prioritySurcharge: prioritySurcharge ?? this.prioritySurcharge,
      houseName: houseName ?? this.houseName,
      batchName: batchName ?? this.batchName,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      vetLocation: vetLocation ?? this.vetLocation,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      serviceCompletedDate: serviceCompletedDate ?? this.serviceCompletedDate,
      isPaid: isPaid ?? this.isPaid,
      userRating: userRating ?? this.userRating,
      userComment: userComment ?? this.userComment,
    );
  }

  // Helper method to get status color
  Color getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.enRoute:
        return Colors.purple;
      case OrderStatus.arrived:
        return Colors.green;
      case OrderStatus.inService:
        return Colors.indigo;
      case OrderStatus.completed:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  // Helper method to get status text
  String getStatusText() {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.enRoute:
        return 'En Route';
      case OrderStatus.arrived:
        return 'Arrived';
      case OrderStatus.inService:
        return 'In Service';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Helper method to get formatted total cost
  String getFormattedTotalCost() {
    return '\$${(totalCost / 100).toStringAsFixed(2)}';
  }

  // Helper method to get formatted date
  String getFormattedDate() {
    return scheduledDate.toLocal().toString().split(' ')[0];
  }

  // Helper method to check if order needs payment
  bool get needsPayment => !isPaid && status == OrderStatus.completed;

  // Helper method to check if order needs rating
  bool get needsRating => userRating == 0 && status == OrderStatus.completed;

  // Helper method to get time until arrival
  Duration get timeUntilArrival => estimatedArrivalTime.difference(DateTime.now());

  // Helper method to check if vet is within tracking window
  bool get isWithinTrackingWindow =>
      timeUntilArrival.inHours <= 1 && timeUntilArrival.inMinutes > 0 && status == OrderStatus.enRoute;
}