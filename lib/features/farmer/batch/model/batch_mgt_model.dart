import 'package:agriflock360/core/utils/type_safe_utils.dart';

class BatchMgtResponse {
  final BatchInfo batch;
  final List<RecentActivity> recentActivities;
  final BatchStats stats;
  final FinancialStats financialStats;

  const BatchMgtResponse({
    required this.batch,
    required this.recentActivities,
    required this.stats,
    required this.financialStats,
  });

  factory BatchMgtResponse.fromJson(Map<String, dynamic> json) {
    return BatchMgtResponse(
      batch: BatchInfo.fromJson(TypeUtils.toMapSafe(json['batch']) ?? {}),
      recentActivities: TypeUtils.toListSafe<Map<String, dynamic>>(json['recent_activities'])
          .map((activity) => RecentActivity.fromJson(activity))
          .toList(),
      stats: BatchStats.fromJson(TypeUtils.toMapSafe(json['stats']) ?? {}),
      financialStats: FinancialStats.fromJson(TypeUtils.toMapSafe(json['financial_stats']) ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch': batch.toJson(),
      'recent_activities': recentActivities.map((a) => a.toJson()).toList(),
      'stats': stats.toJson(),
      'financial_stats': financialStats.toJson(),
    };
  }
}

class BatchInfo {
  final String id;
  final String batchNumber;
  final String breed;
  final String status;
  final String statusLabel;
  final int totalBirds;
  final String liveBirds;
  final int mortalityCount;
  final num mortalityRate;
  final int ageDays;
  final String startDate;
  final String houseName;
  final String farmName;

  const BatchInfo({
    required this.id,
    required this.batchNumber,
    required this.breed,
    required this.status,
    required this.statusLabel,
    required this.totalBirds,
    required this.liveBirds,
    required this.mortalityCount,
    required this.mortalityRate,
    required this.ageDays,
    required this.startDate,
    required this.houseName,
    required this.farmName,
  });

  factory BatchInfo.fromJson(Map<String, dynamic> json) {
    return BatchInfo(
      id: TypeUtils.toStringSafe(json['id']),
      batchNumber: TypeUtils.toStringSafe(json['batch_number']??json['name']),
      breed: TypeUtils.toStringSafe(json['breed']),
      status: TypeUtils.toStringSafe(json['status']),
      statusLabel: TypeUtils.toStringSafe(json['statusLabel']),
      totalBirds: TypeUtils.toIntSafe(json['total_birds']),
      liveBirds: TypeUtils.toStringSafe(json['live_birds']),
      mortalityCount: TypeUtils.toIntSafe(json['mortality_count']),
      mortalityRate: TypeUtils.toDoubleSafe(json['mortality_rate']),
      ageDays: TypeUtils.toIntSafe(json['age_days']),
      startDate: TypeUtils.toDateStringSafe(json['start_date']) ?? '',
      houseName: TypeUtils.toStringSafe(json['house_name']),
      farmName: TypeUtils.toStringSafe(json['farm_name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_number': batchNumber,
      'breed': breed,
      'status': status,
      'statusLabel': statusLabel,
      'total_birds': totalBirds,
      'live_birds': liveBirds,
      'mortality_count': mortalityCount,
      'mortality_rate': mortalityRate,
      'age_days': ageDays,
      'start_date': startDate,
      'house_name': houseName,
      'farm_name': farmName,
    };
  }
}

class RecentActivity {
  final String id;
  final String activityType;
  final String title;
  final String description;
  final String userId;
  final String? farmId;
  final String batchId;
  final String icon;
  final String status;
  final String? performedBy;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecentActivity({
    required this.id,
    required this.activityType,
    required this.title,
    required this.description,
    required this.userId,
    this.farmId,
    required this.batchId,
    required this.icon,
    required this.status,
    this.performedBy,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: TypeUtils.toStringSafe(json['id']),
      activityType: TypeUtils.toStringSafe(json['activity_type']),
      title: TypeUtils.toStringSafe(json['title']),
      description: TypeUtils.toStringSafe(json['description']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      batchId: TypeUtils.toStringSafe(json['batch_id']),
      icon: TypeUtils.toStringSafe(json['icon'], defaultValue: '📊'),
      status: TypeUtils.toStringSafe(json['status']),
      performedBy: TypeUtils.toNullableStringSafe(json['performed_by']),
      metadata: TypeUtils.toMapSafe(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType,
      'title': title,
      'description': description,
      'user_id': userId,
      'farm_id': farmId,
      'batch_id': batchId,
      'icon': icon,
      'status': status,
      'performed_by': performedBy,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class BatchStats {
  final int totalBirds;
  final String liveBirds;
  final int mortality;
  final int ageDays;

  const BatchStats({
    required this.totalBirds,
    required this.liveBirds,
    required this.mortality,
    required this.ageDays,
  });

  factory BatchStats.fromJson(Map<String, dynamic> json) {
    return BatchStats(
      totalBirds: TypeUtils.toIntSafe(json['total_birds']),
      liveBirds: TypeUtils.toStringSafe(json['live_birds']),
      mortality: TypeUtils.toIntSafe(json['mortality']),
      ageDays: TypeUtils.toIntSafe(json['age_days']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_birds': totalBirds,
      'live_birds': liveBirds,
      'mortality': mortality,
      'age_days': ageDays,
    };
  }
}

class FinancialStats {
  final FinancialPeriodStats today;
  final FinancialPeriodStats weekly;
  final FinancialPeriodStats monthly;
  final FinancialPeriodStats yearly;
  final FinancialPeriodStats allTime;

  const FinancialStats({
    required this.today,
    required this.weekly,
    required this.monthly,
    required this.yearly,
    required this.allTime,
  });

  factory FinancialStats.fromJson(Map<String, dynamic> json) {
    return FinancialStats(
      today: FinancialPeriodStats.fromJson(TypeUtils.toMapSafe(json['today']) ?? {}),
      weekly: FinancialPeriodStats.fromJson(TypeUtils.toMapSafe(json['weekly']) ?? {}),
      monthly: FinancialPeriodStats.fromJson(TypeUtils.toMapSafe(json['monthly']) ?? {}),
      yearly: FinancialPeriodStats.fromJson(TypeUtils.toMapSafe(json['yearly']) ?? {}),
      allTime: FinancialPeriodStats.fromJson(TypeUtils.toMapSafe(json['all_time']) ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today.toJson(),
      'weekly': weekly.toJson(),
      'monthly': monthly.toJson(),
      'yearly': yearly.toJson(),
      'all_time': allTime.toJson(),
    };
  }
}

class FinancialPeriodStats {
  final double feedingCost;
  final double vaccinationCost;
  final double inventoryCost;
  final double totalExpenditure;
  final double productIncome;
  final double netProfit;

  const FinancialPeriodStats({
    required this.feedingCost,
    required this.vaccinationCost,
    required this.inventoryCost,
    required this.totalExpenditure,
    required this.productIncome,
    required this.netProfit,
  });

  factory FinancialPeriodStats.fromJson(Map<String, dynamic> json) {
    return FinancialPeriodStats(
      feedingCost: TypeUtils.toDoubleSafe(json['feeding_cost']),
      vaccinationCost: TypeUtils.toDoubleSafe(json['vaccination_cost']),
      inventoryCost: TypeUtils.toDoubleSafe(json['inventory_cost']),
      totalExpenditure: TypeUtils.toDoubleSafe(json['total_expenditure']),
      productIncome: TypeUtils.toDoubleSafe(json['product_income']),
      netProfit: TypeUtils.toDoubleSafe(json['net_profit']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feeding_cost': feedingCost,
      'vaccination_cost': vaccinationCost,
      'inventory_cost': inventoryCost,
      'total_expenditure': totalExpenditure,
      'product_income': productIncome,
      'net_profit': netProfit,
    };
  }
}