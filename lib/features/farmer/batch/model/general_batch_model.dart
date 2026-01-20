class GeneralBatchModel  {
  final String id;
  final String userId;
  final String farmId;
  final Farm? farm;
  final String? houseId;
  final House? house;
  final String? deviceId;
  final dynamic device;
  final dynamic breed;
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
  final DateTime? hatchDate;
  final DateTime? startDate;
  final DateTime? expectedEndDate;
  final DateTime? actualEndDate;
  final String currentStatus;
  final String? notes;
  final double? purchaseCost;
  final double? costPerBird;
  final String currency;
  final int? ageAtPurchase;
  final String? batchPhoto;
  final int totalMortality;
  final double mortalityRate;
  final int ageInDays;
  final DateTime? ageLastUpdated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MortalityStats? mortalityStats;

  const GeneralBatchModel({
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
    this.batchPhoto,
    required this.totalMortality,
    required this.mortalityRate,
    required this.ageInDays,
    this.ageLastUpdated,
    required this.createdAt,
    required this.updatedAt,
    this.mortalityStats,
  });

  factory GeneralBatchModel.fromJson(Map<String, dynamic> json) {
    return GeneralBatchModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      farm: json['farm'] != null ? Farm.fromJson(json['farm']) : null,
      houseId: json['house_id'] as String?,
      house: json['house'] != null ? House.fromJson(json['house']) : null,
      deviceId: json['device_id'] as String?,
      device: json['device'],
      breed: json['breed'],
      batchName: json['batch_name'] as String? ?? '',
      birdTypeId: json['bird_type_id'] as String? ?? '',
      batchType: json['batch_type'] as String? ?? '',
      birdType: json['bird_type'] != null ? BirdType.fromJson(json['bird_type']) : null,
      age: json['age'] as String?,
      birdsAlive: json['birds_alive'] as String?,
      currentWeight: json['current_weight'] != null ? double.tryParse(json['current_weight'].toString()) : null,
      expectedWeight: json['expected_weight'] != null ? double.tryParse(json['expected_weight'].toString()) : null,
      feedingTime: json['feeding_time'] as String?,
      feedingSchedule: json['feeding_schedule'] as String?,
      currentCount: json['current_count'] as int? ?? 0,
      initialCount: json['initial_count'] as int? ?? 0,
      hatchDate: json['hatch_date'] != null ? DateTime.parse(json['hatch_date'] as String) : null,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
      expectedEndDate: json['expected_end_date'] != null ? DateTime.parse(json['expected_end_date'] as String) : null,
      actualEndDate: json['actual_end_date'] != null ? DateTime.parse(json['actual_end_date'] as String) : null,
      currentStatus: json['current_status'] as String? ?? 'active',
      notes: json['notes'] as String?,
      purchaseCost: json['purchase_cost'] != null ? double.tryParse(json['purchase_cost'].toString()) : null,
      costPerBird: json['cost_per_bird'] != null ? double.tryParse(json['cost_per_bird'].toString()) : null,
      currency: json['currency'] as String? ?? 'KES',
      ageAtPurchase: json['age_at_purchase'] as int?,
      batchPhoto: json['batch_photo'] as String?,
      totalMortality: json['total_mortality'] as int? ?? 0,
      mortalityRate: json['mortality_rate'] != null ? double.parse(json['mortality_rate'].toString()) : 0.0,
      ageInDays: json['age_in_days'] as int? ?? 0,
      ageLastUpdated: json['age_last_updated'] != null ? DateTime.parse(json['age_last_updated'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      mortalityStats: json['mortality_stats'] != null ? MortalityStats.fromJson(json['mortality_stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'hatch_date': hatchDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'expected_end_date': expectedEndDate?.toIso8601String(),
      'actual_end_date': actualEndDate?.toIso8601String(),
      'current_status': currentStatus,
      'notes': notes,
      'purchase_cost': purchaseCost,
      'cost_per_bird': costPerBird,
      'currency': currency,
      'age_at_purchase': ageAtPurchase,
      'batch_photo': batchPhoto,
      'total_mortality': totalMortality,
      'mortality_rate': mortalityRate,
      'age_in_days': ageInDays,
      'age_last_updated': ageLastUpdated?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'mortality_stats': mortalityStats?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    farmId,
    farm,
    houseId,
    house,
    deviceId,
    device,
    breed,
    batchName,
    birdTypeId,
    batchType,
    birdType,
    age,
    birdsAlive,
    currentWeight,
    expectedWeight,
    feedingTime,
    feedingSchedule,
    currentCount,
    initialCount,
    hatchDate,
    startDate,
    expectedEndDate,
    actualEndDate,
    currentStatus,
    notes,
    purchaseCost,
    costPerBird,
    currency,
    ageAtPurchase,
    batchPhoto,
    totalMortality,
    mortalityRate,
    ageInDays,
    ageLastUpdated,
    createdAt,
    updatedAt,
    mortalityStats,
  ];
}

class Farm  {
  final String id;
  final String userId;
  final String farmName;
  final String? location;
  final String totalArea;
  final String farmType;
  final String? description;
  final dynamic contactInfo;
  final bool isActive;
  final String? farmPhoto;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Farm({
    required this.id,
    required this.userId,
    required this.farmName,
    this.location,
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
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      farmName: json['farm_name'] as String? ?? '',
      location: json['location'] as String?,
      totalArea: json['total_area'] as String? ?? '0.00',
      farmType: json['farm_type'] as String? ?? '',
      description: json['description'] as String?,
      contactInfo: json['contact_info'],
      isActive: json['is_active'] as bool? ?? true,
      farmPhoto: json['farm_photo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    farmName,
    location,
    totalArea,
    farmType,
    description,
    contactInfo,
    isActive,
    farmPhoto,
    createdAt,
    updatedAt,
  ];
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

  const House({
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
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      maximumCapacity: json['maximum_capacity'] as int? ?? 0,
      minimumCapacity: json['minimum_capacity'] as int? ?? 0,
      description: json['description'] as String?,
      meta: json['meta'],
      isActive: json['is_active'] as bool? ?? true,
      housePhoto: json['house_photo'] as String?,
      currentOccupancy: json['current_occupancy'] as int? ?? 0,
      utilizationPercentage: json['utilization_percentage'] != null ? double.parse(json['utilization_percentage'].toString()) : 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  @override
  List<Object?> get props => [
    id,
    userId,
    farmId,
    name,
    maximumCapacity,
    minimumCapacity,
    description,
    meta,
    isActive,
    housePhoto,
    currentOccupancy,
    utilizationPercentage,
    createdAt,
    updatedAt,
  ];
}

class BirdType {
  final String id;
  final String name;
  final String type;
  final String? description;
  final int maturityDays;
  final String dayOldChickPrice;
  final String expectedSellingPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BirdType({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.maturityDays,
    required this.dayOldChickPrice,
    required this.expectedSellingPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BirdType.fromJson(Map<String, dynamic> json) {
    return BirdType(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      description: json['description'] as String?,
      maturityDays: json['maturity_days'] as int? ?? 0,
      dayOldChickPrice: json['day_old_chick_price'] as String? ?? '0.00',
      expectedSellingPrice: json['expected_selling_price'] as String? ?? '0.00',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    description,
    maturityDays,
    dayOldChickPrice,
    expectedSellingPrice,
    isActive,
    createdAt,
    updatedAt,
  ];
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
  final DateTime? lastMortalityDate;

  const MortalityStats({
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
      initialCount: json['initial_count'] as int? ?? 0,
      currentCount: json['current_count'] as int? ?? 0,
      birdsAlive: json['birds_alive'] as String?,
      totalDeaths: json['total_deaths'] as int? ?? 0,
      mortalityRate: json['mortality_rate'] != null ? double.parse(json['mortality_rate'].toString()) : 0.0,
      survivalRate: json['survival_rate'] != null ? double.parse(json['survival_rate'].toString()) : 0.0,
      recentDeaths7days: json['recent_deaths_7days'] as int? ?? 0,
      recentDailyMortalityAvg: json['recent_daily_mortality_avg'] != null ? double.parse(json['recent_daily_mortality_avg'].toString()) : 0.0,
      lastMortalityDate: json['last_mortality_date'] != null ? DateTime.parse(json['last_mortality_date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initial_count': initialCount,
      'current_count': currentCount,
      'birds_alive': birdsAlive,
      'total_deaths': totalDeaths,
      'mortality_rate': mortalityRate,
      'survival_rate': survivalRate,
      'recent_deaths_7days': recentDeaths7days,
      'recent_daily_mortality_avg': recentDailyMortalityAvg,
      'last_mortality_date': lastMortalityDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    initialCount,
    currentCount,
    birdsAlive,
    totalDeaths,
    mortalityRate,
    survivalRate,
    recentDeaths7days,
    recentDailyMortalityAvg,
    lastMortalityDate,
  ];
}

class GeneralBatchesResponse {
  final List<GeneralBatchModel> batches;
  final GeneralBatchPagination pagination;

  const GeneralBatchesResponse({
    required this.batches,
    required this.pagination,
  });

  factory GeneralBatchesResponse.fromJson(Map<String, dynamic> json) {
    final batches = (json['batches'] as List<dynamic>?)
        ?.map((item) => GeneralBatchModel.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    return GeneralBatchesResponse(
      batches: batches,
      pagination: GeneralBatchPagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batches': batches.map((batch) => batch.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class GeneralBatchPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const GeneralBatchPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory GeneralBatchPagination.fromJson(Map<String, dynamic> json) {
    return GeneralBatchPagination(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}