// lib/features/farmer/batch/models/archived_batch_model.dart

class ArchivedBatchModel {
  final String id;
  final String name;
  final String breed;
  final int totalBirds;
  final int totalDays;
  final String status;
  final double mortalityRate;
  final int finalBirdsAlive;
  final int totalDeaths;
  final DateTime startDate;
  final DateTime endDate;
  final String? houseName;
  final String? farmName;

  const ArchivedBatchModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.totalBirds,
    required this.totalDays,
    required this.status,
    required this.mortalityRate,
    required this.finalBirdsAlive,
    required this.totalDeaths,
    required this.startDate,
    required this.endDate,
    this.houseName,
    this.farmName,
  });

  factory ArchivedBatchModel.fromJson(Map<String, dynamic> json) {
    return ArchivedBatchModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      totalBirds: _parseInt(json['total_birds']),
      totalDays: _parseInt(json['total_days']),
      status: json['status'] ?? 'Completed',
      mortalityRate: _parseDouble(json['mortality_rate']),
      finalBirdsAlive: _parseInt(json['final_birds_alive']),
      totalDeaths: _parseInt(json['total_deaths']),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      houseName: json['house_name'],
      farmName: json['farm_name'],
    );
  }

  // Helper method to parse int from various types
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // Helper method to parse double from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'total_birds': totalBirds,
      'total_days': totalDays,
      'status': status,
      'mortality_rate': mortalityRate,
      'final_birds_alive': finalBirdsAlive,
      'total_deaths': totalDeaths,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'house_name': houseName,
      'farm_name': farmName,
    };
  }

  ArchivedBatchModel copyWith({
    String? id,
    String? name,
    String? breed,
    int? totalBirds,
    int? totalDays,
    String? status,
    double? mortalityRate,
    int? finalBirdsAlive,
    int? totalDeaths,
    DateTime? startDate,
    DateTime? endDate,
    String? houseName,
    String? farmName,
  }) {
    return ArchivedBatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      totalBirds: totalBirds ?? this.totalBirds,
      totalDays: totalDays ?? this.totalDays,
      status: status ?? this.status,
      mortalityRate: mortalityRate ?? this.mortalityRate,
      finalBirdsAlive: finalBirdsAlive ?? this.finalBirdsAlive,
      totalDeaths: totalDeaths ?? this.totalDeaths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      houseName: houseName ?? this.houseName,
      farmName: farmName ?? this.farmName,
    );
  }
}

// Pagination model for archived batches
class ArchivedBatchPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ArchivedBatchPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ArchivedBatchPagination.fromJson(Map<String, dynamic> json) {
    return ArchivedBatchPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
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
}

// Response wrapper for archived batches
class ArchivedBatchesResponse {
  final String message;
  final List<ArchivedBatchModel> batches;
  final ArchivedBatchPagination pagination;

  const ArchivedBatchesResponse({
    required this.message,
    required this.batches,
    required this.pagination,
  });

  factory ArchivedBatchesResponse.fromJson(Map<String, dynamic> json) {
    List<ArchivedBatchModel> batchList = [];
    if (json['batches'] != null) {
      batchList = (json['batches'] as List)
          .map((b) => ArchivedBatchModel.fromJson(b))
          .toList();
    }

    ArchivedBatchPagination paginationData;
    if (json['pagination'] != null) {
      paginationData = ArchivedBatchPagination.fromJson(json['pagination']);
    } else {
      paginationData = ArchivedBatchPagination(
        total: batchList.length,
        page: 1,
        limit: 20,
        totalPages: 1,
      );
    }

    return ArchivedBatchesResponse(
      message: json['message'] ?? 'Success',
      batches: batchList,
      pagination: paginationData,
    );
  }
}