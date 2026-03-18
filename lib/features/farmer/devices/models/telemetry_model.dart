import 'package:agriflock/core/utils/type_safe_utils.dart';
import 'package:flutter/material.dart';

class TelemetryData {
  final String id;
  final String deviceId;
  final double temperature;
  final double humidity;
  final double? voltage;
  final int state;
  final int connMode;
  final bool heaterStatus;
  final bool fanStatus;
  final bool powerStatus;
  final String? errorCode;
  final DateTime timestamp;
  final String stateLabel;
  final String connModeLabel;

  // Added fields
  final int soc;             // battery state of charge (0–100 %)
  final int water;           // water level raw value
  final int paygStatus;      // 0 = active, 1 = expired/locked
  final int mode;            // device operating mode
  final int? tempWeek1;
  final int? tempWeek2;
  final int? tempWeek3;
  final int? tempWeek4;
  final String modeLabel;        // e.g. "auto", "manual"
  final String waterLevelLabel;  // e.g. "low", "medium", "high"

  TelemetryData({
    required this.id,
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    this.voltage,
    required this.state,
    required this.connMode,
    required this.heaterStatus,
    required this.fanStatus,
    required this.powerStatus,
    this.errorCode,
    required this.timestamp,
    required this.stateLabel,
    required this.connModeLabel,
    this.soc = 0,
    this.water = 0,
    this.paygStatus = 0,
    this.mode = 0,
    this.tempWeek1,
    this.tempWeek2,
    this.tempWeek3,
    this.tempWeek4,
    this.modeLabel = '',
    this.waterLevelLabel = '',
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    // meta sub-object (new format nests several fields here)
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return TelemetryData(
      id: TypeUtils.toStringSafe(json['id']),
      deviceId: TypeUtils.toStringSafe(json['device_id']),
      temperature: TypeUtils.toDoubleSafe(json['temp'] ?? json['temperature']),
      humidity: TypeUtils.toDoubleSafe(json['humidity']),
      voltage: json['voltage'] != null ? TypeUtils.toDoubleSafe(json['voltage']) : null,
      state: TypeUtils.toIntSafe(json['state']),
      connMode: TypeUtils.toIntSafe(json['conn_mode']),
      heaterStatus: TypeUtils.toBoolSafe(json['heater_status']),
      fanStatus: TypeUtils.toBoolSafe(json['fan_status']),
      powerStatus: TypeUtils.toBoolSafe(json['power_status']),
      errorCode: TypeUtils.toNullableStringSafe(json['error_code']),
      timestamp: TypeUtils.toDateTimeSafe(json['timestamp']) ?? DateTime.now(),
      stateLabel: TypeUtils.toStringSafe(json['state_label']),
      connModeLabel: TypeUtils.toStringSafe(json['conn_mode_label']),
      // battery: root batt_percentage → meta battery_percent → legacy soc
      soc: TypeUtils.toIntSafe(
        json['batt_percentage'] ?? meta['battery_percent'] ?? json['soc'],
      ),
      // water / payg / mode / weekly temps come from meta in new format
      water: TypeUtils.toIntSafe(meta['water'] ?? json['water']),
      paygStatus: TypeUtils.toIntSafe(meta['payg_status'] ?? json['payg_status']),
      mode: TypeUtils.toIntSafe(meta['mode'] ?? json['mode']),
      tempWeek1: _intFromMeta(meta, 'temp_week1') ?? _intFromJson(json, 'temp_week1'),
      tempWeek2: _intFromMeta(meta, 'temp_week2') ?? _intFromJson(json, 'temp_week2'),
      tempWeek3: _intFromMeta(meta, 'temp_week3') ?? _intFromJson(json, 'temp_week3'),
      tempWeek4: _intFromMeta(meta, 'temp_week4') ?? _intFromJson(json, 'temp_week4'),
      modeLabel: TypeUtils.toStringSafe(json['mode_label']),
      waterLevelLabel: TypeUtils.toStringSafe(json['water_level_label']),
    );
  }

  static int? _intFromMeta(Map<String, dynamic> meta, String key) =>
      meta[key] != null ? TypeUtils.toIntSafe(meta[key]) : null;

  static int? _intFromJson(Map<String, dynamic> json, String key) =>
      json[key] != null ? TypeUtils.toIntSafe(json[key]) : null;
}

class DeviceAlert {
  final String alertId;
  final String type;
  final String severity;
  final String message;

  DeviceAlert({
    required this.alertId,
    required this.type,
    required this.severity,
    required this.message,
  });

  factory DeviceAlert.fromJson(Map<String, dynamic> json) {
    return DeviceAlert(
      alertId: TypeUtils.toStringSafe(json['alertId']),
      type: TypeUtils.toStringSafe(json['type']),
      severity: TypeUtils.toStringSafe(json['severity']),
      message: TypeUtils.toStringSafe(json['message']),
    );
  }

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFD32F2F);
      case 'medium':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF388E3C);
    }
  }
}
