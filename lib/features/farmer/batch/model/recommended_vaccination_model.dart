import 'package:agriflock/core/utils/type_safe_utils.dart';

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
      id: TypeUtils.toStringSafe(json['id']),
      vaccineName: TypeUtils.toStringSafe(json['vaccine_name']),
      vaccineType: TypeUtils.toNullableStringSafe(json['vaccine_type']),
      description: TypeUtils.toNullableStringSafe(json['description']),
      manufacturer: TypeUtils.toNullableStringSafe(json['manufacturer']),
      brandName: TypeUtils.toNullableStringSafe(json['brand_name']),
      recommendedAgeMin: TypeUtils.toIntSafe(json['recommended_age_min']),
      recommendedAgeMax: TypeUtils.toIntSafe(json['recommended_age_max']),
      recommendedAgeDescription: TypeUtils.toNullableStringSafe(json['recommended_age_description']),
      dosage: TypeUtils.toStringSafe(json['dosage']),
      administrationMethod: TypeUtils.toStringSafe(json['administration_method']),
      usageInstructions: TypeUtils.toNullableStringSafe(json['usage_instructions']),
      precautions: TypeUtils.toNullableStringSafe(json['precautions']),
      sideEffects: TypeUtils.toNullableStringSafe(json['side_effects']),
      withdrawalPeriodDays: TypeUtils.toNullableIntSafe(json['withdrawal_period_days']),
      storageConditions: TypeUtils.toNullableStringSafe(json['storage_conditions']),
      estimatedCostPerDose: TypeUtils.toNullableStringSafe(json['estimated_cost_per_dose']),
      currency: TypeUtils.toNullableStringSafe(json['currency']),
      targetDisease: TypeUtils.toNullableStringSafe(json['target_disease']),
      birdType: TypeUtils.toNullableStringSafe(json['bird_type']),
      isRecommended: TypeUtils.toNullableBoolSafe(json['is_recommended']),
      isActive: TypeUtils.toNullableBoolSafe(json['is_active']),
      usageCount: TypeUtils.toNullableIntSafe(json['usage_count']),
      metadata: TypeUtils.toMapSafe(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']),
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
      success: TypeUtils.toBoolSafe(json['success']),
      data: TypeUtils.toListSafe<Map<String, dynamic>>(json['data'])
          .map((e) => RecommendedVaccination.fromJson(e))
          .toList(),
      meta: RecommendedVaccinationsMeta.fromJson(TypeUtils.toMapSafe(json['meta']) ?? {}),
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
      batchAgeDays: TypeUtils.toIntSafe(json['batch_age_days']),
      scheduledCount: TypeUtils.toIntSafe(json['scheduled_count']),
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
