// lib/features/farmer/batch/model/batch_mgt_model.dart

class BatchMgtResponse {
  final BatchInfo batch;
  final List<RecentActivity> recentActivities;
  final BatchStats stats;

  const BatchMgtResponse({
    required this.batch,
    required this.recentActivities,
    required this.stats,
  });

  factory BatchMgtResponse.fromJson(Map<String, dynamic> json) {
    return BatchMgtResponse(
      batch: BatchInfo.fromJson(json['batch']),
      recentActivities: (json['recent_activities'] as List?)
          ?.map((activity) => RecentActivity.fromJson(activity))
          .toList() ??
          [],
      stats: BatchStats.fromJson(json['stats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch': batch.toJson(),
      'recent_activities': recentActivities.map((a) => a.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }
}

class BatchInfo {
  final String id;
  final String name;
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
    required this.name,
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['statusLabel'] ?? '',
      totalBirds: json['total_birds'] ?? 0,
      liveBirds: json['live_birds']?.toString() ?? '0',
      mortalityCount: json['mortality_count'] ?? 0,
      mortalityRate: json['mortality_rate'] ?? 0,
      ageDays: json['age_days'] ?? 0,
      startDate: json['start_date'] ?? '',
      houseName: json['house_name'] ?? '',
      farmName: json['farm_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
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
      id: json['id'] ?? '',
      activityType: json['activity_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['user_id'] ?? '',
      farmId: json['farm_id'],
      batchId: json['batch_id'] ?? '',
      icon: json['icon'] ?? '📊',
      status: json['status'] ?? '',
      performedBy: json['performed_by'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
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
      totalBirds: json['total_birds'] ?? 0,
      liveBirds: json['live_birds']?.toString() ?? '0',
      mortality: json['mortality'] ?? 0,
      ageDays: json['age_days'] ?? 0,
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