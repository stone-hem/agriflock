class BirdType {
  final String id;
  final String name;

  BirdType({required this.id, required this.name});

  factory BirdType.fromJson(Map<String, dynamic> json) {
    return BirdType(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}