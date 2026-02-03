class BatchReportResponse {
  final int statusCode;
  final String message;
  final List<BatchReportData> data;
  final int count;

  BatchReportResponse({
    required this.statusCode,
    required this.message,
    required this.data,
    required this.count,
  });

  factory BatchReportResponse.fromJson(Map<String, dynamic> json) {
    return BatchReportResponse(
      statusCode: json['statusCode'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => BatchReportData.fromJson(item))
          .toList(),
      count: json['count'],
    );
  }
}

class BatchReportData {
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
  final BatchFeed feed;
  final BatchMedication medication;
  final BatchVaccination vaccination;
  final EggProduction? eggProduction;
  final DateTime reportDate;
  final String reportPeriod;

  BatchReportData({
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
    required this.reportDate,
    required this.reportPeriod,
  });

  factory BatchReportData.fromJson(Map<String, dynamic> json) {
    return BatchReportData(
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
      feed: BatchFeed.fromJson(json['feed']),
      medication: BatchMedication.fromJson(json['medication']),
      vaccination: BatchVaccination.fromJson(json['vaccination']),
      eggProduction: json['egg_production'] != null
          ? EggProduction.fromJson(json['egg_production'])
          : null,
      reportDate: DateTime.parse(json['report_date']),
      reportPeriod: json['report_period'],
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

class BatchFeed {
  final int bagsConsumed;
  final int totalBagsConsumed;
  final int balanceInStore;
  final String feedType;

  BatchFeed({
    required this.bagsConsumed,
    required this.totalBagsConsumed,
    required this.balanceInStore,
    required this.feedType,
  });

  factory BatchFeed.fromJson(Map<String, dynamic> json) {
    return BatchFeed(
      bagsConsumed: json['bags_consumed'],
      totalBagsConsumed: json['total_bags_consumed'],
      balanceInStore: json['balance_in_store'],
      feedType: json['feed_type'],
    );
  }
}

class BatchMedication {
  final List<dynamic> medicationsAvailable;

  BatchMedication({
    required this.medicationsAvailable,
  });

  factory BatchMedication.fromJson(Map<String, dynamic> json) {
    return BatchMedication(
      medicationsAvailable: List<dynamic>.from(json['medications_available']),
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
  final double productionPercentage;
  final int goodEggs;
  final double totalValue;

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
      productionPercentage: (json['production_percentage'] as num).toDouble(),
      goodEggs: json['good_eggs'],
      totalValue: (json['total_value'] as num).toDouble(),
    );
  }
}