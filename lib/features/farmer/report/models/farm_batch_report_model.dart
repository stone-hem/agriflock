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
  final List<BatchReport> batches;
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
          .map((item) => BatchReport.fromJson(item))
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

class BatchReport {
  final String batchId;
  final String farmId;
  final String farmName;
  final String houseId;
  final String houseName;
  final String batchNumber;
  final String birdType;
  final int totalBirds;
  final int ageDays;
  final int ageWeeks;
  final BatchMortality mortality;
  final Feed feed;
  final Medication medication;
  final BatchVaccination vaccination;
  final EggProduction? eggProduction;

  BatchReport({
    required this.batchId,
    required this.farmId,
    required this.farmName,
    required this.houseId,
    required this.houseName,
    required this.batchNumber,
    required this.birdType,
    required this.totalBirds,
    required this.ageDays,
    required this.ageWeeks,
    required this.mortality,
    required this.feed,
    required this.medication,
    required this.vaccination,
    this.eggProduction,
  });

  factory BatchReport.fromJson(Map<String, dynamic> json) {
    return BatchReport(
      batchId: json['batch_id'],
      farmId: json['farm_id'],
      farmName: json['farm_name'],
      houseId: json['house_id'],
      houseName: json['house_name'],
      batchNumber: json['batch_number'],
      birdType: json['bird_type'],
      totalBirds: json['total_birds'],
      ageDays: json['age_days'],
      ageWeeks: json['age_weeks'],
      mortality: BatchMortality.fromJson(json['mortality']),
      feed: Feed.fromJson(json['feed']),
      medication: Medication.fromJson(json['medication']),
      vaccination: BatchVaccination.fromJson(json['vaccination']),
      eggProduction: json['egg_production'] != null
          ? EggProduction.fromJson(json['egg_production'])
          : null,
    );
  }
}

class BatchMortality {
  final int day;
  final int night;
  final int total24hrs;
  final int cumulativeTotal;
  final int birdsRemaining;
  final String reason;

  BatchMortality({
    required this.day,
    required this.night,
    required this.total24hrs,
    required this.cumulativeTotal,
    required this.birdsRemaining,
    required this.reason,
  });

  factory BatchMortality.fromJson(Map<String, dynamic> json) {
    return BatchMortality(
      day: json['day'],
      night: json['night'],
      total24hrs: json['total_24hrs'],
      cumulativeTotal: json['cumulative_total'],
      birdsRemaining: json['birds_remaining'],
      reason: json['reason'],
    );
  }
}

class Feed {
  final int bagsConsumed;
  final int totalBagsConsumed;
  final int balanceInStore;
  final String feedType;

  Feed({
    required this.bagsConsumed,
    required this.totalBagsConsumed,
    required this.balanceInStore,
    required this.feedType,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      bagsConsumed: json['bags_consumed'],
      totalBagsConsumed: json['total_bags_consumed'],
      balanceInStore: json['balance_in_store'],
      feedType: json['feed_type'],
    );
  }
}

class BatchVaccination {
  final List<dynamic> vaccinesDone;
  final List<dynamic> vaccinesUpcoming;

  BatchVaccination({
    required this.vaccinesDone,
    required this.vaccinesUpcoming,
  });

  factory BatchVaccination.fromJson(Map<String, dynamic> json) {
    return BatchVaccination(
      vaccinesDone: List<dynamic>.from(json['vaccines_done']),
      vaccinesUpcoming: List<dynamic>.from(json['vaccines_upcoming']),
    );
  }
}

class EggProduction {
  final int traysCollected;
  final int totalEggsCollected;
  final int piecesCollected;
  final int traysInStore;
  final int piecesInStore;
  final int partialBroken;
  final int completeBroken;
  final int smallDeformed;
  final int productionPercentage;
  final int goodEggs;
  final int totalValue;

  EggProduction({
    required this.traysCollected,
    required this.totalEggsCollected,
    required this.piecesCollected,
    required this.traysInStore,
    required this.piecesInStore,
    required this.partialBroken,
    required this.completeBroken,
    required this.smallDeformed,
    required this.productionPercentage,
    required this.goodEggs,
    required this.totalValue,
  });

  factory EggProduction.fromJson(Map<String, dynamic> json) {
    return EggProduction(
      traysCollected: json['trays_collected'],
      totalEggsCollected: json['total_eggs_collected'],
      piecesCollected: json['pieces_collected'],
      traysInStore: json['trays_in_store'],
      piecesInStore: json['pieces_in_store'],
      partialBroken: json['partial_broken'],
      completeBroken: json['complete_broken'],
      smallDeformed: json['small_deformed'],
      productionPercentage: json['production_percentage'],
      goodEggs: json['good_eggs'],
      totalValue: json['total_value'],
    );
  }
}