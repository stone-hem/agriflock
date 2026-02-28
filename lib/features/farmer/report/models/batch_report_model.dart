import 'package:agriflock/core/utils/type_safe_utils.dart';

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
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    return BatchReportResponse(
      statusCode: TypeUtils.toIntSafe(json['statusCode']),
      message: TypeUtils.toStringSafe(json['message']),
      data: dataList
          .map((item) => BatchReportData.fromJson(
          item is Map<String, dynamic> ? item : {}))
          .toList(),
      count: TypeUtils.toIntSafe(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'count': count,
    };
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
  final BatchMedication medications;
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
    final productionStageMap = TypeUtils.toMapSafe(json['production_stage']);
    final mortalityMap = TypeUtils.toMapSafe(json['mortality']);
    final feedMap = TypeUtils.toMapSafe(json['feed']);
    final eggProductionMap = TypeUtils.toMapSafe(json['egg_production']);
    final medicationMap = TypeUtils.toMapSafe(json['medication']);
    final vaccinationMap = TypeUtils.toMapSafe(json['vaccination']);
    final medicationsMap = TypeUtils.toMapSafe(json['medications']);
    final feedingPlanMap = TypeUtils.toMapSafe(json['feeding_plan']);

    return BatchReportData(
      batchId: TypeUtils.toStringSafe(json['batch_id']),
      farmId: TypeUtils.toStringSafe(json['farm_id']),
      farmName: TypeUtils.toStringSafe(json['farm_name']),
      houseId: TypeUtils.toStringSafe(json['house_id']),
      houseName: TypeUtils.toStringSafe(json['house_name']),
      batchNumber: TypeUtils.toStringSafe(json['batch_number']),
      birdType: TypeUtils.toStringSafe(json['bird_type']),
      totalBirds: TypeUtils.toIntSafe(json['total_birds']),
      birdsPlaced: TypeUtils.toIntSafe(json['birds_placed']),
      ageDays: TypeUtils.toIntSafe(json['age_days']),
      ageWeeks: TypeUtils.toIntSafe(json['age_weeks']),
      productionStage: ProductionStage.fromJson(productionStageMap ?? {}),
      mortality: BatchMortality.fromJson(mortalityMap ?? {}),
      feed: BatchFeed.fromJson(feedMap ?? {}),
      eggProduction: EggProduction.fromJson(eggProductionMap ?? {}),
      medication: BatchMedication.fromJson(medicationMap ?? {}),
      vaccination: BatchVaccination.fromJson(vaccinationMap ?? {}),
      medications: BatchMedication.fromJson(medicationsMap ?? {}),
      feedingPlan: FeedingPlan.fromJson(feedingPlanMap ?? {}),
      reportBy: TypeUtils.toStringSafe(json['report_by']),
      reportDate: TypeUtils.toDateTimeSafe(json['report_date']) ?? DateTime.now(),
      reportPeriod: TypeUtils.toStringSafe(json['report_period']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'farm_id': farmId,
      'farm_name': farmName,
      'house_id': houseId,
      'house_name': houseName,
      'batch_number': batchNumber,
      'bird_type': birdType,
      'total_birds': totalBirds,
      'birds_placed': birdsPlaced,
      'age_days': ageDays,
      'age_weeks': ageWeeks,
      'production_stage': productionStage.toJson(),
      'mortality': mortality.toJson(),
      'feed': feed.toJson(),
      'egg_production': eggProduction.toJson(),
      'medication': medication.toJson(),
      'vaccination': vaccination.toJson(),
      'medications': medications.toJson(),
      'feeding_plan': feedingPlan.toJson(),
      'report_by': reportBy,
      'report_date': reportDate.toIso8601String(),
      'report_period': reportPeriod,
    };
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
    final expectedMilestoneMap = TypeUtils.toMapSafe(json['expected_milestone']);

    return ProductionStage(
      stage: TypeUtils.toStringSafe(json['stage']),
      description: TypeUtils.toStringSafe(json['description']),
      expectedMilestone: ExpectedMilestone.fromJson(expectedMilestoneMap ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'description': description,
      'expected_milestone': expectedMilestone.toJson(),
    };
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
      type: TypeUtils.toStringSafe(json['type']),
      expectedStartDay: TypeUtils.toIntSafe(json['expected_start_day']),
      expectedStartWeeks: TypeUtils.toIntSafe(json['expected_start_weeks']),
      daysRemaining: TypeUtils.toIntSafe(json['days_remaining']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'expected_start_day': expectedStartDay,
      'expected_start_weeks': expectedStartWeeks,
      'days_remaining': daysRemaining,
    };
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
      day: TypeUtils.toIntSafe(json['day']),
      night: TypeUtils.toIntSafe(json['night']),
      total24hrs: TypeUtils.toIntSafe(json['total_24hrs']),
      cumulativeTotal: TypeUtils.toIntSafe(json['cumulative_total']),
      birdsRemaining: TypeUtils.toIntSafe(json['birds_remaining']),
      reason: TypeUtils.toStringSafe(json['reason']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'night': night,
      'total_24hrs': total24hrs,
      'cumulative_total': cumulativeTotal,
      'birds_remaining': birdsRemaining,
      'reason': reason,
    };
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
      bagsConsumed: TypeUtils.toIntSafe(json['bags_consumed']),
      bagsConsumedDay: TypeUtils.toIntSafe(json['bags_consumed_day']),
      bagsConsumedNight: TypeUtils.toIntSafe(json['bags_consumed_night']),
      totalBagsConsumed: TypeUtils.toIntSafe(json['total_bags_consumed']),
      balanceInStore: TypeUtils.toIntSafe(json['balance_in_store']),
      feedType: TypeUtils.toStringSafe(json['feed_type']),
      feedVariance: TypeUtils.toStringSafe(json['feed_variance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bags_consumed': bagsConsumed,
      'bags_consumed_day': bagsConsumedDay,
      'bags_consumed_night': bagsConsumedNight,
      'total_bags_consumed': totalBagsConsumed,
      'balance_in_store': balanceInStore,
      'feed_type': feedType,
      'feed_variance': feedVariance,
    };
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
      traysCollected: TypeUtils.toIntSafe(json['trays_collected']),
      totalEggsCollected: TypeUtils.toIntSafe(json['total_eggs_collected']),
      piecesCollected: TypeUtils.toIntSafe(json['pieces_collected']),
      traysInStore: TypeUtils.toIntSafe(json['trays_in_store']),
      piecesInStore: TypeUtils.toIntSafe(json['pieces_in_store']),
      partialBroken: TypeUtils.toIntSafe(json['partial_broken']),
      completeBroken: TypeUtils.toIntSafe(json['complete_broken']),
      smallDeformed: TypeUtils.toIntSafe(json['small_deformed']),
      productionPercentage: TypeUtils.toDoubleSafe(json['production_percentage']),
      goodEggs: TypeUtils.toIntSafe(json['good_eggs']),
      totalValue: TypeUtils.toDoubleSafe(json['total_value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trays_collected': traysCollected,
      'total_eggs_collected': totalEggsCollected,
      'pieces_collected': piecesCollected,
      'trays_in_store': traysInStore,
      'pieces_in_store': piecesInStore,
      'partial_broken': partialBroken,
      'complete_broken': completeBroken,
      'small_deformed': smallDeformed,
      'production_percentage': productionPercentage,
      'good_eggs': goodEggs,
      'total_value': totalValue,
    };
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
    final availableList = TypeUtils.toListSafe<dynamic>(json['available']);
    final inUseList = TypeUtils.toListSafe<dynamic>(json['in_use']);
    final medicationsAvailableList = TypeUtils.toListSafe<dynamic>(json['medications_available']);

    return BatchMedication(
      available: availableList,
      inUse: inUseList
          .map((item) => MedicineInUse.fromJson(
          item is Map<String, dynamic> ? item : {}))
          .toList(),
      medicationsAvailable: medicationsAvailableList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'in_use': inUse.map((item) => item.toJson()).toList(),
      'medications_available': medicationsAvailable,
    };
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
      medicineName: TypeUtils.toStringSafe(json['medicine_name']),
      dosage: TypeUtils.toStringSafe(json['dosage']),
      quantityUsed: TypeUtils.toStringSafe(json['quantity_used']),
      unit: TypeUtils.toStringSafe(json['unit']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'dosage': dosage,
      'quantity_used': quantityUsed,
      'unit': unit,
    };
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
    final vaccinesDoneList = TypeUtils.toListSafe<dynamic>(json['vaccines_done']);
    final vaccinesUpcomingList = TypeUtils.toListSafe<dynamic>(json['vaccines_upcoming']);

    return BatchVaccination(
      vaccinesDone: vaccinesDoneList
          .map((item) => TypeUtils.toStringSafe(item))
          .toList(),
      vaccinesUpcoming: vaccinesUpcomingList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccines_done': vaccinesDone,
      'vaccines_upcoming': vaccinesUpcoming,
    };
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
    final feedingTimesMap = TypeUtils.toMapSafe(json['feeding_times']);

    return FeedingPlan(
      expectedFeedPerDayKg: TypeUtils.toDoubleSafe(json['expected_feed_per_day_kg']),
      feedPerBirdPerDayGrams: TypeUtils.toDoubleSafe(json['feed_per_bird_per_day_grams']),
      expectedFeedPerWeekBags: TypeUtils.toIntSafe(json['expected_feed_per_week_bags']),
      feedTypeInUse: TypeUtils.toStringSafe(json['feed_type_in_use']),
      stageName: TypeUtils.toStringSafe(json['stage_name']),
      timesPerDay: TypeUtils.toIntSafe(json['times_per_day']),
      feedingTimes: FeedingTimes.fromJson(feedingTimesMap ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expected_feed_per_day_kg': expectedFeedPerDayKg,
      'feed_per_bird_per_day_grams': feedPerBirdPerDayGrams,
      'expected_feed_per_week_bags': expectedFeedPerWeekBags,
      'feed_type_in_use': feedTypeInUse,
      'stage_name': stageName,
      'times_per_day': timesPerDay,
      'feeding_times': feedingTimes.toJson(),
    };
  }
}

class FeedingTimes {
  final List<String> slots;

  FeedingTimes({
    required this.slots,
  });

  factory FeedingTimes.fromJson(Map<String, dynamic> json) {
    final slotsList = TypeUtils.toListSafe<dynamic>(json['slots']);

    return FeedingTimes(
      slots: slotsList
          .map((item) => TypeUtils.toStringSafe(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slots': slots,
    };
  }
}