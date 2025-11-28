// lib/telemetry/telemetry_data_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TelemetryDataScreen extends StatefulWidget {
  const TelemetryDataScreen({super.key});

  @override
  State<TelemetryDataScreen> createState() => _TelemetryDataScreenState();
}

class _TelemetryDataScreenState extends State<TelemetryDataScreen> {
  final List<BrooderDevice> _brooders = [
    BrooderDevice(
      id: 'BRD-001',
      name: 'Main Brooder House',
      status: DeviceStatus.normal,
      temperature: 32.5,
      humidity: 65.0,
      feedLevel: 75.0,
      waterLevel: 90.0,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
      location: 'Section A',
      birdCount: 450,
    ),
    BrooderDevice(
      id: 'BRD-002',
      name: 'Nursery Brooder',
      status: DeviceStatus.warning,
      temperature: 29.8,
      humidity: 72.0,
      feedLevel: 25.0,
      waterLevel: 85.0,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
      location: 'Section B',
      birdCount: 280,
    ),
    BrooderDevice(
      id: 'BRD-003',
      name: 'Isolation Unit',
      status: DeviceStatus.critical,
      temperature: 35.2,
      humidity: 58.0,
      feedLevel: 90.0,
      waterLevel: 30.0,
      lastUpdate: DateTime.now().subtract(const Duration(minutes: 10)),
      location: 'Section C',
      birdCount: 120,
    ),
  ];

  bool _isRefreshing = false;

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call to fetch latest data
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      // Update data with new values (in real app, this would come from API)
      _brooders[0] = _brooders[0].copyWith(
        temperature: 32.2 + (DateTime.now().second % 10) * 0.1,
        lastUpdate: DateTime.now(),
      );
      _brooders[1] = _brooders[1].copyWith(
        feedLevel: 20.0 + (DateTime.now().second % 5) * 1.0,
        lastUpdate: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Telementary Data'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.green.shade700,
            ),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Status Overview
              _buildLiveStatusOverview(),
              const SizedBox(height: 24),

              // Brooder Devices List
              _buildBroodersList(),

              // Charts Section
              _buildChartsSection(),

              // Historical Data
              _buildHistoricalData(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatusOverview() {
    final activeBrooders = _brooders.length;
    final warningCount = _brooders.where((b) => b.status == DeviceStatus.warning).length;
    final criticalCount = _brooders.where((b) => b.status == DeviceStatus.critical).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.lightBlue.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Live Brooder Data',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatusIndicator(
                count: activeBrooders,
                label: 'Active',
                color: Colors.green,
              ),
              const SizedBox(width: 16),
              _StatusIndicator(
                count: warningCount,
                label: 'Warning',
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _StatusIndicator(
                count: criticalCount,
                label: 'Critical',
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Last updated: ${_getLastUpdateTime()}',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroodersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brooder Devices',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ..._brooders.map((brooder) => _BrooderCard(brooder: brooder)),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'Environmental Trends',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _MetricChart(
              title: 'Temperature',
              value: '32.5°C',
              subtitle: 'Ideal: 30-35°C',
              color: Colors.orange,
              trend: ChartTrend.up,
            ),
            _MetricChart(
              title: 'Humidity',
              value: '65%',
              subtitle: 'Ideal: 60-70%',
              color: Colors.blue,
              trend: ChartTrend.stable,
            ),
            _MetricChart(
              title: 'Feed Level',
              value: '75%',
              subtitle: 'Refill at 20%',
              color: Colors.green,
              trend: ChartTrend.down,
            ),
            _MetricChart(
              title: 'Water Level',
              value: '90%',
              subtitle: 'Refill at 25%',
              color: Colors.cyan,
              trend: ChartTrend.stable,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoricalData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'Recent Readings',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DataTableRow(
                  parameter: 'Temperature',
                  current: '32.5°C',
                  average: '32.1°C',
                  min: '29.8°C',
                  max: '35.2°C',
                ),
                _DataTableRow(
                  parameter: 'Humidity',
                  current: '65%',
                  average: '67%',
                  min: '58%',
                  max: '72%',
                ),
                _DataTableRow(
                  parameter: 'Feed Consumption',
                  current: '25kg/day',
                  average: '23kg/day',
                  min: '18kg/day',
                  max: '28kg/day',
                ),
                _DataTableRow(
                  parameter: 'Water Usage',
                  current: '45L/day',
                  average: '42L/day',
                  min: '35L/day',
                  max: '50L/day',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getLastUpdateTime() {
    final now = DateTime.now();
    final lastUpdate = _brooders.map((b) => b.lastUpdate).reduce(
          (a, b) => a.isAfter(b) ? a : b,
    );
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return '${difference.inHours} hours ago';
    }
  }
}

enum DeviceStatus { normal, warning, critical }

enum ChartTrend { up, down, stable }

class BrooderDevice {
  final String id;
  final String name;
  final DeviceStatus status;
  final double temperature;
  final double humidity;
  final double feedLevel;
  final double waterLevel;
  final DateTime lastUpdate;
  final String location;
  final int birdCount;

  const BrooderDevice({
    required this.id,
    required this.name,
    required this.status,
    required this.temperature,
    required this.humidity,
    required this.feedLevel,
    required this.waterLevel,
    required this.lastUpdate,
    required this.location,
    required this.birdCount,
  });

  BrooderDevice copyWith({
    double? temperature,
    double? humidity,
    double? feedLevel,
    double? waterLevel,
    DateTime? lastUpdate,
  }) {
    return BrooderDevice(
      id: id,
      name: name,
      status: status,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      feedLevel: feedLevel ?? this.feedLevel,
      waterLevel: waterLevel ?? this.waterLevel,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      location: location,
      birdCount: birdCount,
    );
  }

  Color get statusColor {
    switch (status) {
      case DeviceStatus.normal:
        return Colors.green;
      case DeviceStatus.warning:
        return Colors.orange;
      case DeviceStatus.critical:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case DeviceStatus.normal:
        return 'Normal';
      case DeviceStatus.warning:
        return 'Warning';
      case DeviceStatus.critical:
        return 'Critical';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case DeviceStatus.normal:
        return Icons.check_circle_outline;
      case DeviceStatus.warning:
        return Icons.warning_amber_outlined;
      case DeviceStatus.critical:
        return Icons.error_outline;
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatusIndicator({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrooderCard extends StatelessWidget {
  final BrooderDevice brooder;

  const _BrooderCard({
    required this.brooder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: brooder.statusColor.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: brooder.statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    brooder.statusIcon,
                    size: 20,
                    color: brooder.statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brooder.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ID: ${brooder.id} • ${brooder.location}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: brooder.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: brooder.statusColor.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    brooder.statusText,
                    style: TextStyle(
                      color: brooder.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Metrics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _MetricTile(
                  label: 'Temperature',
                  value: '${brooder.temperature}°C',
                  icon: Icons.thermostat_outlined,
                  color: Colors.orange,
                  isCritical: brooder.temperature < 30 || brooder.temperature > 35,
                ),
                _MetricTile(
                  label: 'Humidity',
                  value: '${brooder.humidity}%',
                  icon: Icons.water_drop_outlined,
                  color: Colors.blue,
                  isCritical: brooder.humidity < 60 || brooder.humidity > 70,
                ),
                _MetricTile(
                  label: 'Feed Level',
                  value: '${brooder.feedLevel}%',
                  icon: Icons.restaurant_outlined,
                  color: Colors.green,
                  isCritical: brooder.feedLevel < 20,
                ),
                _MetricTile(
                  label: 'Water Level',
                  value: '${brooder.waterLevel}%',
                  icon: Icons.invert_colors_on_outlined,
                  color: Colors.cyan,
                  isCritical: brooder.waterLevel < 25,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Icon(Icons.groups_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${brooder.birdCount} birds',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(Icons.schedule_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  _formatTimeAgo(brooder.lastUpdate),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCritical;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isCritical,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.shade50 : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? Colors.red.shade200 : color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isCritical ? Colors.red : color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isCritical ? Colors.red : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isCritical ? Colors.red : color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChart extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final ChartTrend trend;

  const _MetricChart({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTrendIcon(),
                    size: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            // Simple chart visualization
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTrendIcon() {
    switch (trend) {
      case ChartTrend.up:
        return Icons.trending_up;
      case ChartTrend.down:
        return Icons.trending_down;
      case ChartTrend.stable:
        return Icons.trending_flat;
    }
  }
}

class _DataTableRow extends StatelessWidget {
  final String parameter;
  final String current;
  final String average;
  final String min;
  final String max;

  const _DataTableRow({
    required this.parameter,
    required this.current,
    required this.average,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              parameter,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
                Text(
                  current,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
                Text(
                  average,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Range',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '$min-$max',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}