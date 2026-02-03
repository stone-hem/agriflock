import 'package:agriflock360/features/farmer/report/models/batch_report_model.dart';

class FarmBatchReportResponse {
  final int statusCode;
  final String message;
  final List<FarmBatchReportData> data;
  final int count;

  FarmBatchReportResponse({
    required this.statusCode,
    required this.message,
    required this.data,
    required this.count,
  });

  factory FarmBatchReportResponse.fromJson(Map<String, dynamic> json) {
    return FarmBatchReportResponse(
      statusCode: json['statusCode'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => FarmBatchReportData.fromJson(item))
          .toList(),
      count: json['count'],
    );
  }
}

class FarmBatchReportData {
  final FarmSummary farmSummary;
  final List<BatchReportData> batches;
  final DateTime reportDate;
  final int totalBatches;
  final int totalHouses;
  final String farmName;
  final String reportPeriod;

  FarmBatchReportData({
    required this.farmSummary,
    required this.batches,
    required this.reportDate,
    required this.totalBatches,
    required this.totalHouses,
    required this.farmName,
    required this.reportPeriod,
  });

  factory FarmBatchReportData.fromJson(Map<String, dynamic> json) {
    return FarmBatchReportData(
      farmSummary: FarmSummary.fromJson(json['farm_summary']),
      batches: (json['batches'] as List)
          .map((item) => BatchReportData.fromJson(item))
          .toList(),
      reportDate: DateTime.parse(json['report_date']),
      totalBatches: json['total_batches'],
      totalHouses: json['total_houses'],
      farmName: json['farm_name'],
      reportPeriod: json['report_period'],
    );
  }
}

class FarmSummary {
  final String farmId;
  final String farmName;
  final String reportType;
  final String reportPeriod;
  final String birdType;
  final int totalBirds;
  final FarmMetadata metadata;
  final Mortality mortality;
  final List<String> batches;
  final Medication medication;
  final Vaccination vaccination;

  FarmSummary({
    required this.farmId,
    required this.farmName,
    required this.reportType,
    required this.reportPeriod,
    required this.birdType,
    required this.totalBirds,
    required this.metadata,
    required this.mortality,
    required this.batches,
    required this.medication,
    required this.vaccination,
  });

  factory FarmSummary.fromJson(Map<String, dynamic> json) {
    return FarmSummary(
      farmId: json['farm_id'],
      farmName: json['farm_name'],
      reportType: json['report_type'],
      reportPeriod: json['report_period'],
      birdType: json['bird_type'],
      totalBirds: json['total_birds'],
      metadata: FarmMetadata.fromJson(json['metadata']),
      mortality: Mortality.fromJson(json['mortality']),
      batches: List<String>.from(json['batches']),
      medication: Medication.fromJson(json['medication']),
      vaccination: Vaccination.fromJson(json['vaccination']),
    );
  }
}

class FarmMetadata {
  final int totalBatches;
  final int totalHouses;
  final int activeBatches;

  FarmMetadata({
    required this.totalBatches,
    required this.totalHouses,
    required this.activeBatches,
  });

  factory FarmMetadata.fromJson(Map<String, dynamic> json) {
    return FarmMetadata(
      totalBatches: json['total_batches'],
      totalHouses: json['total_houses'],
      activeBatches: json['active_batches'],
    );
  }
}

class Mortality {
  final int day;
  final int night;
  final int total24hrs;

  Mortality({
    required this.day,
    required this.night,
    required this.total24hrs,
  });

  factory Mortality.fromJson(Map<String, dynamic> json) {
    return Mortality(
      day: json['day'],
      night: json['night'],
      total24hrs: json['total_24hrs'],
    );
  }
}

class Medication {
  final List<dynamic> items;

  Medication({
    required this.items,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      items: List<dynamic>.from(json['items']),
    );
  }
}

class Vaccination {
  final List<dynamic> vaccinesDone;
  final List<dynamic> vaccinesUpcoming;

  Vaccination({
    required this.vaccinesDone,
    required this.vaccinesUpcoming,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      vaccinesDone: List<dynamic>.from(json['vaccines_done']),
      vaccinesUpcoming: List<dynamic>.from(json['vaccines_upcoming']),
    );
  }
}