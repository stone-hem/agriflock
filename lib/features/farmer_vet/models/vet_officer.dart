import 'dart:ui';

class VetOfficer {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final String distance;
  final String phone;
  final String email;
  final String clinic;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isAvailable;
  final String consultationFee;
  final bool emergencyService;
  final List<String> languages;
  final List<String> services;
  final Color avatarColor;

  VetOfficer({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.distance,
    required this.phone,
    required this.email,
    required this.clinic,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isAvailable,
    required this.consultationFee,
    required this.emergencyService,
    required this.languages,
    required this.services,
    required this.avatarColor,
  });
}