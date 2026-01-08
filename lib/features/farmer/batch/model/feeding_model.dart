// lib/features/farmer/batch/model/feeding_model.dart

class FeedingRecommendation {
  final String id;
  final String birdTypeId;
  final BirdType? birdType;
  final String stageName;
  final int ageStart;
  final int ageEnd;
  final String feedType;
  final String proteinPercentage;
  final String quantityPerBirdPerDay;
  final int timesPerDay;
  final FeedingTimes feedingTimes;
  final String? notes;
  final String? supplements;
  final bool isActive;
  final bool isSystemDefault;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? dailyFeedRequiredKg;
  final double? costEstimate;

  FeedingRecommendation({
    required this.id,
    required this.birdTypeId,
    this.birdType,
    required this.stageName,
    required this.ageStart,
    required this.ageEnd,
    required this.feedType,
    required this.proteinPercentage,
    required this.quantityPerBirdPerDay,
    required this.timesPerDay,
    required this.feedingTimes,
    this.notes,
    this.supplements,
    required this.isActive,
    required this.isSystemDefault,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.dailyFeedRequiredKg,
    this.costEstimate,
  });

  factory FeedingRecommendation.fromJson(Map<String, dynamic> json) {
    return FeedingRecommendation(
      id: json['id'],
      birdTypeId: json['bird_type_id'],
      birdType: json['bird_type'] != null
          ? BirdType.fromJson(json['bird_type'])
          : null,
      stageName: json['stage_name'],
      ageStart: json['age_start'],
      ageEnd: json['age_end'],
      feedType: json['feed_type'],
      proteinPercentage: json['protein_percentage'],
      quantityPerBirdPerDay: json['quantity_per_bird_per_day'],
      timesPerDay: json['times_per_day'],
      feedingTimes: FeedingTimes.fromJson(json['feeding_times']),
      notes: json['notes'],
      supplements: json['supplements'],
      isActive: json['is_active'],
      isSystemDefault: json['is_system_default'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      dailyFeedRequiredKg: json['daily_feed_required_kg']?.toDouble(),
      costEstimate: json['cost_estimate']?.toDouble(),
    );
  }
}

class BirdType {
  final String id;
  final String name;
  final String? category;
  final String? description;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BirdType({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BirdType.fromJson(Map<String, dynamic> json) {
    return BirdType(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class FeedingTimes {
  final List<String> slots;

  FeedingTimes({required this.slots});

  factory FeedingTimes.fromJson(Map<String, dynamic> json) {
    return FeedingTimes(
      slots: List<String>.from(json['slots']),
    );
  }
}

class BatchInfo {
  final String id;
  final int ageDays;
  final int currentCount;
  final String birdType;

  BatchInfo({
    required this.id,
    required this.ageDays,
    required this.currentCount,
    required this.birdType,
  });

  factory BatchInfo.fromJson(Map<String, dynamic> json) {
    return BatchInfo(
      id: json['id'],
      ageDays: json['age_days'],
      currentCount: json['current_count'],
      birdType: json['bird_type'],
    );
  }
}

class FeedingRecommendationsResponse {
  final FeedingRecommendation currentRecommendation;
  final List<FeedingRecommendation> allRecommendations;
  final BatchInfo batchInfo;

  FeedingRecommendationsResponse({
    required this.currentRecommendation,
    required this.allRecommendations,
    required this.batchInfo,
  });

  factory FeedingRecommendationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    // Handle current_recommendation - create dummy if empty
    FeedingRecommendation currentRec;
    final currentRecData = data['current_recommendation'];

    if (currentRecData is Map<String, dynamic>) {
      currentRec = FeedingRecommendation.fromJson(currentRecData);
    } else if (currentRecData is List && currentRecData.isNotEmpty) {
      final firstItem = currentRecData.first;
      if (firstItem is Map<String, dynamic>) {
        currentRec = FeedingRecommendation.fromJson(firstItem);
      } else {
        currentRec = _createEmptyRecommendation();
      }
    } else {
      currentRec = _createEmptyRecommendation();
    }

    return FeedingRecommendationsResponse(
      currentRecommendation: currentRec,
      allRecommendations: (data['all_recommendations'] as List)
          .map((item) => FeedingRecommendation.fromJson(item))
          .toList(),
      batchInfo: BatchInfo.fromJson(data['batch_info']),
    );
  }

  static FeedingRecommendation _createEmptyRecommendation() {
    return FeedingRecommendation(
      id: 'no-recommendation',
      birdTypeId: '',
      stageName: 'No recommendation available',
      ageStart: 0,
      ageEnd: 0,
      feedType: 'N/A',
      proteinPercentage: 'N/A',
      quantityPerBirdPerDay: 'N/A',
      timesPerDay: 0,
      feedingTimes: FeedingTimes(slots: []),
      isActive: false,
      isSystemDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class FeedingRecord {
  final String id;
  final String batchId;
  final String? scheduleId;
  final int age;
  final String feedType;
  final String quantity;
  final String cost;
  final String supplier;
  final DateTime fedAt;
  final String recordedBy;
  final String? notes;
  final DateTime createdAt;

  FeedingRecord({
    required this.id,
    required this.batchId,
    this.scheduleId,
    required this.age,
    required this.feedType,
    required this.quantity,
    required this.cost,
    required this.supplier,
    required this.fedAt,
    required this.recordedBy,
    this.notes,
    required this.createdAt,
  });

  factory FeedingRecord.fromJson(Map<String, dynamic> json) {
    return FeedingRecord(
      id: json['id'],
      batchId: json['batch_id'],
      scheduleId: json['schedule_id'],
      age: json['age'],
      feedType: json['feed_type'],
      quantity: json['quantity'],
      cost: json['cost'],
      supplier: json['supplier'],
      fedAt: DateTime.parse(json['fed_at']),
      recordedBy: json['recorded_by'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class FeedingRecordsResponse {
  final List<FeedingRecord> records;
  final Pagination pagination;

  FeedingRecordsResponse({
    required this.records,
    required this.pagination,
  });

  factory FeedingRecordsResponse.fromJson(Map<String, dynamic> json) {
    return FeedingRecordsResponse(
      records: (json['data'] as List)
          .map((item) => FeedingRecord.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
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
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
    );
  }
}

class RecentFeeding {
  final String id;
  final String amountKg;
  final String time;
  final String date;
  final String dayLabel;
  final int compliancePercentage;

  RecentFeeding({
    required this.id,
    required this.amountKg,
    required this.time,
    required this.date,
    required this.dayLabel,
    required this.compliancePercentage,
  });

  factory RecentFeeding.fromJson(Map<String, dynamic> json) {
    return RecentFeeding(
      id: json['id'],
      amountKg: json['amount_kg'],
      time: json['time'],
      date: json['date'],
      dayLabel: json['dayLabel'],
      compliancePercentage: json['compliance_percentage'],
    );
  }
}

class FeedDashboard {
  final String dailyConsumptionKg;
  final String weeklyTotalKg;
  final String avgPerBirdKg;
  final String fcrStatus;
  final int totalBirds;
  final String batchName;
  final List<RecentFeeding> recentFeedings;

  FeedDashboard({
    required this.dailyConsumptionKg,
    required this.weeklyTotalKg,
    required this.avgPerBirdKg,
    required this.fcrStatus,
    required this.totalBirds,
    required this.batchName,
    required this.recentFeedings,
  });

  factory FeedDashboard.fromJson(Map<String, dynamic> json) {
    return FeedDashboard(
      dailyConsumptionKg: json['daily_consumption_kg'],
      weeklyTotalKg: json['weekly_total_kg'],
      avgPerBirdKg: json['avg_per_bird_kg'],
      fcrStatus: json['fcr_status'],
      totalBirds: json['total_birds'],
      batchName: json['batch_name'],
      recentFeedings: (json['recent_feedings'] as List)
          .map((item) => RecentFeeding.fromJson(item))
          .toList(),
    );
  }
}

class CreateFeedingRecordRequest {
  final int age;
  final String feedType;
  final double quantity;
  final double cost;
  final String supplier;
  final DateTime fedAt;
  final String? notes;
  final int? birdsAliveBefore;
  final int? mortalityToday;
  final double? currentTotalWeight;
  final double? expectedWeight;

  CreateFeedingRecordRequest({
    required this.age,
    required this.feedType,
    required this.quantity,
    required this.cost,
    required this.supplier,
    required this.fedAt,
    this.notes,
    this.birdsAliveBefore,
    this.mortalityToday,
    this.currentTotalWeight,
    this.expectedWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'feed_type': feedType,
      'quantity': quantity,
      'cost': cost,
      'supplier': supplier,
      'fed_at': fedAt.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (birdsAliveBefore != null) 'birds_alive_before': birdsAliveBefore,
      if (mortalityToday != null) 'mortality_today': mortalityToday,
      if (currentTotalWeight != null) 'current_total_weight': currentTotalWeight,
      if (expectedWeight != null) 'expected_weight': expectedWeight,
    };
  }
}