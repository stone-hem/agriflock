import 'package:agriflock/core/utils/type_safe_utils.dart';

class BirdType {
  final String id;
  final String name;
  final String type;

  BirdType({required this.id, required this.name, required this.type});

  factory BirdType.fromJson(Map<String, dynamic> json) {
    return BirdType(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      type: TypeUtils.toStringSafe(json['type']),
    );
  }

  /// True for bird types that belong to the layers/growers category
  /// (require sub-type selection in the batch form).
  bool get isLayersCategory => type == 'layer' || type == 'grower';
}
