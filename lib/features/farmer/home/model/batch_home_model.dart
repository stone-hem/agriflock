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
    return BatchHomeResponse(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((batch) => BatchHomeData.fromJson(batch))
          .toList(),
      totalBatches: json['total_batches'] as int,
    );
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
  final int foodInStoreBags;
  final int foodInStoreKg;
  final double expectedFoodPerBirdPerDayG;
  final double totalActualFoodPerDayKg;
  final double actualFoodPerBirdPerDayG;
  final double? expectedWeight;
  final double? actualWeight;
  final Vaccination vaccination;
  final int? totalEggProduction;
  final int? productionPercentage;
  final double? eggCost;

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
    required this.foodInStoreBags,
    required this.foodInStoreKg,
    required this.expectedFoodPerBirdPerDayG,
    required this.totalActualFoodPerDayKg,
    required this.actualFoodPerBirdPerDayG,
    this.expectedWeight,
    this.actualWeight,
    required this.vaccination,
    this.totalEggProduction,
    this.productionPercentage,
    this.eggCost,
  });

  factory BatchHomeData.fromJson(Map<String, dynamic> json) {
    return BatchHomeData(
      batchId: json['batch_id'] as String,
      farmId: json['farm_id'] as String,
      farmName: json['farm_name'] as String,
      houseName: json['house_name'] as String,
      batchNumber: json['batch_number'] as String,
      birdType: json['bird_type'] as String,
      totalBirds: json['total_birds'] as int,
      birdsPlaced: json['birds_placed'] as int,
      reportBy: json['report_by'] as String,
      ageDays: json['age_days'].toString(),
      ageWeeks: json['age_weeks'] as int,
      productionStage: ProductionStage.fromJson(json['production_stage']),
      mortality: json['mortality'] as int,
      mortalityRate: json['mortality_rate'] as String,
      foodInStoreBags: json['food_in_store_bags'] as int,
      foodInStoreKg: json['food_in_store_kg'] as int,
      expectedFoodPerBirdPerDayG: (json['expected_food_per_bird_per_day_g'] as num).toDouble(),
      totalActualFoodPerDayKg: (json['total_actual_food_per_day_kg'] as num).toDouble(),
      actualFoodPerBirdPerDayG: (json['actual_food_per_bird_per_day_g'] as num).toDouble(),
      expectedWeight: json['expected_weight'] != null ? (json['expected_weight'] as num).toDouble() : null,
      actualWeight: json['actual_weight'] != null ? (json['actual_weight'] as num).toDouble() : null,
      vaccination: Vaccination.fromJson(json['vaccination']),
      totalEggProduction: json['total_egg_production'] as int?,
      productionPercentage: json['production_percentage'] as int?,
      eggCost: json['egg_cost'] != null ? (json['egg_cost'] as num).toDouble() : null,
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
      stage: json['stage'] as String,
      description: json['description'] as String,
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
      type: json['type'] as String,
      expectedStartDay: json['expected_start_day'] as int,
      expectedStartWeeks: json['expected_start_weeks'] as int,
      daysRemaining: json['days_remaining'] as int,
    );
  }
}

class Vaccination {
  final List<String> vaccinesDone;
  final List<String> vaccinesUpcoming;

  Vaccination({
    required this.vaccinesDone,
    required this.vaccinesUpcoming,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      vaccinesDone: (json['vaccines_done'] as List).cast<String>(),
      vaccinesUpcoming: (json['vaccines_upcoming'] as List).cast<String>(),
    );
  }
}