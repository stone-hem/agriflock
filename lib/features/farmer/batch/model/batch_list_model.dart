import 'dart:convert';

import 'package:agriflock360/core/utils/type_safe_utils.dart';


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
            .map((batch) => BatchListItem.fromJson(batch as Map<String, dynamic>)),
      ),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
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
      total: TypeUtils.toIntSafe(json['total']),
      page: TypeUtils.toIntSafe(json['page'], defaultValue: 1),
      limit: TypeUtils.toIntSafe(json['limit'], defaultValue: 20),
      totalPages: TypeUtils.toIntSafe(json['totalPages'], defaultValue: 1),
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
  final String batchNumber;
  final String birdTypeId;
  final String batchType;
  final BirdType? birdType;
  final String? age;
  final int? birdsAlive; // Changed to int? to match your data
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
    required this.batchNumber,
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
    final farmMap = TypeUtils.toMapSafe(json['farm']);
    final houseMap = TypeUtils.toMapSafe(json['house']);
    final birdTypeMap = TypeUtils.toMapSafe(json['bird_type']);
    final mortalityStatsMap = TypeUtils.toMapSafe(json['mortality_stats']);

    return BatchListItem(
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      farmId: TypeUtils.toStringSafe(json['farm_id']),
      farm: farmMap != null ? Farm.fromJson(farmMap) : null,
      houseId: TypeUtils.toNullableStringSafe(json['house_id']),
      house: houseMap != null ? House.fromJson(houseMap) : null,
      deviceId: TypeUtils.toNullableStringSafe(json['device_id']),
      device: TypeUtils.toMapSafe(json['device']), // or however device is typed
      breed: TypeUtils.toNullableStringSafe(json['breed']),
      batchNumber: TypeUtils.toStringSafe(json['batch_number']),
      birdTypeId: TypeUtils.toStringSafe(json['bird_type_id']),
      batchType: TypeUtils.toStringSafe(json['batch_type']),
      birdType: birdTypeMap != null ? BirdType.fromJson(birdTypeMap) : null,
      age: TypeUtils.toNullableStringSafe(json['age']),
      birdsAlive: TypeUtils.toNullableIntSafe(json['birds_alive']),     // simplified
      currentWeight: TypeUtils.toNullableDoubleSafe(json['current_weight']),
      expectedWeight: TypeUtils.toNullableDoubleSafe(json['expected_weight']),
      feedingTime: TypeUtils.toNullableStringSafe(json['feeding_time']),
      feedingSchedule: TypeUtils.toNullableStringSafe(json['feeding_schedule']),
      currentCount: TypeUtils.toIntSafe(json['current_count']),
      initialCount: TypeUtils.toIntSafe(json['initial_count']),
      hatchDate: TypeUtils.toDateStringSafe(json['hatch_date']),
      startDate: TypeUtils.toDateStringSafe(json['start_date']),
      expectedEndDate: TypeUtils.toDateStringSafe(json['expected_end_date']),
      actualEndDate: TypeUtils.toDateStringSafe(json['actual_end_date']),
      currentStatus: TypeUtils.toStringSafe(json['current_status'], defaultValue: 'unknown'),
      notes: TypeUtils.toNullableStringSafe(json['notes']),
      purchaseCost: TypeUtils.toNullableDoubleSafe(json['purchase_cost']),
      costPerBird: TypeUtils.toNullableDoubleSafe(json['cost_per_bird']),
      currency: TypeUtils.toStringSafe(json['currency'], defaultValue: 'KES'),
      ageAtPurchase: TypeUtils.toNullableStringSafe(json['age_at_purchase']),
      hatcherySource: TypeUtils.toNullableStringSafe(json['hatchery_source']),
      batchPhoto: TypeUtils.toNullableStringSafe(json['batch_photo']),
      totalMortality: TypeUtils.toIntSafe(json['total_mortality']),
      mortalityRate: TypeUtils.toDoubleSafe(json['mortality_rate']),
      ageInDays: TypeUtils.toIntSafe(json['age_in_days']),
      ageLastUpdated: TypeUtils.toDateStringSafe(json['age_last_updated']),
      purchaseExpenditureId: TypeUtils.toNullableStringSafe(json['purchase_expenditure_id']),
      deletedAt: TypeUtils.toDateStringSafe(json['deleted_at']),
      deletedBy: TypeUtils.toNullableStringSafe(json['deleted_by']),
      deleteByDate: TypeUtils.toDateStringSafe(json['delete_by_date']),
      deleted: TypeUtils.toBoolSafe(json['deleted']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
      mortalityStats: mortalityStatsMap != null
          ? MortalityStats.fromJson(mortalityStatsMap)
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
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      farmName: TypeUtils.toStringSafe(json['farm_name']),
      location: json['location'],
      totalArea: TypeUtils.toStringSafe(json['total_area'], defaultValue: '0.00'),
      farmType: TypeUtils.toStringSafe(json['farm_type']),
      description: TypeUtils.toNullableStringSafe(json['description'], defaultValue: null),
      contactInfo: TypeUtils.toNullableStringSafe(json['contact_info'], defaultValue: null),
      isActive: TypeUtils.toBoolSafe(json['is_active'], defaultValue: true),
      farmPhoto: TypeUtils.toNullableStringSafe(json['farm_photo'], defaultValue: null),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
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
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      farmId: TypeUtils.toStringSafe(json['farm_id']),
      name: TypeUtils.toStringSafe(json['name']),
      maximumCapacity: TypeUtils.toIntSafe(json['maximum_capacity']),
      minimumCapacity: TypeUtils.toIntSafe(json['minimum_capacity']),
      description: TypeUtils.toNullableStringSafe(json['description'], defaultValue: null),
      meta: json['meta'],
      isActive: TypeUtils.toBoolSafe(json['is_active'], defaultValue: true),
      housePhoto: TypeUtils.toNullableStringSafe(json['house_photo'], defaultValue: null),
      currentOccupancy: TypeUtils.toIntSafe(json['current_occupancy']),
      utilizationPercentage: TypeUtils.toDoubleSafe(json['utilization_percentage']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
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
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      type: TypeUtils.toStringSafe(json['type']),
      description: TypeUtils.toStringSafe(json['description']),
      maturityDays: TypeUtils.toIntSafe(json['maturity_days']),
      dayOldChickPrice: TypeUtils.toStringSafe(json['day_old_chick_price'], defaultValue: '0.00'),
      expectedSellingPrice: TypeUtils.toStringSafe(json['expected_selling_price'], defaultValue: '0.00'),
      isActive: TypeUtils.toBoolSafe(json['is_active'], defaultValue: true),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
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
  final int? birdsAlive; // Changed to int?
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
      initialCount: TypeUtils.toIntSafe(json['initial_count']),
      currentCount: TypeUtils.toIntSafe(json['current_count']),
      birdsAlive: json['birds_alive'] != null ? TypeUtils.toIntSafe(json['birds_alive']) : null,
      totalDeaths: TypeUtils.toIntSafe(json['total_deaths']),
      mortalityRate: TypeUtils.toDoubleSafe(json['mortality_rate']),
      survivalRate: TypeUtils.toDoubleSafe(json['survival_rate']),
      recentDeaths7days: TypeUtils.toIntSafe(json['recent_deaths_7days']),
      recentDailyMortalityAvg: TypeUtils.toDoubleSafe(json['recent_daily_mortality_avg']),
      lastMortalityDate: TypeUtils.toNullableStringSafe(json['last_mortality_date'], defaultValue: null),
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