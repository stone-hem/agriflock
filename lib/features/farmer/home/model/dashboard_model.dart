class DashboardSummary {
  final num totalBirds;
  final num eggsToday;
  final num activeBatches;
  final num mortalityRate;
  final num feedEfficiencyFcr;
  final num averageWeightKg;

  const DashboardSummary({
    required this.totalBirds,
    required this.eggsToday,
    required this.activeBatches,
    required this.mortalityRate,
    required this.feedEfficiencyFcr,
    required this.averageWeightKg,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalBirds: json['total_birds'] ?? 0,
      eggsToday: json['eggs_today'] ?? 0,
      activeBatches: json['active_batches'] ?? 0,
      mortalityRate: json['mortality_rate'] ?? 0,
      feedEfficiencyFcr: json['feed_efficiency_fcr'] ?? 0,
      averageWeightKg: json['average_weight_kg'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_birds': totalBirds,
      'eggs_today': eggsToday,
      'active_batches': activeBatches,
      'mortality_rate': mortalityRate,
      'feed_efficiency_fcr': feedEfficiencyFcr,
      'average_weight_kg': averageWeightKg,
    };
  }
}

class DashboardActivity {
  final String id;
  final String activityType;
  final String title;
  final String description;
  final String? farmId;
  final String? batchId;
  final String icon;
  final String status;
  final String? performedBy;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String timeAgo;

  const DashboardActivity({
    required this.id,
    required this.activityType,
    required this.title,
    required this.description,
    this.farmId,
    this.batchId,
    required this.icon,
    required this.status,
    this.performedBy,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.timeAgo,
  });

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    return DashboardActivity(
      id: json['id'] ?? '',
      activityType: json['activity_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      farmId: json['farm_id'],
      batchId: json['batch_id'],
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
      timeAgo: json['time_ago'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType,
      'title': title,
      'description': description,
      'farm_id': farmId,
      'batch_id': batchId,
      'icon': icon,
      'status': status,
      'performed_by': performedBy,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'time_ago': timeAgo,
    };
  }
}