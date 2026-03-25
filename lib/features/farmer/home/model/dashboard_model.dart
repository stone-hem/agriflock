import 'dart:convert';
import 'package:agriflock/core/utils/type_safe_utils.dart';

class DashboardSummary {
  final num activeBatches;
  final num numberOfHouses;
  final num numberOfFarms;

  const DashboardSummary({
    required this.activeBatches,
    required this.numberOfHouses,
    required this.numberOfFarms,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final breedBreakdownList = TypeUtils.toListSafe<dynamic>(json['breed_breakdown']);

    return DashboardSummary(
      activeBatches: json['active_batches'] ?? 0,
      numberOfHouses: json['number_of_houses'] ?? 0,
      numberOfFarms: json['number_of_farms'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_batches': activeBatches,
      'number_of_houses': numberOfHouses,
      'number_of_farms': numberOfFarms,
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
      id: TypeUtils.toStringSafe(json['id']),
      activityType: TypeUtils.toStringSafe(json['activity_type']),
      title: TypeUtils.toStringSafe(json['title']),
      description: TypeUtils.toStringSafe(json['description']),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      batchId: TypeUtils.toNullableStringSafe(json['batch_id']),
      icon: TypeUtils.toStringSafe(json['icon'], defaultValue: '📊'),
      status: TypeUtils.toStringSafe(json['status']),
      performedBy: TypeUtils.toNullableStringSafe(json['performed_by']),
      metadata: TypeUtils.toMapSafe(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
      timeAgo: TypeUtils.toStringSafe(json['time_ago']),
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