import 'package:flutter/material.dart';
import 'dart:convert';


class VaccineCatalog {
  final String id;
  final String vaccineName;
  final String vaccineType;
  final String? description;
  final String? manufacturer;
  final String? brandName;
  final int? recommendedAgeMin;
  final int? recommendedAgeMax;
  final String? recommendedAgeDescription;
  final String? dosage;
  final String? administrationMethod;
  final String? usageInstructions;
  final String? precautions;
  final String? sideEffects;
  final int? withdrawalPeriodDays;
  final String? storageConditions;
  final String? estimatedCostPerDose;
  final String? currency;
  final String? targetDisease;
  final String? birdType;
  final bool isRecommended;
  final bool isActive;
  final int? usageCount;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaccineCatalog({
    required this.id,
    required this.vaccineName,
    required this.vaccineType,
    this.description,
    this.manufacturer,
    this.brandName,
    this.recommendedAgeMin,
    this.recommendedAgeMax,
    this.recommendedAgeDescription,
    this.dosage,
    this.administrationMethod,
    this.usageInstructions,
    this.precautions,
    this.sideEffects,
    this.withdrawalPeriodDays,
    this.storageConditions,
    this.estimatedCostPerDose,
    this.currency,
    this.targetDisease,
    this.birdType,
    required this.isRecommended,
    required this.isActive,
    this.usageCount,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VaccineCatalog.fromJson(Map<String, dynamic> json) {
    return VaccineCatalog(
      id: json['id'],
      vaccineName: json['vaccine_name'],
      vaccineType: json['vaccine_type'],
      description: json['description'],
      manufacturer: json['manufacturer'],
      brandName: json['brand_name'],
      recommendedAgeMin: json['recommended_age_min'],
      recommendedAgeMax: json['recommended_age_max'],
      recommendedAgeDescription: json['recommended_age_description'],
      dosage: json['dosage'],
      administrationMethod: json['administration_method'],
      usageInstructions: json['usage_instructions'],
      precautions: json['precautions'],
      sideEffects: json['side_effects'],
      withdrawalPeriodDays: json['withdrawal_period_days'],
      storageConditions: json['storage_conditions'],
      estimatedCostPerDose: json['estimated_cost_per_dose'],
      currency: json['currency'],
      targetDisease: json['target_disease'],
      birdType: json['bird_type'],
      isRecommended: json['is_recommended'],
      isActive: json['is_active'],
      usageCount: json['usage_count'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class Vaccination {
  final String id;
  final String batchId;
  final String? vaccineCatalogId;
  final VaccineCatalog? vaccineCatalog;
  final String? inventoryItemId;
  final String? inventoryTransactionId;
  final String vaccineName;
  final String vaccineType;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final DateTime? completedDate;
  final TimeOfDay? completedTime;
  final String vaccinationStatus;
  final String dosage;
  final String administrationMethod;
  final String? administeredBy;
  final DateTime? administeredAt;
  final int? birdsVaccinated;
  final String? cost;
  final String? currency;
  final String? region;
  final String? estimatedCost;
  final String? notes;
  final bool reminderSent;
  final String source;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vaccination({
    required this.id,
    required this.batchId,
    this.vaccineCatalogId,
    this.vaccineCatalog,
    this.inventoryItemId,
    this.inventoryTransactionId,
    required this.vaccineName,
    required this.vaccineType,
    this.scheduledDate,
    this.scheduledTime,
    this.completedDate,
    this.completedTime,
    required this.vaccinationStatus,
    required this.dosage,
    required this.administrationMethod,
    this.administeredBy,
    this.administeredAt,
    this.birdsVaccinated,
    this.cost,
    this.currency,
    this.region,
    this.estimatedCost,
    this.notes,
    required this.reminderSent,
    required this.source,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'],
      batchId: json['batch_id'],
      vaccineCatalogId: json['vaccine_catalog_id'],
      vaccineCatalog: json['vaccine_catalog'] != null
          ? VaccineCatalog.fromJson(json['vaccine_catalog'])
          : null,
      inventoryItemId: json['inventory_item_id'],
      inventoryTransactionId: json['inventory_transaction_id'],
      vaccineName: json['vaccine_name'],
      vaccineType: json['vaccine_type'],
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : null,
      scheduledTime: json['scheduled_time'] != null
          ? _parseTime(json['scheduled_time'])
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      completedTime: json['completed_time'] != null
          ? _parseTime(json['completed_time'])
          : null,
      vaccinationStatus: json['vaccination_status'],
      dosage: json['dosage'],
      administrationMethod: json['administration_method'],
      administeredBy: json['administered_by'],
      administeredAt: json['administered_at'] != null
          ? DateTime.parse(json['administered_at'])
          : null,
      birdsVaccinated: json['birds_vaccinated'],
      cost: json['cost'],
      currency: json['currency'],
      region: json['region'],
      estimatedCost: json['estimated_cost'],
      notes: json['notes'],
      reminderSent: json['reminder_sent'],
      source: json['source'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null) return null;
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return null;
  }

  // Alternative: Check if status is "completed" and has completion data
  bool get isStatusCompleted {
    return vaccinationStatus == 'completed';
  }

  // Alternative: Check if status is "scheduled" and has scheduled data
  bool get isStatusScheduled {
    return vaccinationStatus == 'scheduled';
  }

  // Get scheduled DateTime with time if available
  DateTime? get scheduledDateTime {
    if (scheduledDate != null && scheduledTime != null) {
      return DateTime(
        scheduledDate!.year,
        scheduledDate!.month,
        scheduledDate!.day,
        scheduledTime!.hour,
        scheduledTime!.minute,
      );
    }
    return scheduledDate;
  }

  // Get completed DateTime with time if available
  DateTime? get completedDateTime {
    if (completedDate != null && completedTime != null) {
      return DateTime(
        completedDate!.year,
        completedDate!.month,
        completedDate!.day,
        completedTime!.hour,
        completedTime!.minute,
      );
    }
    return completedDate;
  }

  // Check if vaccination is overdue (for scheduled vaccinations)
  bool get isOverdue {
    if (!isStatusScheduled || scheduledDate == null) return false;
    final now = DateTime.now();
    final scheduled = scheduledDateTime ?? scheduledDate!;
    return now.isAfter(scheduled);
  }

  // Check if vaccination is due today
  bool get isDueToday {
    if (!isStatusScheduled || scheduledDate == null) return false;
    final now = DateTime.now();
    final scheduled = scheduledDateTime ?? scheduledDate!;
    return scheduled.year == now.year &&
        scheduled.month == now.month &&
        scheduled.day == now.day;
  }

  // Check if vaccination is upcoming (future scheduled)
  bool get isUpcoming {
    if (!isStatusScheduled || scheduledDate == null) return false;
    final now = DateTime.now();
    final scheduled = scheduledDateTime ?? scheduledDate;
    return scheduled!.isAfter(now) && !isDueToday;
  }

  // Check if vaccination is missed (overdue for more than 1 day)
  bool get isMissed {
    if (!isStatusScheduled || scheduledDate == null) return false;
    final now = DateTime.now();
    final scheduled = scheduledDateTime ?? scheduledDate;
    final difference = now.difference(scheduled!);
    return difference.inDays >= 1;
  }

  // Get vaccination status with validation
  String get validatedStatus {
    if (isStatusCompleted) return 'completed';
    if (isStatusScheduled) {
      if (isMissed) return 'missed';
      if (isOverdue) return 'overdue';
      if (isDueToday) return 'due_today';
      if (isUpcoming) return 'upcoming';
      return 'scheduled';
    }
    return vaccinationStatus; // fallback to original status
  }
}



class VaccinationSummary {
  final int total;
  final int completed;
  final int scheduled;
  final int missed;

  VaccinationSummary({
    required this.total,
    required this.completed,
    required this.scheduled,
    required this.missed,
  });

  factory VaccinationSummary.fromJson(Map<String, dynamic> json) {
    return VaccinationSummary(
      total: json['total'],
      completed: json['completed'],
      scheduled: json['scheduled'],
      missed: json['missed'],
    );
  }
}

class VaccinationsResponse {
  final List<Vaccination> vaccinations;
  final VaccinationSummary summary;

  VaccinationsResponse({
    required this.vaccinations,
    required this.summary,
  });

  factory VaccinationsResponse.fromJson(Map<String, dynamic> json) {
    return VaccinationsResponse(
      vaccinations: (json['data'] as List)
          .map((item) => Vaccination.fromJson(item))
          .toList(),
      summary: VaccinationSummary.fromJson(json['summary']),
    );
  }
}

class VaccinationDashboardSummary {
  final int completed;
  final int upcoming;
  final int overdue;
  final String coveragePercentage;
  final int uniqueVaccinatedBirds;

  VaccinationDashboardSummary({
    required this.completed,
    required this.upcoming,
    required this.overdue,
    required this.coveragePercentage,
    required this.uniqueVaccinatedBirds,
  });

  factory VaccinationDashboardSummary.fromJson(Map<String, dynamic> json) {
    return VaccinationDashboardSummary(
      completed: json['completed'],
      upcoming: json['upcoming'],
      overdue: json['overdue'],
      coveragePercentage: json['coverage_percentage'],
      uniqueVaccinatedBirds: json['unique_vaccinated_birds'],
    );
  }
}

class VaccinationDashboard {
  final VaccinationDashboardSummary summary;
  final int totalBirds;
  final String batchName;

  VaccinationDashboard({
    required this.summary,
    required this.totalBirds,
    required this.batchName,
  });

  factory VaccinationDashboard.fromJson(Map<String, dynamic> json) {
    return VaccinationDashboard(
      summary: VaccinationDashboardSummary.fromJson(json['summary']),
      totalBirds: json['total_birds'],
      batchName: json['batch_name'],
    );
  }
}

class CreateVaccinationRequest {
  final String vaccineName;
  final String vaccineType;
  final String scheduledDate;
  final String dosage;
  final String administrationMethod;
  final double cost;
  final String? notes;
  final String source;

  CreateVaccinationRequest({
    required this.vaccineName,
    required this.vaccineType,
    required this.scheduledDate,
    required this.dosage,
    required this.administrationMethod,
    required this.cost,
    this.notes,
    this.source = 'manual',
  });

  Map<String, dynamic> toJson() {
    return {
      'vaccine_name': vaccineName,
      'vaccine_type': vaccineType,
      'scheduled_date': scheduledDate,
      'dosage': dosage,
      'administration_method': administrationMethod,
      'cost': cost,
      if (notes != null) 'notes': notes,
      'source': source,
    };
  }
}


class UpdateVaccinationStatusRequest {
  final String status;
  final String? actualDate;
  final String? actualTime;
  final int? birdsVaccinated;
  final String? administeredBy;
  final String? notes;
  final String? failureReason;
  final String? cancellationReason;
  final bool? rescheduleAfterFailure;
  final String? newScheduledDate;
  final String? newScheduledTime;
  final String? rescheduleReason;

  UpdateVaccinationStatusRequest({
    required this.status,
    this.actualDate,
    this.actualTime,
    this.birdsVaccinated,
    this.administeredBy,
    this.notes,
    this.failureReason,
    this.cancellationReason,
    this.rescheduleAfterFailure,
    this.newScheduledDate,
    this.newScheduledTime,
    this.rescheduleReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (actualDate != null) 'actual_date': actualDate,
      if (actualTime != null) 'actual_time': actualTime,
      if (birdsVaccinated != null) 'birds_vaccinated': birdsVaccinated,
      if (administeredBy != null) 'administered_by': administeredBy,
      if (notes != null) 'notes': notes,
      if (failureReason != null) 'failure_reason': failureReason,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      if (rescheduleAfterFailure != null)
        'reschedule_after_failure': rescheduleAfterFailure,
      if (newScheduledDate != null) 'new_scheduled_date': newScheduledDate,
      if (newScheduledTime != null) 'new_scheduled_time': newScheduledTime,
      if (rescheduleReason != null) 'reschedule_reason': rescheduleReason,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class VaccinationScheduleRequest {
  final String vaccineName;
  final String vaccineType;
  final DateTime scheduledDate;
  final String scheduleTime;
  final String dosage;
  final String administrationMethod;
  final String? notes;
  final String source;

  VaccinationScheduleRequest({
    required this.vaccineName,
    required this.vaccineType,
    required this.scheduledDate,
    required this.dosage,
    required this.administrationMethod,
    this.notes,
    this.source = 'manual',
    required this.scheduleTime,
  });

  Map<String, dynamic> toJson() => {
    'vaccine_name': vaccineName,
    'vaccine_type': vaccineType,
    'scheduled_date': scheduledDate.toIso8601String(),
    'scheduled_time': scheduleTime,
    'dosage': dosage,
    'administration_method': administrationMethod,
    'notes': notes,
    'source': source,
  };
}

class QuickDoneVaccinationRequest {
  final String vaccineName;
  final String vaccineType;
  final String dosage;
  final String administrationMethod;
  final int birdsVaccinated;
  final DateTime completedDate;
  final String completedTime;
  final String? notes;

  QuickDoneVaccinationRequest({
    required this.vaccineName,
    required this.vaccineType,
    required this.dosage,
    required this.administrationMethod,
    required this.birdsVaccinated,
    required this.completedDate,
    this.notes, required this.completedTime,
  });

  Map<String, dynamic> toJson() => {
    'vaccine_name': vaccineName,
    'vaccine_type': vaccineType,
    'completed_date': completedDate.toIso8601String(),
    'completed_time': completedTime,
    'dosage': dosage,
    'birds_vaccinated':birdsVaccinated,
    'administration_method': administrationMethod,
    'notes': notes,
    'source': 'manual'
  };
}