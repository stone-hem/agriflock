class BatchModel {
  final String id;
  final String batchName;
  final String? houseId;
  final String? houseName;
  final String breed;
  final String type;
  final DateTime startDate;
  final int age;
  final int initialQuantity;
  final int birdsAlive;
  final num mortality;
  final double currentWeight;
  final double expectedWeight;
  final String feedingTime;
  final List<String> feedingSchedule;
  final String? photoUrl;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BatchModel({
    required this.id,
    required this.batchName,
    this.houseId,
    this.houseName,
    required this.breed,
    required this.type,
    required this.startDate,
    required this.age,
    required this.initialQuantity,
    required this.birdsAlive,
    this.mortality = 0,
    required this.currentWeight,
    required this.expectedWeight,
    required this.feedingTime,
    required this.feedingSchedule,
    this.photoUrl,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'].toString(),
      batchName: json['batch_name'] ?? json['name'] ?? '',
      houseId: json['house_id']?.toString(),
      houseName: json['house_name'],
      breed: json['breed'] ?? '',
      type: json['type'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      age: int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      initialQuantity: int.tryParse((json['initial_quantity'] ?? json['quantity'])?.toString() ?? '0') ?? 0,
      birdsAlive: int.tryParse((json['birds_alive'] ?? json['quantity'])?.toString() ?? '0') ?? 0,
      mortality: json['mortality'] ?? 0,
      currentWeight: (json['current_weight'] ?? 0).toDouble(),
      expectedWeight: (json['expected_weight'] ?? 0).toDouble(),
      feedingTime: json['feeding_time'] ?? 'Day',
      feedingSchedule: json['feeding_schedule'] != null
          ? List<String>.from(json['feeding_schedule'])
          : [],
      photoUrl: json['photo_url'] ?? json['batch_avatar'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_name': batchName,
      'house_id': houseId,
      'breed': breed,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'age': age,
      'initial_quantity': initialQuantity,
      'birds_alive': birdsAlive,
      'mortality': mortality,
      'current_weight': currentWeight,
      'expected_weight': expectedWeight,
      'feeding_time': feedingTime,
      'feeding_schedule': feedingSchedule,
      'photo_url': photoUrl,
      'description': description,
    };
  }

  BatchModel copyWith({
    String? id,
    String? batchName,
    String? houseId,
    String? houseName,
    String? breed,
    String? type,
    DateTime? startDate,
    int? age,
    int? initialQuantity,
    int? birdsAlive,
    num? mortality,
    double? currentWeight,
    double? expectedWeight,
    String? feedingTime,
    List<String>? feedingSchedule,
    String? photoUrl,
    String? description,
  }) {
    return BatchModel(
      id: id ?? this.id,
      batchName: batchName ?? this.batchName,
      houseId: houseId ?? this.houseId,
      houseName: houseName ?? this.houseName,
      breed: breed ?? this.breed,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      age: age ?? this.age,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      birdsAlive: birdsAlive ?? this.birdsAlive,
      mortality: mortality ?? this.mortality,
      currentWeight: currentWeight ?? this.currentWeight,
      expectedWeight: expectedWeight ?? this.expectedWeight,
      feedingTime: feedingTime ?? this.feedingTime,
      feedingSchedule: feedingSchedule ?? this.feedingSchedule,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class House {
  final String? id;
  final String houseName;
  final String? farmId;
  final int capacity;
  final int currentBirds;
  final double utilization;
  final List<BatchModel> batches;
  final String? photoUrl;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const House({
    this.id,
    required this.houseName,
    this.farmId,
    required this.capacity,
    this.currentBirds = 0,
    this.utilization = 0,
    this.batches = const [],
    this.photoUrl,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    List<BatchModel> batchList = [];
    if (json['batches'] != null) {
      batchList = (json['batches'] as List)
          .map((b) => BatchModel.fromJson(b))
          .toList();
    }

    return House(
      id: json['id']?.toString(),
      houseName: json['house_name'] ?? json['name'] ?? '',
      farmId: json['farm_id']?.toString(),
      capacity: json['capacity'] ?? 0,
      currentBirds: json['current_birds'] ?? 0,
      utilization: (json['utilization'] ?? 0).toDouble(),
      batches: batchList,
      photoUrl: json['photo_url'] ?? json['house_avatar'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'house_name': houseName,
      'farm_id': farmId,
      'capacity': capacity,
      'current_birds': currentBirds,
      'utilization': utilization,
      'photo_url': photoUrl,
      'description': description,
    };
  }

  House copyWith({
    String? id,
    String? houseName,
    String? farmId,
    int? capacity,
    int? currentBirds,
    double? utilization,
    List<BatchModel>? batches,
    String? photoUrl,
    String? description,
  }) {
    return House(
      id: id ?? this.id,
      houseName: houseName ?? this.houseName,
      farmId: farmId ?? this.farmId,
      capacity: capacity ?? this.capacity,
      currentBirds: currentBirds ?? this.currentBirds,
      utilization: utilization ?? this.utilization,
      batches: batches ?? this.batches,
      photoUrl: photoUrl ?? this.photoUrl,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}