import 'package:agriflock360/features/farmer/vet/models/vet_officer.dart';
import 'package:flutter/material.dart';

class FarmHouse {
  final String id;
  final String name;
  final String location;
  final List<FarmBatch> batches;

  FarmHouse({
    required this.id,
    required this.name,
    required this.location,
    required this.batches,
  });
}

class FarmBatch {
  final String id;
  final String name;
  final int birdCount;
  final int ageWeeks;
  final String birdType;
  final String healthStatus;

  FarmBatch({
    required this.id,
    required this.name,
    required this.birdCount,
    required this.ageWeeks,
    required this.birdType,
    required this.healthStatus,
  });
}

class OrderSummary {
  final VetOfficer vet;
  final FarmHouse house;
  final FarmBatch batch;
  final String serviceType;
  final String priority;
  final DateTime date;
  final TimeOfDay time;
  final String reason;
  final double consultationFee;
  final double serviceFee;
  final double mileageFee;
  final double prioritySurcharge;
  final double totalCost;

  OrderSummary({
    required this.vet,
    required this.house,
    required this.batch,
    required this.serviceType,
    required this.priority,
    required this.date,
    required this.time,
    required this.reason,
    required this.consultationFee,
    required this.serviceFee,
    required this.mileageFee,
    required this.prioritySurcharge,
    required this.totalCost,
  });
}