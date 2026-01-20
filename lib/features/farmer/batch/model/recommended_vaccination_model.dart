// lib/features/farmer/batch/model/recommended_vaccination_model.dart

class RecommendedVaccination {
  final String id;
  final String vaccineName;
  final String? vaccineType;
  final String? description;
  final String? manufacturer;
  final String? brandName;
  final int recommendedAgeMin;
  final int recommendedAgeMax;
  final String? recommendedAgeDescription;
  final String dosage;
  final String administrationMethod;
  final String? usageInstructions;
  final String? precautions;
  final String? sideEffects;
  final int? withdrawalPeriodDays;
  final String? storageConditions;
  final String? estimatedCostPerDose;
  final String? currency;
  final String? targetDisease;
  final String? birdType;
  final bool? isRecommended;
  final bool? isActive;
  final int? usageCount;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecommendedVaccination({
    required this.id,
    required this.vaccineName,
    this.vaccineType,
    this.description,
    this.manufacturer,
    this.brandName,
    required this.recommendedAgeMin,
    required this.recommendedAgeMax,
    this.recommendedAgeDescription,
    required this.dosage,
    required this.administrationMethod,
    this.usageInstructions,
    this.precautions,
    this.sideEffects,
    this.withdrawalPeriodDays,
    this.storageConditions,
    this.estimatedCostPerDose,
    this.currency,
    this.targetDisease,
    this.birdType,
    this.isRecommended,
    this.isActive,
    this.usageCount,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory RecommendedVaccination.fromJson(Map<String, dynamic> json) {
    return RecommendedVaccination(
      id: json['id'] as String,
      vaccineName: json['vaccine_name'] as String,
      vaccineType: json['vaccine_type'] as String?,
      description: json['description'] as String?,
      manufacturer: json['manufacturer'] as String?,
      brandName: json['brand_name'] as String?,
      recommendedAgeMin: (json['recommended_age_min'] as num).toInt(),
      recommendedAgeMax: (json['recommended_age_max'] as num).toInt(),
      recommendedAgeDescription: json['recommended_age_description'] as String?,
      dosage: json['dosage'] as String,
      administrationMethod: json['administration_method'] as String,
      usageInstructions: json['usage_instructions'] as String?,
      precautions: json['precautions'] as String?,
      sideEffects: json['side_effects'] as String?,
      withdrawalPeriodDays: (json['withdrawal_period_days'] as num?)?.toInt(),
      storageConditions: json['storage_conditions'] as String?,
      estimatedCostPerDose: json['estimated_cost_per_dose'] as String?,
      currency: json['currency'] as String?,
      targetDisease: json['target_disease'] as String?,
      birdType: json['bird_type'] as String?,
      isRecommended: json['is_recommended'] as bool?,
      isActive: json['is_active'] as bool?,
      usageCount: (json['usage_count'] as num?)?.toInt(),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccine_name': vaccineName,
      'vaccine_type': vaccineType,
      'description': description,
      'manufacturer': manufacturer,
      'brand_name': brandName,
      'recommended_age_min': recommendedAgeMin,
      'recommended_age_max': recommendedAgeMax,
      'recommended_age_description': recommendedAgeDescription,
      'dosage': dosage,
      'administration_method': administrationMethod,
      'usage_instructions': usageInstructions,
      'precautions': precautions,
      'side_effects': sideEffects,
      'withdrawal_period_days': withdrawalPeriodDays,
      'storage_conditions': storageConditions,
      'estimated_cost_per_dose': estimatedCostPerDose,
      'currency': currency,
      'target_disease': targetDisease,
      'bird_type': birdType,
      'is_recommended': isRecommended,
      'is_active': isActive,
      'usage_count': usageCount,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class RecommendedVaccinationsResponse {
  final bool success;
  final List<RecommendedVaccination> data;
  final RecommendedVaccinationsMeta meta;

  RecommendedVaccinationsResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory RecommendedVaccinationsResponse.fromJson(Map<String, dynamic> json) {
    return RecommendedVaccinationsResponse(
      success: json['success'] as bool,
      data: (json['data'] as List)
          .map((e) => RecommendedVaccination.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: RecommendedVaccinationsMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class RecommendedVaccinationsMeta {
  final int batchAgeDays;
  final int scheduledCount;

  RecommendedVaccinationsMeta({
    required this.batchAgeDays,
    required this.scheduledCount,
  });

  factory RecommendedVaccinationsMeta.fromJson(Map<String, dynamic> json) {
    return RecommendedVaccinationsMeta(
      batchAgeDays: (json['batch_age_days'] as num).toInt(),
      scheduledCount: (json['scheduled_count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_age_days': batchAgeDays,
      'scheduled_count': scheduledCount,
    };
  }
}

class AdoptVaccinationRequest {
  final String vaccineId;
  final DateTime? scheduledDate;
  final String? notes;

  AdoptVaccinationRequest({
    required this.vaccineId,
    this.scheduledDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'vaccine_id': vaccineId,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'notes': notes,
    };
  }
}

// Create this new model or update the existing one
class AdoptVaccinationsRequest {
  final List<String> vaccineCatalogIds;
  final DateTime scheduledDate;
  final bool skipExisting;

  AdoptVaccinationsRequest({
    required this.vaccineCatalogIds,
    required this.scheduledDate,
    this.skipExisting = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'vaccineCatalogIds': vaccineCatalogIds,
      'scheduledDate': scheduledDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'skipExisting': skipExisting,
    };
  }
}