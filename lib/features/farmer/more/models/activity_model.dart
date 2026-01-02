
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
      id: json['id'] ?? '',
      activityType: json['activity_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['user_id'],
      farmId: json['farm_id'],
      batchId: json['batch_id'],
      icon: json['icon'] ?? '📝',
      status: json['status'] ?? 'completed',
      performedBy: json['performed_by'] ?? '',
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'])
          : json['metadata'] != null
          ? {'data': json['metadata']}
          : {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
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
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  // Helper methods to extract common metadata
  String? get batchName => metadata['batch_name'] as String?;
  int? get initialCount => metadata['initial_count'] as int?;
  String? get farmName {
    if (metadata['farm_details'] is Map) {
      final farmDetails = Map<String, dynamic>.from(metadata['farm_details'] as Map);
      return farmDetails['farm_name'] as String?;
    }
    return null;
  }
  String? get vaccinationId => metadata['vaccination_id'] as String?;
  double? get feedQuantity => metadata['quantity'] != null
      ? double.tryParse(metadata['quantity'].toString())
      : null;
  String? get feedType => metadata['feed_type'] as String?;
  int? get mortalityCount => metadata['mortality_today'] as int?;
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
    List<ActivityModel> activities = [];

    if (json['data'] is List) {
      activities = (json['data'] as List)
          .map((activity) => ActivityModel.fromJson(activity))
          .toList();
    }

    return ActivityResponse(
      activities: activities,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['pages'] ?? 1,
    );
  }

  bool get hasMore => page < totalPages;
}