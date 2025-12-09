import 'dart:convert';
import 'package:agriflock360/features/auth/shared/country_phone_input.dart';
import 'package:flutter/services.dart';

class CountriesService {
  static Future<List<Country>> loadCountries() async {
    final String jsonString = await rootBundle.loadString('assets/data/countries.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Country.fromJson(json)).toList();
  }
}