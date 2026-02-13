import 'package:agriflock360/core/utils/type_safe_utils.dart';

class ActivityModel {
  final String id;
  final String activityType;
  final String title;
  final String description;
  final String? userId;
  final String? farmId;
  final String? batchId;
  final String icon;
  final String status;
  final String performedBy;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    required this.id,
    required this.activityType,
    required this.title,
    required this.description,
    this.userId,
    this.farmId,
    this.batchId,
    required this.icon,
    required this.status,
    required this.performedBy,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: TypeUtils.toStringSafe(json['id']),
      activityType: TypeUtils.toStringSafe(json['activity_type']),
      title: TypeUtils.toStringSafe(json['title']),
      description: TypeUtils.toStringSafe(json['description']),
      userId: TypeUtils.toNullableStringSafe(json['user_id']),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      batchId: TypeUtils.toNullableStringSafe(json['batch_id']),
      icon: TypeUtils.toStringSafe(json['icon'], defaultValue: '📝'),
      status: TypeUtils.toStringSafe(json['status'], defaultValue: 'completed'),
      performedBy: TypeUtils.toStringSafe(json['performed_by']),
      metadata: _parseMetadata(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at'])?.toLocal() ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at'])?.toLocal() ?? DateTime.now(),
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
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  // Helper method to safely parse metadata
  static Map<String, dynamic> _parseMetadata(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        return {'data': value};
      }
    }
    return {'data': value};
  }

  // Helper methods to extract common metadata
  String? get batchName => metadata['batch_name'] as String?;

  int? get initialCount {
    final value = metadata['initial_count'];
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  String? get farmName {
    final farmDetails = metadata['farm_details'];
    if (farmDetails is Map) {
      final farmMap = Map<String, dynamic>.from(farmDetails);
      return farmMap['farm_name'] as String?;
    }
    return null;
  }

  String? get vaccinationId => metadata['vaccination_id'] as String?;

  double? get feedQuantity {
    final value = metadata['quantity'];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? get feedType => metadata['feed_type'] as String?;

  int? get mortalityCount {
    final value = metadata['mortality_today'];
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }
}

class ActivityResponse {
  final List<ActivityModel> activities;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ActivityResponse({
    required this.activities,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    final activities = dataList
        .map((activity) => ActivityModel.fromJson(
        activity is Map<String, dynamic> ? activity : {}))
        .toList();

    return ActivityResponse(
      activities: activities,
      total: TypeUtils.toIntSafe(json['total'], defaultValue: activities.length),
      page: TypeUtils.toIntSafe(json['page'], defaultValue: 1),
      limit: TypeUtils.toIntSafe(json['limit'], defaultValue: 20),
      totalPages: TypeUtils.toIntSafe(json['pages'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': activities.map((activity) => activity.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'pages': totalPages,
    };
  }

  bool get hasMore => page < totalPages;
}