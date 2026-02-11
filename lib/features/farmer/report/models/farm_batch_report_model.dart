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
  final DateTime? reportEndDate; // Made nullable
  final String reportPeriod;

  FarmBatchReportData({
    required this.farmSummary,
    required this.batches,
    required this.reportDate,
    required this.totalBatches,
    required this.totalHouses,
    required this.farmName,
    this.reportEndDate, // Made optional
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
      reportEndDate: json['report_end_date'] != null
          ? DateTime.parse(json['report_end_date'])
          : null,
      reportPeriod: json['report_period'] ?? '', // Handle null
    );
  }
}

class FarmSummary {
  final String farmId;
  final String farmName;
  final String reportType;
  final String? reportPeriod; // Made nullable
  final String birdType;
  final int totalBirds;
  final FarmMetadata metadata;
  final FarmMortality mortality;
  final List<String> batches;
  final FarmMedication medication;
  final FarmVaccination vaccination;

  FarmSummary({
    required this.farmId,
    required this.farmName,
    required this.reportType,
    this.reportPeriod, // Made optional
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
      reportPeriod: json['report_period'], // Can be null
      birdType: json['bird_type'],
      totalBirds: json['total_birds'],
      metadata: FarmMetadata.fromJson(json['metadata']),
      mortality: FarmMortality.fromJson(json['mortality']),
      batches: List<String>.from(json['batches']),
      medication: FarmMedication.fromJson(json['medication']),
      vaccination: FarmVaccination.fromJson(json['vaccination']),
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

class FarmMortality {
  final int day;
  final int night;
  final int total24hrs;

  FarmMortality({
    required this.day,
    required this.night,
    required this.total24hrs,
  });

  factory FarmMortality.fromJson(Map<String, dynamic> json) {
    return FarmMortality(
      day: json['day'] ?? 0,
      night: json['night'] ?? 0,
      total24hrs: json['total_24hrs'] ?? 0,
    );
  }
}

class FarmMedication {
  final List<dynamic> items;

  FarmMedication({
    required this.items,
  });

  factory FarmMedication.fromJson(Map<String, dynamic> json) {
    return FarmMedication(
      items: json['items'] != null ? List<dynamic>.from(json['items']) : [],
    );
  }
}

class FarmVaccination {
  final List<String> vaccinesDone;
  final List<dynamic> vaccinesUpcoming;

  FarmVaccination({
    required this.vaccinesDone,
    required this.vaccinesUpcoming,
  });

  factory FarmVaccination.fromJson(Map<String, dynamic> json) {
    return FarmVaccination(
      vaccinesDone: json['vaccines_done'] != null
          ? List<String>.from(json['vaccines_done'])
          : [],
      vaccinesUpcoming: json['vaccines_upcoming'] != null
          ? List<dynamic>.from(json['vaccines_upcoming'])
          : [],
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
  final int birdsPlaced;
  final dynamic ageDays; // Can be String or int
  final int ageWeeks;
  final ProductionStage productionStage;
  final BatchMortality mortality;
  final BatchFeed feed;
  final EggProduction? eggProduction;
  final BatchMedication medication;
  final BatchVaccination vaccination;
  final BatchMedication medications;
  final FeedingPlan? feedingPlan;
  final String reportBy;

  BatchReport({
    required this.batchId,
    required this.farmId,
    required this.farmName,
    required this.houseId,
    required this.houseName,
    required this.batchNumber,
    required this.birdType,
    required this.totalBirds,
    required this.birdsPlaced,
    required this.ageDays,
    required this.ageWeeks,
    required this.productionStage,
    required this.mortality,
    required this.feed,
    this.eggProduction,
    required this.medication,
    required this.vaccination,
    required this.medications,
    this.feedingPlan,
    required this.reportBy,
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
      birdsPlaced: json['birds_placed'] ?? 0,
      ageDays: json['age_days'] ?? 0,
      ageWeeks: json['age_weeks'] ?? 0,
      productionStage: ProductionStage.fromJson(json['production_stage']),
      mortality: BatchMortality.fromJson(json['mortality']),
      feed: BatchFeed.fromJson(json['feed']),
      eggProduction: json['egg_production'] != null
          ? EggProduction.fromJson(json['egg_production'])
          : null,
      medication: BatchMedication.fromJson(json['medication']),
      vaccination: BatchVaccination.fromJson(json['vaccination']),
      medications: BatchMedication.fromJson(json['medications']),
      feedingPlan: json['feeding_plan'] != null
          ? FeedingPlan.fromJson(json['feeding_plan'])
          : null,
      reportBy: json['report_by'] ?? '',
    );
  }
}

class ProductionStage {
  final String stage;
  final String description;
  final ExpectedMilestone expectedMilestone;

  ProductionStage({
    required this.stage,
    required this.description,
    required this.expectedMilestone,
  });

  factory ProductionStage.fromJson(Map<String, dynamic> json) {
    return ProductionStage(
      stage: json['stage'] ?? '',
      description: json['description'] ?? '',
      expectedMilestone: ExpectedMilestone.fromJson(json['expected_milestone']),
    );
  }
}

class ExpectedMilestone {
  final String type;
  final int expectedStartDay;
  final int expectedStartWeeks;
  final int daysRemaining;

  ExpectedMilestone({
    required this.type,
    required this.expectedStartDay,
    required this.expectedStartWeeks,
    required this.daysRemaining,
  });

  factory ExpectedMilestone.fromJson(Map<String, dynamic> json) {
    return ExpectedMilestone(
      type: json['type'] ?? '',
      expectedStartDay: json['expected_start_day'] ?? 0,
      expectedStartWeeks: json['expected_start_weeks'] ?? 0,
      daysRemaining: json['days_remaining'] ?? 0,
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
      day: json['day'] ?? 0,
      night: json['night'] ?? 0,
      total24hrs: json['total_24hrs'] ?? 0,
      cumulativeTotal: json['cumulative_total'] ?? 0,
      birdsRemaining: json['birds_remaining'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }
}

class BatchFeed {
  final int bagsConsumed;
  final int bagsConsumedDay;
  final int bagsConsumedNight;
  final int totalBagsConsumed;
  final int balanceInStore;
  final String feedType;
  final String feedVariance;

  BatchFeed({
    required this.bagsConsumed,
    required this.bagsConsumedDay,
    required this.bagsConsumedNight,
    required this.totalBagsConsumed,
    required this.balanceInStore,
    required this.feedType,
    required this.feedVariance,
  });

  factory BatchFeed.fromJson(Map<String, dynamic> json) {
    return BatchFeed(
      bagsConsumed: json['bags_consumed'] ?? 0,
      bagsConsumedDay: json['bags_consumed_day'] ?? 0,
      bagsConsumedNight: json['bags_consumed_night'] ?? 0,
      totalBagsConsumed: json['total_bags_consumed'] ?? 0,
      balanceInStore: json['balance_in_store'] ?? 0,
      feedType: json['feed_type'] ?? '',
      feedVariance: json['feed_variance'] ?? '',
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
      traysCollected: json['trays_collected'] ?? 0,
      totalEggsCollected: json['total_eggs_collected'] ?? 0,
      piecesCollected: json['pieces_collected'] ?? 0,
      traysInStore: json['trays_in_store'] ?? 0,
      piecesInStore: json['pieces_in_store'] ?? 0,
      partialBroken: json['partial_broken'] ?? 0,
      completeBroken: json['complete_broken'] ?? 0,
      smallDeformed: json['small_deformed'] ?? 0,
      productionPercentage: (json['production_percentage'] as num?)?.toDouble() ?? 0,
      goodEggs: json['good_eggs'] ?? 0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BatchMedication {
  final List<dynamic> available;
  final List<MedicineInUse> inUse;
  final List<dynamic> medicationsAvailable;

  BatchMedication({
    required this.available,
    required this.inUse,
    required this.medicationsAvailable,
  });

  factory BatchMedication.fromJson(Map<String, dynamic> json) {
    return BatchMedication(
      available: json['available'] != null
          ? List<dynamic>.from(json['available'])
          : [],
      inUse: json['in_use'] != null
          ? (json['in_use'] as List)
          .map((item) => MedicineInUse.fromJson(item))
          .toList()
          : [],
      medicationsAvailable: json['medications_available'] != null
          ? List<dynamic>.from(json['medications_available'])
          : [],
    );
  }
}

class MedicineInUse {
  final String medicineName;
  final String dosage;
  final String quantityUsed;
  final String unit;

  MedicineInUse({
    required this.medicineName,
    required this.dosage,
    required this.quantityUsed,
    required this.unit,
  });

  factory MedicineInUse.fromJson(Map<String, dynamic> json) {
    return MedicineInUse(
      medicineName: json['medicine_name'] ?? '',
      dosage: json['dosage'] ?? '',
      quantityUsed: json['quantity_used'] ?? '',
      unit: json['unit'] ?? '',
    );
  }
}

class BatchVaccination {
  final List<String> vaccinesDone;
  final List<dynamic> vaccinesUpcoming;

  BatchVaccination({
    required this.vaccinesDone,
    required this.vaccinesUpcoming,
  });

  factory BatchVaccination.fromJson(Map<String, dynamic> json) {
    return BatchVaccination(
      vaccinesDone: json['vaccines_done'] != null
          ? List<String>.from(json['vaccines_done'])
          : [],
      vaccinesUpcoming: json['vaccines_upcoming'] != null
          ? List<dynamic>.from(json['vaccines_upcoming'])
          : [],
    );
  }
}

class FeedingPlan {
  final double expectedFeedPerDayKg;
  final double feedPerBirdPerDayGrams;
  final int expectedFeedPerWeekBags;
  final String feedTypeInUse;
  final String stageName;
  final int timesPerDay;
  final FeedingTimes feedingTimes;

  FeedingPlan({
    required this.expectedFeedPerDayKg,
    required this.feedPerBirdPerDayGrams,
    required this.expectedFeedPerWeekBags,
    required this.feedTypeInUse,
    required this.stageName,
    required this.timesPerDay,
    required this.feedingTimes,
  });

  factory FeedingPlan.fromJson(Map<String, dynamic> json) {
    return FeedingPlan(
      expectedFeedPerDayKg: (json['expected_feed_per_day_kg'] as num?)?.toDouble() ?? 0,
      feedPerBirdPerDayGrams: (json['feed_per_bird_per_day_grams'] as num?)?.toDouble() ?? 0,
      expectedFeedPerWeekBags: json['expected_feed_per_week_bags'] ?? 0,
      feedTypeInUse: json['feed_type_in_use'] ?? '',
      stageName: json['stage_name'] ?? '',
      timesPerDay: json['times_per_day'] ?? 0,
      feedingTimes: FeedingTimes.fromJson(json['feeding_times'] ?? {}),
    );
  }
}

class FeedingTimes {
  final List<String> slots;

  FeedingTimes({
    required this.slots,
  });

  factory FeedingTimes.fromJson(Map<String, dynamic> json) {
    return FeedingTimes(
      slots: json['slots'] != null
          ? List<String>.from(json['slots'])
          : [],
    );
  }
}