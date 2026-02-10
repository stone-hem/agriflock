// lib/features/farmer/batch/model/product_model.dart

class Product {
  final String id;
  final String productType;
  final String userId;
  final String? batchId;
  final int? eggsCollected;
  final int? crackedEggs;
  final int? birdsSold;
  final String? weight;
  final String? quantity;
  final String price;
  final DateTime collectionDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.productType,
    required this.userId,
    this.batchId,
    this.eggsCollected,
    this.crackedEggs,
    this.birdsSold,
    this.weight,
    this.quantity,
    required this.price,
    required this.collectionDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      productType: json['product_type'] ?? '',
      userId: json['user_id'] ?? '',
      batchId: json['batch_id'],
      eggsCollected: json['eggs_collected'],
      crackedEggs: json['cracked_eggs'] ?? 0,
      birdsSold: json['birds_sold'],
      weight: json['weight']?.toString(),
      quantity: json['quantity']?.toString(),
      price: json['price']?.toString() ?? '0',
      collectionDate: json['collection_date'] != null
          ? DateTime.parse(json['collection_date'])
          : DateTime.now(),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_type': productType,
      'user_id': userId,
      'batch_id': batchId,
      'eggs_collected': eggsCollected,
      'cracked_eggs': crackedEggs,
      'birds_sold': birdsSold,
      'weight': weight,
      'quantity': quantity,
      'price': price,
      'collection_date': collectionDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ProductDashboard {
  final int totalEggs;
  final int totalCrackedEggs;
  final num averageDailyEggs;
  final int totalBirdsSold;
  final num totalMeatWeight;
  final num averageMonthlySales;
  final List<ProductionByType> productionByType;
  final List<WeeklyProduction> weeklyEggProduction;

  const ProductDashboard({
    required this.totalEggs,
    required this.totalCrackedEggs,
    required this.averageDailyEggs,
    required this.totalBirdsSold,
    required this.totalMeatWeight,
    required this.averageMonthlySales,
    required this.productionByType,
    required this.weeklyEggProduction,
  });

  factory ProductDashboard.fromJson(Map<String, dynamic> json) {
    return ProductDashboard(
      totalEggs: json['total_eggs'] ?? 0,
      totalCrackedEggs: json['total_cracked_eggs'] ?? 0,
      averageDailyEggs: json['average_daily_eggs'] ?? 0,
      totalBirdsSold: json['total_birds_sold'] ?? 0,
      totalMeatWeight: json['total_meat_weight'] ?? 0,
      averageMonthlySales: json['average_monthly_sales'] ?? 0,
      productionByType: (json['production_by_type'] as List?)
          ?.map((item) => ProductionByType.fromJson(item))
          .toList() ??
          [],
      weeklyEggProduction: (json['weekly_egg_production'] as List?)
          ?.map((item) => WeeklyProduction.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_eggs': totalEggs,
      'total_cracked_eggs': totalCrackedEggs,
      'average_daily_eggs': averageDailyEggs,
      'total_birds_sold': totalBirdsSold,
      'total_meat_weight': totalMeatWeight,
      'average_monthly_sales': averageMonthlySales,
      'production_by_type': productionByType.map((p) => p.toJson()).toList(),
      'weekly_egg_production': weeklyEggProduction.map((w) => w.toJson()).toList(),
    };
  }
}

class ProductionByType {
  final String productType;
  final num totalQuantity;
  final num totalRevenue;
  final num percentage;

  const ProductionByType({
    required this.productType,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.percentage,
  });

  factory ProductionByType.fromJson(Map<String, dynamic> json) {
    return ProductionByType(
      productType: json['product_type'] ?? '',
      totalQuantity: json['total_quantity'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_type': productType,
      'total_quantity': totalQuantity,
      'total_revenue': totalRevenue,
      'percentage': percentage,
    };
  }
}

class WeeklyProduction {
  final String week;
  final int eggsCollected;
  final int birdsSold;

  const WeeklyProduction({
    required this.week,
    required this.eggsCollected,
    required this.birdsSold,
  });

  factory WeeklyProduction.fromJson(Map<String, dynamic> json) {
    return WeeklyProduction(
      week: json['week'] ?? '',
      eggsCollected: json['eggs_collected'] ?? 0,
      birdsSold: json['birds_sold'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'eggs_collected': eggsCollected,
      'birds_sold': birdsSold,
    };
  }
}

// Request models for creating products
class CreateProductRequest {
  final String productType;
  final String batchId;
  final int? eggsCollected;
  final int? crackedEggs;
  final int? birdsSold;
  final num? weight;
  final num? quantity;
  final num price;
  final String collectionDate;
  final String? notes;
  final int? smallDeformedEggs;
  final int? partialBrokenEggs;



  const CreateProductRequest({
    required this.productType,
    required this.batchId,
    this.eggsCollected,
    this.crackedEggs,
    this.birdsSold,
    this.weight,
    this.quantity,
    required this.price,
    required this.collectionDate,
    this.notes, this.smallDeformedEggs, this.partialBrokenEggs,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'product_type': productType,
      'batch_id': batchId,
      'price': price,
      'collection_date': collectionDate,
    };

    if (notes != null && notes!.isNotEmpty) {
      data['notes'] = notes;
    }

    // Add type-specific fields
    switch (productType) {
      case 'eggs':
        data['eggs_collected'] = eggsCollected;
        data['cracked_eggs'] = crackedEggs ?? 0;
        data['small_deformed_eggs'] = smallDeformedEggs ?? 0;
        data['partial_broken_eggs'] = partialBrokenEggs??0;
        break;
      case 'meat':
        data['birds_sold'] = birdsSold;
        if (weight != null) {
          data['weight'] = weight;
        }
        break;
      case 'other':
        data['quantity'] = quantity;
        break;
    }

    return data;
  }
}