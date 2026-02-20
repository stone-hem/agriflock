import 'package:agriflock360/core/utils/type_safe_utils.dart';
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
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      id: TypeUtils.toStringSafe(json['id']),
      deviceId: TypeUtils.toStringSafe(json['device_id']),
      temperature: TypeUtils.toDoubleSafe(json['temperature']),
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
    );
  }
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
