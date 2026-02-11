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
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List? ?? [])
          .map((batch) => BatchHomeData.fromJson(batch as Map<String, dynamic>))
          .toList(),
      totalBatches: json['total_batches'] as int? ?? 0,
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
  final String ageDays; // Keep as String to handle both formats
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

  // Helper getter to get age days as int when needed
  int get ageDaysAsInt => int.tryParse(ageDays) ?? 0;

  factory BatchHomeData.fromJson(Map<String, dynamic> json) {
    // Safely parse age_days - handle both String and int
    String parseAgeDays(dynamic value) {
      if (value == null) return '0';
      if (value is String) return value;
      if (value is int) return value.toString();
      return '0';
    }

    // Safely parse double values
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Safely parse int values
    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      if (value is double) return value.toInt();
      return defaultValue;
    }

    return BatchHomeData(
      batchId: json['batch_id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      farmName: json['farm_name'] as String? ?? '',
      houseName: json['house_name'] as String? ?? '',
      batchNumber: json['batch_number'] as String? ?? '',
      birdType: json['bird_type'] as String? ?? '',
      totalBirds: parseInt(json['total_birds']),
      birdsPlaced: parseInt(json['birds_placed']),
      reportBy: json['report_by'] as String? ?? '',
      ageDays: parseAgeDays(json['age_days']),
      ageWeeks: parseInt(json['age_weeks']),
      productionStage: ProductionStage.fromJson(
        json['production_stage'] as Map<String, dynamic>? ?? {},
      ),
      mortality: parseInt(json['mortality']),
      mortalityRate: json['mortality_rate'] as String? ?? '0%',
      foodInStoreBags: parseInt(json['food_in_store_bags']),
      foodInStoreKg: parseInt(json['food_in_store_kg']),
      expectedFoodPerBirdPerDayG: parseDouble(json['expected_food_per_bird_per_day_g']),
      totalActualFoodPerDayKg: parseDouble(json['total_actual_food_per_day_kg']),
      actualFoodPerBirdPerDayG: parseDouble(json['actual_food_per_bird_per_day_g']),
      expectedWeight: json['expected_weight'] != null
          ? parseDouble(json['expected_weight'])
          : null,
      actualWeight: json['actual_weight'] != null
          ? parseDouble(json['actual_weight'])
          : null,
      vaccination: Vaccination.fromJson(
        json['vaccination'] as Map<String, dynamic>? ?? {},
      ),
      totalEggProduction: json['total_egg_production'] != null
          ? parseInt(json['total_egg_production'])
          : null,
      productionPercentage: json['production_percentage'] != null
          ? parseInt(json['production_percentage'])
          : null,
      eggCost: json['egg_cost'] != null
          ? parseDouble(json['egg_cost'])
          : null,
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
      stage: json['stage'] as String? ?? '',
      description: json['description'] as String? ?? '',
      expectedMilestone: ExpectedMilestone.fromJson(
        json['expected_milestone'] as Map<String, dynamic>? ?? {},
      ),
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
    // Safely parse int values
    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      if (value is double) return value.toInt();
      return defaultValue;
    }

    return ExpectedMilestone(
      type: json['type'] as String? ?? '',
      expectedStartDay: parseInt(json['expected_start_day']),
      expectedStartWeeks: parseInt(json['expected_start_weeks']),
      daysRemaining: parseInt(json['days_remaining']),
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
    // Safely parse string lists
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((item) => item?.toString() ?? '').toList();
      }
      return [];
    }

    return Vaccination(
      vaccinesDone: parseStringList(json['vaccines_done']),
      vaccinesUpcoming: parseStringList(json['vaccines_upcoming']),
    );
  }
}