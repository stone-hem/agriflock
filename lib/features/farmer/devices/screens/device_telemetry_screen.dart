import 'dart:async';

import 'package:agriflock/features/farmer/devices/models/device_model.dart';
import 'package:agriflock/features/farmer/devices/models/telemetry_model.dart';
import 'package:agriflock/features/farmer/devices/services/device_telemetry_service.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceTelemetryScreen extends StatefulWidget {
  final DeviceItem device;

  const DeviceTelemetryScreen({super.key, required this.device});

  @override
  State<DeviceTelemetryScreen> createState() => _DeviceTelemetryScreenState();
}

class _DeviceTelemetryScreenState extends State<DeviceTelemetryScreen> {
  late final DeviceTelemetryService _service;

  TelemetryData? _latestTelemetry;
  final List<DeviceAlert> _alerts = [];
  bool _isConnected = false;
  StreamSubscription<TelemetryData>? _telemetrySub;
  StreamSubscription<DeviceAlert>? _alertSub;

  @override
  void initState() {
    super.initState();
    _service = DeviceTelemetryService(
      deviceId: widget.device.id,
      storage: secureStorage,
    );
    _connect();
  }

  Future<void> _connect() async {
    _telemetrySub = _service.telemetryStream.listen((data) {
      setState(() {
        _latestTelemetry = data;
        _isConnected = true;
      });
    });

    _alertSub = _service.alertStream.listen((alert) {
      setState(() {
        _alerts.insert(0, alert);
      });
    });

    await _service.connect();
    // Mark connected visually after a brief delay if no telemetry yet
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isConnected) {
        setState(() => _isConnected = true);
      }
    });
  }

  @override
  void dispose() {
    _telemetrySub?.cancel();
    _alertSub?.cancel();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionBanner(),
            const SizedBox(height: 12),
            if (_alerts.isNotEmpty) _buildAlertBanner(_alerts.first),
            if (_alerts.isNotEmpty) const SizedBox(height: 12),
            _buildDeviceInfoCard(),
            const SizedBox(height: 16),
            _buildTelemetryGrid(),
            const SizedBox(height: 16),
            _buildStatusRow(),
            if (_alerts.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAlertsSection(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.device.deviceName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Live Telemetry',
            style: TextStyle(fontSize: 11, color: Colors.green.shade700),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
        onPressed: () => context.pop(),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildConnectionBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _isConnected
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isConnected
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected ? 'Connected — Receiving live data' : 'Connecting to device...',
            style: TextStyle(
              color: _isConnected ? Colors.green.shade800 : Colors.orange.shade800,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!_isConnected) ...[
            const Spacer(),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertBanner(DeviceAlert alert) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alert.severityColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alert.severityColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_rounded, color: alert.severityColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.type.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: alert.severityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: TextStyle(color: alert.severityColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.memory_outlined, color: Colors.green.shade700, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.device.deviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.device.deviceImei,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                if (widget.device.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.teal.shade600),
                      const SizedBox(width: 2),
                      Text(
                        widget.device.location!,
                        style: TextStyle(color: Colors.teal.shade700, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (_latestTelemetry != null)
            Text(
              _formatTime(_latestTelemetry!.timestamp.toLocal()),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid() {
    final telemetry = _latestTelemetry;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _MetricCard(
          icon: Icons.thermostat_outlined,
          label: 'Temperature',
          value: telemetry != null ? '${telemetry.temperature.toStringAsFixed(1)}°C' : '--',
          color: _tempColor(telemetry?.temperature),
          subtitle: _tempStatus(telemetry?.temperature),
        ),
        _MetricCard(
          icon: Icons.water_drop_outlined,
          label: 'Humidity',
          value: telemetry != null ? '${telemetry.humidity.toStringAsFixed(1)}%' : '--',
          color: _humidityColor(telemetry?.humidity),
          subtitle: _humidityStatus(telemetry?.humidity),
        ),
        _MetricCard(
          icon: Icons.bolt_outlined,
          label: 'Voltage',
          value: telemetry?.voltage != null
              ? '${telemetry!.voltage!.toStringAsFixed(1)}V'
              : 'N/A',
          color: Colors.purple,
          subtitle: 'Supply Voltage',
        ),
        _MetricCard(
          icon: Icons.settings_suggest_outlined,
          label: 'State',
          value: telemetry != null
              ? telemetry.stateLabel.replaceAll('-', ' ').toUpperCase()
              : '--',
          color: Colors.teal,
          subtitle: telemetry != null ? 'Mode: ${telemetry.connModeLabel}' : '',
          isSmallText: true,
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    final telemetry = _latestTelemetry;
    return Row(
      children: [
        Expanded(
          child: _StatusTile(
            icon: Icons.local_fire_department_outlined,
            label: 'Heater',
            isActive: telemetry?.heaterStatus ?? false,
            activeColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusTile(
            icon: Icons.air_outlined,
            label: 'Fan',
            isActive: telemetry?.fanStatus ?? false,
            activeColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusTile(
            icon: Icons.power_settings_new_outlined,
            label: 'Power',
            isActive: telemetry?.powerStatus ?? false,
            activeColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Alerts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        ..._alerts.take(5).map((alert) => _AlertListTile(alert: alert)),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color _tempColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp >= 35) return Colors.red;
    if (temp >= 30) return Colors.orange;
    return Colors.green;
  }

  String _tempStatus(double? temp) {
    if (temp == null) return 'Waiting...';
    if (temp >= 35) return 'High — Alert';
    if (temp >= 30) return 'Elevated';
    return 'Normal';
  }

  Color _humidityColor(double? h) {
    if (h == null) return Colors.grey;
    if (h >= 80) return Colors.red;
    if (h >= 70) return Colors.orange;
    return Colors.blue;
  }

  String _humidityStatus(double? h) {
    if (h == null) return 'Waiting...';
    if (h >= 80) return 'High — Alert';
    if (h >= 70) return 'Elevated';
    return 'Normal';
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String subtitle;
  final bool isSmallText;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.subtitle,
    this.isSmallText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isSmallText ? 13 : 22,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;

  const _StatusTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : Colors.grey.shade400;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isActive ? 'ON' : 'OFF',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertListTile extends StatelessWidget {
  final DeviceAlert alert;

  const _AlertListTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alert.severityColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alert.severityColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: alert.severityColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.type.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: alert.severityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  alert.message,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: alert.severityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              alert.severity.toUpperCase(),
              style: TextStyle(
                color: alert.severityColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
