import 'dart:convert';
import 'package:agriflock/core/utils/type_safe_utils.dart'; // Adjust the import path as needed

class BatchModel {
  final String id;
  final String batchNumber;
  final String? houseId;
  final String birdTypeId;
  final String? houseName;
  final String breed;
  final String type;
  final DateTime startDate;
  final int age;
  final int initialQuantity;
  final int birdsAlive;
  final num mortality;
  final double currentWeight;
  final double expectedWeight;
  final String feedingTime;
  final List<String> feedingSchedule;
  final String? photoUrl;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BatchModel({
    required this.id,
    required this.batchNumber,
    this.houseId,
    required this.birdTypeId,
    this.houseName,
    required this.breed,
    required this.type,
    required this.startDate,
    required this.age,
    required this.initialQuantity,
    required this.birdsAlive,
    this.mortality = 0,
    required this.currentWeight,
    required this.expectedWeight,
    required this.feedingTime,
    required this.feedingSchedule,
    this.photoUrl,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    // Parse feeding schedule - handle both List and comma-separated string
    List<String> parsedFeedingSchedule = [];
    dynamic scheduleValue = json['feeding_schedule'];
    if (scheduleValue != null) {
      if (scheduleValue is String) {
        String scheduleString = TypeUtils.toStringSafe(scheduleValue);
        // Split by comma and trim whitespace
        parsedFeedingSchedule = scheduleString
            .split(',')
            .map((time) => time.trim())
            .where((time) => time.isNotEmpty)
            .toList();
      } else if (scheduleValue is List) {
        parsedFeedingSchedule = TypeUtils.toListSafe<String>(scheduleValue);
      }
    }

    // Parse feeding time - handle null case with default
    String feedingTime = TypeUtils.toStringSafe(json['feeding_time'], defaultValue: 'Day');
    // Ensure feeding time is one of the expected values if needed
    if (!['Day', 'Night', 'Both'].contains(feedingTime)) {
      // Map other values to valid ones, or keep as is if flexible
      if (feedingTime.toLowerCase().contains('both')) {
        feedingTime = 'Both';
      } else if (feedingTime.toLowerCase().contains('night')) {
        feedingTime = 'Night';
      } else {
        feedingTime = 'Day'; // Default
      }
    }

    return BatchModel(
      id: TypeUtils.toStringSafe(json['id']),
      batchNumber: TypeUtils.toStringSafe(json['batch_number'] ?? json['batch_name'], defaultValue: ''),
      houseId: TypeUtils.toNullableStringSafe(json['house_id']),
      birdTypeId: TypeUtils.toStringSafe(json['bird_type_id'], defaultValue: ''),
      houseName: TypeUtils.toNullableStringSafe(json['house_name']),
      breed: TypeUtils.toStringSafe(json['breed'], defaultValue: ''),
      type: TypeUtils.toStringSafe(json['batch_type'], defaultValue: ''),
      startDate: TypeUtils.toDateTimeSafe(json['start_date']) ?? DateTime.now(),
      age: TypeUtils.toIntSafe(json['age']),
      initialQuantity: TypeUtils.toIntSafe(json['initial_quantity'] ?? json['quantity']),
      birdsAlive: TypeUtils.toIntSafe(json['birds_alive'] ?? json['quantity']),
      mortality: TypeUtils.toDoubleSafe(json['mortality']),
      currentWeight: TypeUtils.toDoubleSafe(json['current_weight']),
      expectedWeight: TypeUtils.toDoubleSafe(json['expected_weight']),
      feedingTime: feedingTime,
      feedingSchedule: parsedFeedingSchedule,
      photoUrl: TypeUtils.toNullableStringSafe(json['photo_url'] ?? json['batch_avatar']),
      description: TypeUtils.toNullableStringSafe(json['description'] ?? json['notes']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_name': batchNumber,
      'house_id': houseId,
      'bird_type_id': birdTypeId,
      'breed': breed,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'age': age,
      'initial_quantity': initialQuantity,
      'birds_alive': birdsAlive,
      'mortality': mortality,
      'current_weight': currentWeight,
      'expected_weight': expectedWeight,
      'feeding_time': feedingTime,
      'feeding_schedule': feedingSchedule.join(','), // Convert back to comma-separated string
      'photo_url': photoUrl,
      'description': description,
    };
  }

  // Helper method to get feeding times as DateTime for easier scheduling
  List<DateTime> getFeedingTimes(DateTime referenceDate) {
    final times = <DateTime>[];
    final now = referenceDate;
    for (final timeString in feedingSchedule) {
      try {
        // Parse time string - handle various formats
        String normalizedTime = timeString.toLowerCase();
        // Remove AM/PM indicators and extra text
        normalizedTime = normalizedTime
            .replaceAll('am', '')
            .replaceAll('pm', '')
            .replaceAll('noon', '12:00')
            .replaceAll('midnight', '00:00')
            .trim();

        // Extract hour and minute
        final parts = normalizedTime.split(':');
        if (parts.length >= 2) {
          int hour = int.tryParse(parts[0]) ?? 0;
          int minute = int.tryParse(parts[1]) ?? 0;

          // Handle PM times (add 12 hours)
          if (timeString.toLowerCase().contains('pm') && hour < 12) {
            hour += 12;
          }

          // Handle midnight/noon special cases
          if (timeString.toLowerCase().contains('midnight') && hour == 12) {
            hour = 0;
          }

          final time = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );
          times.add(time);
        }
      } catch (e) {
        // Skip invalid time formats
        continue;
      }
    }
    return times;
  }

  BatchModel copyWith({
    String? id,
    String? batchName,
    String? houseId,
    String? birdTypeId,
    String? houseName,
    String? breed,
    String? type,
    DateTime? startDate,
    int? age,
    int? initialQuantity,
    int? birdsAlive,
    num? mortality,
    double? currentWeight,
    double? expectedWeight,
    String? feedingTime,
    List<String>? feedingSchedule,
    String? photoUrl,
    String? description,
  }) {
    return BatchModel(
      id: id ?? this.id,
      batchNumber: batchName ?? this.batchNumber,
      houseId: houseId ?? this.houseId,
      birdTypeId: birdTypeId ?? this.birdTypeId,
      houseName: houseName ?? this.houseName,
      breed: breed ?? this.breed,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      age: age ?? this.age,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      birdsAlive: birdsAlive ?? this.birdsAlive,
      mortality: mortality ?? this.mortality,
      currentWeight: currentWeight ?? this.currentWeight,
      expectedWeight: expectedWeight ?? this.expectedWeight,
      feedingTime: feedingTime ?? this.feedingTime,
      feedingSchedule: feedingSchedule ?? this.feedingSchedule,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class House {
  final String? id;
  final String houseName;
  final String? farmId;
  final int capacity;
  final int currentBirds;
  final double utilization;
  final List<BatchModel> batches;
  final String? photoUrl;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const House({
    this.id,
    required this.houseName,
    this.farmId,
    required this.capacity,
    this.currentBirds = 0,
    this.utilization = 0,
    this.batches = const [],
    this.photoUrl,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    List<BatchModel> batchList = TypeUtils.toListSafe<Map<String, dynamic>>(json['batches'])
        .map((b) => BatchModel.fromJson(b))
        .toList();

    return House(
      id: TypeUtils.toNullableStringSafe(json['id']),
      houseName: TypeUtils.toStringSafe(json['house_name'] ?? json['name'], defaultValue: ''),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      capacity: TypeUtils.toIntSafe(json['capacity']),
      currentBirds: TypeUtils.toIntSafe(json['current_birds'] ?? json['currentBirds']),
      utilization: TypeUtils.toDoubleSafe(json['utilization']),
      batches: batchList,
      photoUrl: TypeUtils.toNullableStringSafe(json['photo_url'] ?? json['house_avatar']),
      description: TypeUtils.toNullableStringSafe(json['description']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'house_name': houseName,
      'farm_id': farmId,
      'capacity': capacity,
      'current_birds': currentBirds,
      'utilization': utilization,
      'batches': batches.map((b) => b.toJson()).toList(),
      'photo_url': photoUrl,
      'description': description,
    };
  }

  House copyWith({
    String? id,
    String? houseName,
    String? farmId,
    int? capacity,
    int? currentBirds,
    double? utilization,
    List<BatchModel>? batches,
    String? photoUrl,
    String? description,
  }) {
    return House(
      id: id ?? this.id,
      houseName: houseName ?? this.houseName,
      farmId: farmId ?? this.farmId,
      capacity: capacity ?? this.capacity,
      currentBirds: currentBirds ?? this.currentBirds,
      utilization: utilization ?? this.utilization,
      batches: batches ?? this.batches,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}