import 'package:agriflock360/core/utils/type_safe_utils.dart';

class DeviceListResponse {
  final List<DeviceItem> devices;

  DeviceListResponse({required this.devices});

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) {
    return DeviceListResponse(
      devices: List<DeviceItem>.from(
        (json['devices'] as List<dynamic>? ?? [])
            .map((device) => DeviceItem.fromJson(device as Map<String, dynamic>)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'devices': devices.map((d) => d.toJson()).toList(),
  };
}

class DeviceStatus {
  final String id;
  final String name;
  final String desc;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceStatus({
    required this.id,
    required this.name,
    required this.desc,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      desc: TypeUtils.toStringSafe(json['desc']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'desc': desc,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class DeviceItem {
  final String id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String? brooderId;
  final String ownerId;
  final String? deviceStatusId;
  final DeviceStatus? deviceStatus;
  final String? firmwareVersionId;
  final String? lastSeen;
  final String? apiKeyCreatedAt;
  final bool isPaygLocked;
  final double paygBalance;
  final String? installationDate;
  final String? warrantyExpiry;
  final String? mqttTopicPrefix;
  final String? wifiSsid;
  final String? location;
  final String? subscriptionId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceItem({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.brooderId,
    required this.ownerId,
    this.deviceStatusId,
    this.deviceStatus,
    this.firmwareVersionId,
    this.lastSeen,
    this.apiKeyCreatedAt,
    required this.isPaygLocked,
    required this.paygBalance,
    this.installationDate,
    this.warrantyExpiry,
    this.mqttTopicPrefix,
    this.wifiSsid,
    this.location,
    this.subscriptionId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceItem.fromJson(Map<String, dynamic> json) {
    final statusMap = TypeUtils.toMapSafe(json['device_status']);
    return DeviceItem(
      id: TypeUtils.toStringSafe(json['id']),
      deviceId: TypeUtils.toStringSafe(json['device_id']),
      deviceName: TypeUtils.toStringSafe(json['device_name']),
      deviceType: TypeUtils.toStringSafe(json['device_type']),
      brooderId: TypeUtils.toNullableStringSafe(json['brooder_id']),
      ownerId: TypeUtils.toStringSafe(json['owner_id']),
      deviceStatusId: TypeUtils.toNullableStringSafe(json['device_status_id']),
      deviceStatus: statusMap != null ? DeviceStatus.fromJson(statusMap) : null,
      firmwareVersionId: TypeUtils.toNullableStringSafe(json['firmware_version_id']),
      lastSeen: TypeUtils.toNullableStringSafe(json['last_seen']),
      apiKeyCreatedAt: TypeUtils.toNullableStringSafe(json['api_key_created_at']),
      isPaygLocked: TypeUtils.toBoolSafe(json['is_payg_locked']),
      paygBalance: TypeUtils.toDoubleSafe(json['payg_balance']),
      installationDate: TypeUtils.toNullableStringSafe(json['installation_date']),
      warrantyExpiry: TypeUtils.toNullableStringSafe(json['warranty_expiry']),
      mqttTopicPrefix: TypeUtils.toNullableStringSafe(json['mqtt_topic_prefix']),
      wifiSsid: TypeUtils.toNullableStringSafe(json['wifi_ssid']),
      location: TypeUtils.toNullableStringSafe(json['location']),
      subscriptionId: TypeUtils.toNullableStringSafe(json['subscription_id']),
      notes: TypeUtils.toNullableStringSafe(json['notes']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'device_id': deviceId,
    'device_name': deviceName,
    'device_type': deviceType,
    'brooder_id': brooderId,
    'owner_id': ownerId,
    'device_status_id': deviceStatusId,
    'device_status': deviceStatus?.toJson(),
    'firmware_version_id': firmwareVersionId,
    'last_seen': lastSeen,
    'api_key_created_at': apiKeyCreatedAt,
    'is_payg_locked': isPaygLocked,
    'payg_balance': paygBalance,
    'installation_date': installationDate,
    'warranty_expiry': warrantyExpiry,
    'mqtt_topic_prefix': mqttTopicPrefix,
    'wifi_ssid': wifiSsid,
    'location': location,
    'subscription_id': subscriptionId,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  bool get isOnline => lastSeen != null;
  bool get isRegistered => deviceStatus?.name == 'registered';
  bool get isActive => deviceStatus?.name == 'active';
  bool get isSmartBrooder => deviceType == 'smart_brooder';

  String get statusLabel => deviceStatus?.name ?? 'unknown';

  String get formattedLastSeen {
    if (lastSeen == null) return 'Never';
    try {
      final date = DateTime.parse(lastSeen!);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Unknown';
    }
  }
}