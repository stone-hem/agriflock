// lib/features/farmer/batch/model/vaccination_model.dart

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
  final String vaccineName;
  final String vaccineType;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String vaccinationStatus;
  final String dosage;
  final String administrationMethod;
  final String? administeredBy;
  final DateTime? administeredAt;
  final int? birdsVaccinated;
  final String cost;
  final String? notes;
  final bool reminderSent;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vaccination({
    required this.id,
    required this.batchId,
    this.vaccineCatalogId,
    this.vaccineCatalog,
    required this.vaccineName,
    required this.vaccineType,
    required this.scheduledDate,
    this.completedDate,
    required this.vaccinationStatus,
    required this.dosage,
    required this.administrationMethod,
    this.administeredBy,
    this.administeredAt,
    this.birdsVaccinated,
    required this.cost,
    this.notes,
    required this.reminderSent,
    required this.source,
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
      vaccineName: json['vaccine_name'],
      vaccineType: json['vaccine_type'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
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
      notes: json['notes'],
      reminderSent: json['reminder_sent'],
      source: json['source'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isOverdue {
    if (vaccinationStatus != 'scheduled') return false;
    return DateTime.now().isAfter(scheduledDate);
  }

  bool get isDueToday {
    if (vaccinationStatus != 'scheduled') return false;
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isUpcoming {
    if (vaccinationStatus != 'scheduled') return false;
    return scheduledDate.isAfter(DateTime.now()) && !isDueToday;
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
  final DateTime? completedDate;
  final int? birdsVaccinated;
  final String? notes;
  final String? failureReason;
  final String? cancellationReason;
  final DateTime? scheduledDate;



  UpdateVaccinationStatusRequest({
    required this.status,
    this.completedDate,
    this.birdsVaccinated,
    this.notes,
    this.failureReason,
    this.cancellationReason,
    this.scheduledDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'vaccination_status': status,
      if (completedDate != null)
        'completed_date': completedDate!.toIso8601String(),
      if (birdsVaccinated != null) 'birds_vaccinated': birdsVaccinated,
      if (notes != null) 'notes': notes,
      if (failureReason != null) 'failure_reason': failureReason,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
    };
  }
}

class VaccinationScheduleRequest {
  final String vaccineName;
  final String vaccineType;
  final DateTime scheduledDate;
  final String dosage;
  final String administrationMethod;
  final double cost;
  final String? notes;
  final String source;

  VaccinationScheduleRequest({
    required this.vaccineName,
    required this.vaccineType,
    required this.scheduledDate,
    required this.dosage,
    required this.administrationMethod,
    required this.cost,
    this.notes,
    this.source = 'manual',
  });

  Map<String, dynamic> toJson() => {
    'vaccine_name': vaccineName,
    'vaccine_type': vaccineType,
    'scheduled_date': scheduledDate.toIso8601String(),
    'dosage': dosage,
    'administration_method': administrationMethod,
    'cost': cost,
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
  final double cost;
  final String? notes;

  QuickDoneVaccinationRequest({
    required this.vaccineName,
    required this.vaccineType,
    required this.dosage,
    required this.administrationMethod,
    required this.birdsVaccinated,
    required this.completedDate,
    required this.cost,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'vaccine_name': vaccineName,
    'vaccine_type': vaccineType,
    'completed_date': completedDate.toIso8601String(),
    'dosage': dosage,
    'administration_method': administrationMethod,
    'cost': cost,
    'notes': notes,
    'source': 'manual',
    'vaccination_status': 'completed',
  };
}