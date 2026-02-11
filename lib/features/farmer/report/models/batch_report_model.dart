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
  final int birdsPlaced;
  final int ageDays;
  final int ageWeeks;
  final ProductionStage productionStage;
  final BatchMortality mortality;
  final BatchFeed feed;
  final EggProduction eggProduction;
  final BatchMedication medication;
  final BatchVaccination vaccination;
  final BatchMedication medications; // Same structure as medication
  final FeedingPlan feedingPlan;
  final String reportBy;
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
    required this.birdsPlaced,
    required this.ageDays,
    required this.ageWeeks,
    required this.productionStage,
    required this.mortality,
    required this.feed,
    required this.eggProduction,
    required this.medication,
    required this.vaccination,
    required this.medications,
    required this.feedingPlan,
    required this.reportBy,
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
      birdsPlaced: json['birds_placed'],
      ageDays: json['age_days'],
      ageWeeks: json['age_weeks'],
      productionStage: ProductionStage.fromJson(json['production_stage']),
      mortality: BatchMortality.fromJson(json['mortality']),
      feed: BatchFeed.fromJson(json['feed']),
      eggProduction: EggProduction.fromJson(json['egg_production']),
      medication: BatchMedication.fromJson(json['medication']),
      vaccination: BatchVaccination.fromJson(json['vaccination']),
      medications: BatchMedication.fromJson(json['medications']),
      feedingPlan: FeedingPlan.fromJson(json['feeding_plan']),
      reportBy: json['report_by'],
      reportDate: DateTime.parse(json['report_date']),
      reportPeriod: json['report_period'],
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
      stage: json['stage'],
      description: json['description'],
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
      type: json['type'],
      expectedStartDay: json['expected_start_day'],
      expectedStartWeeks: json['expected_start_weeks'],
      daysRemaining: json['days_remaining'],
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
      bagsConsumed: json['bags_consumed'],
      bagsConsumedDay: json['bags_consumed_day'],
      bagsConsumedNight: json['bags_consumed_night'],
      totalBagsConsumed: json['total_bags_consumed'],
      balanceInStore: json['balance_in_store'],
      feedType: json['feed_type'],
      feedVariance: json['feed_variance'],
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
      available: List<dynamic>.from(json['available'] ?? []),
      inUse: (json['in_use'] as List)
          .map((item) => MedicineInUse.fromJson(item))
          .toList(),
      medicationsAvailable: List<dynamic>.from(json['medications_available'] ?? []),
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
      medicineName: json['medicine_name'],
      dosage: json['dosage'],
      quantityUsed: json['quantity_used'],
      unit: json['unit'],
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
      vaccinesDone: List<String>.from(json['vaccines_done']),
      vaccinesUpcoming: List<dynamic>.from(json['vaccines_upcoming']),
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
      expectedFeedPerDayKg: (json['expected_feed_per_day_kg'] as num).toDouble(),
      feedPerBirdPerDayGrams: (json['feed_per_bird_per_day_grams'] as num).toDouble(),
      expectedFeedPerWeekBags: json['expected_feed_per_week_bags'],
      feedTypeInUse: json['feed_type_in_use'],
      stageName: json['stage_name'],
      timesPerDay: json['times_per_day'],
      feedingTimes: FeedingTimes.fromJson(json['feeding_times']),
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
      slots: List<String>.from(json['slots']),
    );
  }
}