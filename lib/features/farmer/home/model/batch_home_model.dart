import 'dart:convert';
import 'package:agriflock/core/utils/type_safe_utils.dart';

class BatchHomeResponse {
  final int statusCode;
  final String message;
  final List<BatchHomeData> data;
  final int totalBatches;

  BatchHomeResponse({
    required this.statusCode,
    required this.message,
    required this.data,
    required this.totalBatches,
  });

  factory BatchHomeResponse.fromJson(Map<String, dynamic> json) {
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    return BatchHomeResponse(
      statusCode: TypeUtils.toIntSafe(json['statusCode']),
      message: TypeUtils.toStringSafe(json['message']),
      data: dataList
          .map((batch) => BatchHomeData.fromJson(
          batch is Map<String, dynamic> ? batch : {}))
          .toList(),
      totalBatches: TypeUtils.toIntSafe(json['total_batches']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': data.map((batch) => batch.toJson()).toList(),
      'total_batches': totalBatches,
    };
  }
}

class BatchHomeData {
  final String batchId;
  final String farmId;
  final String farmName;
  final String houseName;
  final String batchNumber;
  final String birdType;
  final int totalBirds;
  final int birdsPlaced;
  final String reportBy;
  final String ageDays;
  final int ageWeeks;
  final ProductionStage productionStage;
  final int mortality;
  final String mortalityRate;
  final double productionCostPerBird;
  final String expenditureCurrency;
  final int foodInStoreBags;
  final int foodInStoreKg;
  final double totalExpectedFoodPerDayKg;
  final double expectedFoodPerBirdPerDayG;
  final double totalActualFoodPerDayKg;
  final double actualFoodPerBirdPerDayG;
  final double? expectedWeight;
  final double? actualWeight;
  final Vaccination vaccination;
  final Feed? feed;                       // NEW: Feed object
  final FeedingPlan? feedingPlan;         // NEW: Feeding plan object
  final double? totalMeatProduction;       // NEW: Total meat production
  final int? totalEggProduction;
  final int? productionPercentage;
  final double? eggCost;
  final double? productionCostPerEgg;
  final String? othersProduction;

  BatchHomeData({
    required this.batchId,
    required this.farmId,
    required this.farmName,
    required this.houseName,
    required this.batchNumber,
    required this.birdType,
    required this.totalBirds,
    required this.birdsPlaced,
    required this.reportBy,
    required this.ageDays,
    required this.ageWeeks,
    required this.productionStage,
    required this.mortality,
    required this.mortalityRate,
    required this.productionCostPerBird,
    required this.expenditureCurrency,
    required this.foodInStoreBags,
    required this.foodInStoreKg,
    required this.totalExpectedFoodPerDayKg,
    required this.expectedFoodPerBirdPerDayG,
    required this.totalActualFoodPerDayKg,
    required this.actualFoodPerBirdPerDayG,
    this.expectedWeight,
    this.actualWeight,
    required this.vaccination,
    this.feed,                             // NEW
    this.feedingPlan,                       // NEW
    this.totalMeatProduction,                // NEW
    this.totalEggProduction,
    this.productionPercentage,
    this.eggCost,
    this.productionCostPerEgg,
    this.othersProduction,
  });

  factory BatchHomeData.fromJson(Map<String, dynamic> json) {
    final productionStageMap = TypeUtils.toMapSafe(json['production_stage']);
    final vaccinationMap = TypeUtils.toMapSafe(json['vaccination']);
    final feedMap = TypeUtils.toMapSafe(json['feed']);                 // NEW
    final feedingPlanMap = TypeUtils.toMapSafe(json['feeding_plan']); // NEW

    return BatchHomeData(
      batchId: TypeUtils.toStringSafe(json['batch_id']),
      farmId: TypeUtils.toStringSafe(json['farm_id']),
      farmName: TypeUtils.toStringSafe(json['farm_name']),
      houseName: TypeUtils.toStringSafe(json['house_name']),
      batchNumber: TypeUtils.toStringSafe(json['batch_number']),
      birdType: TypeUtils.toStringSafe(json['bird_type']),
      totalBirds: TypeUtils.toIntSafe(json['total_birds']),
      birdsPlaced: TypeUtils.toIntSafe(json['birds_placed']),
      reportBy: TypeUtils.toStringSafe(json['report_by']),
      ageDays: _parseAgeDays(json['age_days']),
      ageWeeks: TypeUtils.toIntSafe(json['age_weeks']),
      productionStage: ProductionStage.fromJson(productionStageMap ?? {}),
      mortality: TypeUtils.toIntSafe(json['mortality']),
      mortalityRate: TypeUtils.toStringSafe(json['mortality_rate'], defaultValue: '0%'),
      productionCostPerBird: TypeUtils.toDoubleSafe(json['production_cost_per_bird']),
      expenditureCurrency: TypeUtils.toStringSafe(json['expenditure_currency']),
      foodInStoreBags: TypeUtils.toIntSafe(json['food_in_store_bags']),
      foodInStoreKg: TypeUtils.toIntSafe(json['food_in_store_kg']),
      totalExpectedFoodPerDayKg: TypeUtils.toDoubleSafe(json['total_expected_food_per_day_kg']),
      expectedFoodPerBirdPerDayG: TypeUtils.toDoubleSafe(json['expected_food_per_bird_per_day_g']),
      totalActualFoodPerDayKg: TypeUtils.toDoubleSafe(json['total_actual_food_per_day_kg']),
      actualFoodPerBirdPerDayG: TypeUtils.toDoubleSafe(json['actual_food_per_bird_per_day_g']),
      expectedWeight: TypeUtils.toNullableDoubleSafe(json['expected_weight']),
      actualWeight: TypeUtils.toNullableDoubleSafe(json['actual_weight']),
      vaccination: Vaccination.fromJson(vaccinationMap ?? {}),
      feed: feedMap != null ? Feed.fromJson(feedMap) : null,                 // NEW
      feedingPlan: feedingPlanMap != null ? FeedingPlan.fromJson(feedingPlanMap) : null, // NEW
      totalMeatProduction: TypeUtils.toNullableDoubleSafe(json['total_meat_production']), // NEW
      totalEggProduction: TypeUtils.toNullableIntSafe(json['total_egg_production']),
      productionPercentage: TypeUtils.toNullableIntSafe(json['production_percentage']),
      eggCost: TypeUtils.toNullableDoubleSafe(json['egg_cost']),
      productionCostPerEgg: TypeUtils.toNullableDoubleSafe(json['production_cost_per_egg']),
      othersProduction: TypeUtils.toNullableStringSafe(json['others_production']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'farm_id': farmId,
      'farm_name': farmName,
      'house_name': houseName,
      'batch_number': batchNumber,
      'bird_type': birdType,
      'total_birds': totalBirds,
      'birds_placed': birdsPlaced,
      'report_by': reportBy,
      'age_days': ageDays,
      'age_weeks': ageWeeks,
      'production_stage': productionStage.toJson(),
      'mortality': mortality,
      'mortality_rate': mortalityRate,
      'production_cost_per_bird': productionCostPerBird,
      'expenditure_currency': expenditureCurrency,
      'food_in_store_bags': foodInStoreBags,
      'food_in_store_kg': foodInStoreKg,
      'total_expected_food_per_day_kg': totalExpectedFoodPerDayKg,
      'expected_food_per_bird_per_day_g': expectedFoodPerBirdPerDayG,
      'total_actual_food_per_day_kg': totalActualFoodPerDayKg,
      'actual_food_per_bird_per_day_g': actualFoodPerBirdPerDayG,
      'expected_weight': expectedWeight,
      'actual_weight': actualWeight,
      'vaccination': vaccination.toJson(),
      'feed': feed?.toJson(),                 // NEW
      'feeding_plan': feedingPlan?.toJson(),   // NEW
      'total_meat_production': totalMeatProduction, // NEW
      'total_egg_production': totalEggProduction,
      'production_percentage': productionPercentage,
      'egg_cost': eggCost,
      'production_cost_per_egg': productionCostPerEgg,
      'others_production': othersProduction,
    };
  }

  static String _parseAgeDays(dynamic value) {
    if (value == null) return '0';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toInt().toString();
    return '0';
  }
}

// NEW: Feed class
class Feed {
  final int bagsConsumed;
  final int bagsConsumedDay;
  final int bagsConsumedNight;
  final int totalBagsConsumed;
  final int balanceInStore;
  final String feedType;
  final String feedVariance;

  Feed({
    required this.bagsConsumed,
    required this.bagsConsumedDay,
    required this.bagsConsumedNight,
    required this.totalBagsConsumed,
    required this.balanceInStore,
    required this.feedType,
    required this.feedVariance,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
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

// NEW: FeedingPlan class
class FeedingPlan {
  final double expectedFeedPerDayKg;
  final int feedPerBirdPerDayGrams;
  final int expectedFeedPerWeekBags;
  final String expectedAvgWeight;
  final String feedTypeInUse;
  final String stageName;
  final int timesPerDay;
  final FeedingTimes feedingTimes;

  FeedingPlan({
    required this.expectedFeedPerDayKg,
    required this.feedPerBirdPerDayGrams,
    required this.expectedFeedPerWeekBags,
    required this.expectedAvgWeight,
    required this.feedTypeInUse,
    required this.stageName,
    required this.timesPerDay,
    required this.feedingTimes,
  });

  factory FeedingPlan.fromJson(Map<String, dynamic> json) {
    final feedingTimesMap = TypeUtils.toMapSafe(json['feeding_times']);

    return FeedingPlan(
      expectedFeedPerDayKg: TypeUtils.toDoubleSafe(json['expected_feed_per_day_kg']),
      feedPerBirdPerDayGrams: TypeUtils.toIntSafe(json['feed_per_bird_per_day_grams']),
      expectedFeedPerWeekBags: TypeUtils.toIntSafe(json['expected_feed_per_week_bags']),
      expectedAvgWeight: TypeUtils.toStringSafe(json['expected_avg_weight']),
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
      'expected_avg_weight': expectedAvgWeight,
      'feed_type_in_use': feedTypeInUse,
      'stage_name': stageName,
      'times_per_day': timesPerDay,
      'feeding_times': feedingTimes.toJson(),
    };
  }
}

// NEW: FeedingTimes class
class FeedingTimes {
  final List<String> slots;

  FeedingTimes({
    required this.slots,
  });

  factory FeedingTimes.fromJson(Map<String, dynamic> json) {
    return FeedingTimes(
      slots: _parseStringList(json['slots']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slots': slots,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => TypeUtils.toStringSafe(item)).toList();
    }
    return [];
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

class Vaccination {
  final List<Vaccine> vaccinesDone;
  final List<Vaccine> vaccinesUpcoming;

  Vaccination({
    required this.vaccinesDone,
    required this.vaccinesUpcoming,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      vaccinesDone: _parseVaccineList(json['vaccines_done']),
      vaccinesUpcoming: _parseVaccineList(json['vaccines_upcoming']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccines_done': vaccinesDone.map((v) => v.toJson()).toList(),
      'vaccines_upcoming': vaccinesUpcoming.map((v) => v.toJson()).toList(),
    };
  }

  static List<Vaccine> _parseVaccineList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) {
        if (item is Map<String, dynamic>) {
          return Vaccine.fromJson(item);
        }
        return Vaccine(name: item.toString());
      }).toList();
    }
    return [];
  }
}

class Vaccine {
  final String name;
  final String? dueDate;
  final int? dayDue;

  Vaccine({
    required this.name,
    this.dueDate,
    this.dayDue,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      name: TypeUtils.toStringSafe(json['name']),
      dueDate: TypeUtils.toNullableStringSafe(json['due_date']),
      dayDue: TypeUtils.toNullableIntSafe(json['day_due']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'due_date': dueDate,
      'day_due': dayDue,
    };
  }
}