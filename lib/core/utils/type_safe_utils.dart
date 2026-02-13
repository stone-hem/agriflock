import 'dart:convert';

class TypeUtils {
  // Private constructor to prevent instantiation
  TypeUtils._();

  // Safely convert any value to String, returns defaultValue (empty string) if null
  static String toStringSafe(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return defaultValue;
  }

  // NEW: Specifically for date strings - preserves the exact string value
  static String? toDateStringSafe(dynamic value, {String? defaultValue}) {
    if (value == null) return defaultValue;
    // Return the string representation exactly as is, without any parsing
    if (value is String) return value;
    if (value is DateTime) return value.toIso8601String();
    if (value is num || value is bool) return value.toString();
    return defaultValue;
  }

  // Safely convert any value to nullable String
  static String? toNullableStringSafe(dynamic value, {String? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return defaultValue;
  }

  // Safely convert any value to int, returns defaultValue (0) if null or invalid
  static int toIntSafe(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Handle empty strings or very long numeric strings
      if (value.isEmpty) return defaultValue;
      // Try to parse the string to int
      try {
        return int.parse(value);
      } catch (e) {
        // If parsing fails (e.g., very long number), return defaultValue
        return defaultValue;
      }
    }
    if (value is num) return value.toInt();
    return defaultValue;
  }

  // Safely convert any value to nullable int
  static int? toNullableIntSafe(dynamic value, {int? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value.isEmpty) return defaultValue;
      try {
        return int.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    if (value is num) return value.toInt();
    return defaultValue;
  }

  // Safely convert any value to double, returns defaultValue (0.0) if null or invalid
  static double toDoubleSafe(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return defaultValue;
      try {
        return double.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    if (value is num) return value.toDouble();
    return defaultValue;
  }

  // Safely convert any value to nullable double
  static double? toNullableDoubleSafe(dynamic value, {double? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return defaultValue;
      try {
        return double.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    if (value is num) return value.toDouble();
    return defaultValue;
  }

  // Safely convert any value to bool, returns defaultValue (false) if null
  static bool toBoolSafe(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
    }
    if (value is num) return value != 0;
    return defaultValue;
  }

  // Safely convert any value to nullable bool
  static bool? toNullableBoolSafe(dynamic value, {bool? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
    }
    if (value is num) return value != 0;
    return defaultValue;
  }

  // Safely convert any value to DateTime, returns null if invalid
  static DateTime? toDateTimeSafe(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Safely get value from map with type checking
  static T? getFromMap<T>(Map<String, dynamic> map, String key, T? defaultValue) {
    if (!map.containsKey(key)) return defaultValue;
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is T) return value;
    return defaultValue;
  }

  static Map<String, dynamic>? toMapSafe(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    // Handle Map<dynamic, dynamic> from some decoders
    if (value is Map) {
      try {
        return value.cast<String, dynamic>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Parse JSON string to Map if needed
  static Map<String, dynamic>? parseJsonString(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is String) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Safely convert to List
  static List<T> toListSafe<T>(dynamic value, {List<T> defaultValue = const []}) {
    if (value == null) return defaultValue;
    if (value is List) {
      try {
        return value.cast<T>();
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
}