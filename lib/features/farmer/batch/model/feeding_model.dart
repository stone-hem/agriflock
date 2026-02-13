import 'dart:convert';
import 'package:agriflock360/core/utils/type_safe_utils.dart'; // Adjust the import path as needed

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
    final birdTypeMap = TypeUtils.toMapSafe(json['bird_type']);
    return FeedingRecommendation(
      id: TypeUtils.toStringSafe(json['id']),
      birdTypeId: TypeUtils.toStringSafe(json['bird_type_id']),
      birdType: birdTypeMap != null ? BirdType.fromJson(birdTypeMap) : null,
      stageName: TypeUtils.toStringSafe(json['stage_name']),
      ageStart: TypeUtils.toIntSafe(json['age_start']),
      ageEnd: TypeUtils.toIntSafe(json['age_end']),
      feedType: TypeUtils.toStringSafe(json['feed_type']),
      proteinPercentage: TypeUtils.toStringSafe(json['protein_percentage']),
      quantityPerBirdPerDay: TypeUtils.toStringSafe(json['quantity_per_bird_per_day']),
      timesPerDay: TypeUtils.toIntSafe(json['times_per_day']),
      feedingTimes: FeedingTimes.fromJson(TypeUtils.toMapSafe(json['feeding_times']) ?? {}),
      notes: TypeUtils.toNullableStringSafe(json['notes']),
      supplements: TypeUtils.toNullableStringSafe(json['supplements']),
      isActive: TypeUtils.toBoolSafe(json['is_active']),
      isSystemDefault: TypeUtils.toBoolSafe(json['is_system_default']),
      metadata: TypeUtils.toMapSafe(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
      dailyFeedRequiredKg: TypeUtils.toNullableDoubleSafe(json['daily_feed_required_kg']),
      costEstimate: TypeUtils.toNullableDoubleSafe(json['cost_estimate']),
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
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      category: TypeUtils.toNullableStringSafe(json['category']),
      description: TypeUtils.toNullableStringSafe(json['description']),
      notes: TypeUtils.toNullableStringSafe(json['notes']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
    );
  }
}

class FeedingTimes {
  final List<String> slots;

  FeedingTimes({required this.slots});

  factory FeedingTimes.fromJson(Map<String, dynamic> json) {
    return FeedingTimes(
      slots: TypeUtils.toListSafe<String>(json['slots']),
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
      id: TypeUtils.toStringSafe(json['id']),
      ageDays: TypeUtils.toIntSafe(json['age_days']),
      currentCount: TypeUtils.toIntSafe(json['current_count']),
      birdType: TypeUtils.toStringSafe(json['bird_type']),
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
    final data = TypeUtils.toMapSafe(json['data']) ?? {};

    // Handle current_recommendation - create dummy if empty
    FeedingRecommendation currentRec;
    dynamic currentRecData = data['current_recommendation'];
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
      allRecommendations: TypeUtils.toListSafe<Map<String, dynamic>>(data['all_recommendations'])
          .map((item) => FeedingRecommendation.fromJson(item))
          .toList(),
      batchInfo: BatchInfo.fromJson(TypeUtils.toMapSafe(data['batch_info']) ?? {}),
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
      id: TypeUtils.toStringSafe(json['id']),
      batchId: TypeUtils.toStringSafe(json['batch_id']),
      scheduleId: TypeUtils.toNullableStringSafe(json['schedule_id']),
      age: TypeUtils.toIntSafe(json['age']),
      feedType: TypeUtils.toStringSafe(json['feed_type']),
      quantity: TypeUtils.toStringSafe(json['quantity']),
      cost: TypeUtils.toStringSafe(json['cost']),
      supplier: TypeUtils.toStringSafe(json['supplier']),
      fedAt: TypeUtils.toDateTimeSafe(json['fed_at']) ?? DateTime.now(),
      recordedBy: TypeUtils.toStringSafe(json['recorded_by']),
      notes: TypeUtils.toNullableStringSafe(json['notes']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
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
      records: TypeUtils.toListSafe<Map<String, dynamic>>(json['data'])
          .map((item) => FeedingRecord.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(TypeUtils.toMapSafe(json['pagination']) ?? {}),
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
      total: TypeUtils.toIntSafe(json['total']),
      page: TypeUtils.toIntSafe(json['page']),
      limit: TypeUtils.toIntSafe(json['limit']),
      totalPages: TypeUtils.toIntSafe(json['totalPages']),
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
      id: TypeUtils.toStringSafe(json['id']),
      amountKg: TypeUtils.toStringSafe(json['amount_kg']),
      time: TypeUtils.toStringSafe(json['time']),
      date: TypeUtils.toStringSafe(json['date']),
      dayLabel: TypeUtils.toStringSafe(json['dayLabel']),
      compliancePercentage: TypeUtils.toIntSafe(json['compliance_percentage']),
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
      dailyConsumptionKg: TypeUtils.toStringSafe(json['daily_consumption_kg']),
      weeklyTotalKg: TypeUtils.toStringSafe(json['weekly_total_kg']),
      avgPerBirdKg: TypeUtils.toStringSafe(json['avg_per_bird_kg']),
      fcrStatus: TypeUtils.toStringSafe(json['fcr_status']),
      totalBirds: TypeUtils.toIntSafe(json['total_birds']),
      batchName: TypeUtils.toStringSafe(json['batch_name']),
      recentFeedings: TypeUtils.toListSafe<Map<String, dynamic>>(json['recent_feedings'])
          .map((item) => RecentFeeding.fromJson(item))
          .toList(),
    );
  }
}