class FarmHouse {
  final String id;
  final String name;
  final String location;
  final List<FarmBatch> batches;

  FarmHouse({
    required this.id,
    required this.name,
    required this.location,
    required this.batches,
  });
}

class FarmBatch {
  final String id;
  final String name;
  final int birdCount;
  final int ageWeeks;
  final String birdType;
  final String healthStatus;

  FarmBatch({
    required this.id,
    required this.name,
    required this.birdCount,
    required this.ageWeeks,
    required this.birdType,
    required this.healthStatus,
  });
}

