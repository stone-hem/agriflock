import 'dart:convert';

import 'package:agriflock360/core/utils/date_util.dart';

class BatchListResponse {
  final List<BatchListItem> batches;
  final Pagination pagination;

  BatchListResponse({
    required this.batches,
    required this.pagination,
  });

  factory BatchListResponse.fromJson(Map<String, dynamic> json) {
    return BatchListResponse(
      batches: List<BatchListItem>.from(
        (json['batchs'] as List<dynamic>? ?? json['batches'] as List<dynamic>? ?? [])
            .map((batch) => BatchListItem.fromJson(batch)),
      ),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'batchs': batches.map((batch) => batch.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'limit': limit,
    'totalPages': totalPages,
  };

  bool get hasNextPage => page < totalPages;
}

class BatchListItem {
  final String id;
  final String userId;
  final String farmId;
  final Farm? farm;
  final String? houseId;
  final House? house;
  final String? deviceId;
  final dynamic device;
  final String? breed;
  final String batchName;
  final String birdTypeId;
  final String batchType;
  final BirdType? birdType;
  final String? age;
  final String? birdsAlive;
  final double? currentWeight;
  final double? expectedWeight;
  final String? feedingTime;
  final String? feedingSchedule;
  final int currentCount;
  final int initialCount;
  final String? hatchDate;
  final String? startDate;
  final String? expectedEndDate;
  final String? actualEndDate;
  final String currentStatus;
  final String? notes;
  final double? purchaseCost;
  final double? costPerBird;
  final String currency;
  final String? ageAtPurchase;
  final String? hatcherySource;
  final String? batchPhoto;
  final int totalMortality;
  final double mortalityRate;
  final int ageInDays;
  final String? ageLastUpdated;
  final String? purchaseExpenditureId;
  final String? deletedAt;
  final String? deletedBy;
  final String? deleteByDate;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MortalityStats? mortalityStats;

  BatchListItem({
    required this.id,
    required this.userId,
    required this.farmId,
    this.farm,
    this.houseId,
    this.house,
    this.deviceId,
    this.device,
    this.breed,
    required this.batchName,
    required this.birdTypeId,
    required this.batchType,
    this.birdType,
    this.age,
    this.birdsAlive,
    this.currentWeight,
    this.expectedWeight,
    this.feedingTime,
    this.feedingSchedule,
    required this.currentCount,
    required this.initialCount,
    this.hatchDate,
    this.startDate,
    this.expectedEndDate,
    this.actualEndDate,
    required this.currentStatus,
    this.notes,
    this.purchaseCost,
    this.costPerBird,
    required this.currency,
    this.ageAtPurchase,
    this.hatcherySource,
    this.batchPhoto,
    required this.totalMortality,
    required this.mortalityRate,
    required this.ageInDays,
    this.ageLastUpdated,
    this.purchaseExpenditureId,
    this.deletedAt,
    this.deletedBy,
    this.deleteByDate,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
    this.mortalityStats,
  });

  factory BatchListItem.fromJson(Map<String, dynamic> json) {
    return BatchListItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      farmId: json['farm_id'] as String,
      farm: json['farm'] != null ? Farm.fromJson(json['farm'] as Map<String, dynamic>) : null,
      houseId: json['house_id'] as String?,
      house: json['house'] != null ? House.fromJson(json['house'] as Map<String, dynamic>) : null,
      deviceId: json['device_id'] as String?,
      device: json['device'],
      breed: json['breed'] as String?,
      batchName: json['batch_name'] as String,
      birdTypeId: json['bird_type_id'] as String,
      batchType: json['batch_type'] as String,
      birdType: json['bird_type'] != null ? BirdType.fromJson(json['bird_type'] as Map<String, dynamic>) : null,
      age: json['age'] as String?,
      birdsAlive: json['birds_alive'] as String?,
      currentWeight: (json['current_weight'] as num?)?.toDouble(),
      expectedWeight: (json['expected_weight'] as num?)?.toDouble(),
      feedingTime: json['feeding_time'] as String?,
      feedingSchedule: json['feeding_schedule'] as String?,
      currentCount: (json['current_count'] as num?)?.toInt() ?? 0,
      initialCount: (json['initial_count'] as num?)?.toInt() ?? 0,
      hatchDate: json['hatch_date'] as String?,
      startDate: json['start_date'] as String?,
      expectedEndDate: json['expected_end_date'] as String?,
      actualEndDate: json['actual_end_date'] as String?,
      currentStatus: json['current_status'] as String,
      notes: json['notes'] as String?,
      purchaseCost: (json['purchase_cost'] as num?)?.toDouble(),
      costPerBird: (json['cost_per_bird'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      ageAtPurchase: json['age_at_purchase'] as String?,
      hatcherySource: json['hatchery_source'] as String?,
      batchPhoto: json['batch_photo'] as String?,
      totalMortality: (json['total_mortality'] as num?)?.toInt() ?? 0,
      mortalityRate: (json['mortality_rate'] as num?)?.toDouble() ?? 0.0,
      ageInDays: (json['age_in_days'] as num?)?.toInt() ?? 0,
      ageLastUpdated: json['age_last_updated'] as String?,
      purchaseExpenditureId: json['purchase_expenditure_id'] as String?,
      deletedAt: json['deleted_at'] as String?,
      deletedBy: json['deleted_by'] as String?,
      deleteByDate: json['delete_by_date'] as String?,
      deleted: (json['deleted'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      mortalityStats: json['mortality_stats'] != null
          ? MortalityStats.fromJson(json['mortality_stats'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'farm_id': farmId,
    'farm': farm?.toJson(),
    'house_id': houseId,
    'house': house?.toJson(),
    'device_id': deviceId,
    'device': device,
    'breed': breed,
    'batch_name': batchName,
    'bird_type_id': birdTypeId,
    'batch_type': batchType,
    'bird_type': birdType?.toJson(),
    'age': age,
    'birds_alive': birdsAlive,
    'current_weight': currentWeight,
    'expected_weight': expectedWeight,
    'feeding_time': feedingTime,
    'feeding_schedule': feedingSchedule,
    'current_count': currentCount,
    'initial_count': initialCount,
    'hatch_date': hatchDate,
    'start_date': startDate,
    'expected_end_date': expectedEndDate,
    'actual_end_date': actualEndDate,
    'current_status': currentStatus,
    'notes': notes,
    'purchase_cost': purchaseCost,
    'cost_per_bird': costPerBird,
    'currency': currency,
    'age_at_purchase': ageAtPurchase,
    'hatchery_source': hatcherySource,
    'batch_photo': batchPhoto,
    'total_mortality': totalMortality,
    'mortality_rate': mortalityRate,
    'age_in_days': ageInDays,
    'age_last_updated': ageLastUpdated,
    'purchase_expenditure_id': purchaseExpenditureId,
    'deleted_at': deletedAt,
    'deleted_by': deletedBy,
    'delete_by_date': deleteByDate,
    'deleted': deleted,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'mortality_stats': mortalityStats?.toJson(),
  };

  // Helper methods
  bool get isActive => currentStatus == 'active';
  bool get isCompleted => currentStatus == 'completed';
  double get utilizationPercentage => initialCount > 0 ? (currentCount / initialCount) * 100 : 0.0;
  double get survivalRate => initialCount > 0 ? (currentCount / initialCount) * 100 : 0.0;

  String get formattedAge {
    if (ageInDays >= 365) {
      final years = ageInDays ~/ 365;
      final remainingDays = ageInDays % 365;
      if (remainingDays > 0) {
        return '$years year${years > 1 ? 's' : ''}, $remainingDays day${remainingDays > 1 ? 's' : ''}';
      }
      return '$years year${years > 1 ? 's' : ''}';
    } else if (ageInDays >= 30) {
      final months = ageInDays ~/ 30;
      final remainingDays = ageInDays % 30;
      if (remainingDays > 0) {
        return '$months month${months > 1 ? 's' : ''}, $remainingDays day${remainingDays > 1 ? 's' : ''}';
      }
      return '$months month${months > 1 ? 's' : ''}';
    }
    return '$ageInDays day${ageInDays != 1 ? 's' : ''}';
  }
}

class Farm {
  final String id;
  final String userId;
  final String farmName;
  final dynamic location;
  final String totalArea;
  final String farmType;
  final String? description;
  final String? contactInfo;
  final bool isActive;
  final String? farmPhoto;
  final DateTime createdAt;
  final DateTime updatedAt;

  Farm({
    required this.id,
    required this.userId,
    required this.farmName,
    required this.location,
    required this.totalArea,
    required this.farmType,
    this.description,
    this.contactInfo,
    required this.isActive,
    this.farmPhoto,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      farmName: json['farm_name'] as String,
      location: json['location'],
      totalArea: json['total_area'] as String? ?? '0.00',
      farmType: json['farm_type'] as String,
      description: json['description'] as String?,
      contactInfo: json['contact_info'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      farmPhoto: json['farm_photo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'farm_name': farmName,
    'location': location,
    'total_area': totalArea,
    'farm_type': farmType,
    'description': description,
    'contact_info': contactInfo,
    'is_active': isActive,
    'farm_photo': farmPhoto,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Helper method to get location data
  Map<String, dynamic>? get parsedLocation {
    if (location is String) {
      try {
        return jsonDecode(location as String) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    } else if (location is Map<String, dynamic>) {
      return location as Map<String, dynamic>;
    }
    return null;
  }
}

class House {
  final String id;
  final String userId;
  final String farmId;
  final String name;
  final int maximumCapacity;
  final int minimumCapacity;
  final String? description;
  final dynamic meta;
  final bool isActive;
  final String? housePhoto;
  final int currentOccupancy;
  final double utilizationPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  House({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.name,
    required this.maximumCapacity,
    required this.minimumCapacity,
    this.description,
    this.meta,
    required this.isActive,
    this.housePhoto,
    required this.currentOccupancy,
    required this.utilizationPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      farmId: json['farm_id'] as String,
      name: json['name'] as String,
      maximumCapacity: (json['maximum_capacity'] as num?)?.toInt() ?? 0,
      minimumCapacity: (json['minimum_capacity'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      meta: json['meta'],
      isActive: (json['is_active'] as bool?) ?? true,
      housePhoto: json['house_photo'] as String?,
      currentOccupancy: (json['current_occupancy'] as num?)?.toInt() ?? 0,
      utilizationPercentage: (json['utilization_percentage'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'farm_id': farmId,
    'name': name,
    'maximum_capacity': maximumCapacity,
    'minimum_capacity': minimumCapacity,
    'description': description,
    'meta': meta,
    'is_active': isActive,
    'house_photo': housePhoto,
    'current_occupancy': currentOccupancy,
    'utilization_percentage': utilizationPercentage,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class BirdType {
  final String id;
  final String name;
  final String type;
  final String description;
  final int maturityDays;
  final String dayOldChickPrice;
  final String expectedSellingPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BirdType({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.maturityDays,
    required this.dayOldChickPrice,
    required this.expectedSellingPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BirdType.fromJson(Map<String, dynamic> json) {
    return BirdType(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      maturityDays: (json['maturity_days'] as num?)?.toInt() ?? 0,
      dayOldChickPrice: json['day_old_chick_price'] as String? ?? '0.00',
      expectedSellingPrice: json['expected_selling_price'] as String? ?? '0.00',
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'description': description,
    'maturity_days': maturityDays,
    'day_old_chick_price': dayOldChickPrice,
    'expected_selling_price': expectedSellingPrice,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class MortalityStats {
  final int initialCount;
  final int currentCount;
  final String? birdsAlive;
  final int totalDeaths;
  final double mortalityRate;
  final double survivalRate;
  final int recentDeaths7days;
  final double recentDailyMortalityAvg;
  final String? lastMortalityDate;

  MortalityStats({
    required this.initialCount,
    required this.currentCount,
    this.birdsAlive,
    required this.totalDeaths,
    required this.mortalityRate,
    required this.survivalRate,
    required this.recentDeaths7days,
    required this.recentDailyMortalityAvg,
    this.lastMortalityDate,
  });

  factory MortalityStats.fromJson(Map<String, dynamic> json) {
    return MortalityStats(
      initialCount: (json['initial_count'] as num?)?.toInt() ?? 0,
      currentCount: (json['current_count'] as num?)?.toInt() ?? 0,
      birdsAlive: json['birds_alive'] as String?,
      totalDeaths: (json['total_deaths'] as num?)?.toInt() ?? 0,
      mortalityRate: (json['mortality_rate'] as num?)?.toDouble() ?? 0.0,
      survivalRate: (json['survival_rate'] as num?)?.toDouble() ?? 0.0,
      recentDeaths7days: (json['recent_deaths_7days'] as num?)?.toInt() ?? 0,
      recentDailyMortalityAvg: (json['recent_daily_mortality_avg'] as num?)?.toDouble() ?? 0.0,
      lastMortalityDate: json['last_mortality_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'initial_count': initialCount,
    'current_count': currentCount,
    'birds_alive': birdsAlive,
    'total_deaths': totalDeaths,
    'mortality_rate': mortalityRate,
    'survival_rate': survivalRate,
    'recent_deaths_7days': recentDeaths7days,
    'recent_daily_mortality_avg': recentDailyMortalityAvg,
    'last_mortality_date': lastMortalityDate,
  };
}