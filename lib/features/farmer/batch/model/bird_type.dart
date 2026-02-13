import 'dart:convert';
import 'package:agriflock360/core/utils/type_safe_utils.dart';

class BirdType {
  final String id;
  final String name;

  BirdType({required this.id, required this.name});

  factory BirdType.fromJson(Map<String, dynamic> json) {
    return BirdType(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
    );
  }
}