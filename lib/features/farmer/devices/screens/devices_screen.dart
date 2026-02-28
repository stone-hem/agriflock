import 'package:agriflock/app_routes.dart';
import 'package:agriflock/features/farmer/devices/models/device_model.dart';
import 'package:agriflock/features/farmer/devices/repository/devices_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _telemetryRoute = '/my-devices/telemetry';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final DevicesRepository _repository = DevicesRepository();

  List<DeviceItem> _devices = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() => _isRefreshing = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _repository.getMyDevices();

    result.when(
      success: (devices) {
        setState(() {
          _devices = devices;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
        });
      },
      failure: (message, response, statusCode) {
        setState(() {
          _errorMessage = message;
          _isLoading = false;
          _isRefreshing = false;
        });
      },
    );
  }

  Future<void> _refreshData() => _fetchDevices(isRefresh: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(Icons.image, size: 40, color: Colors.white54),
                );
              },
            ),
            const SizedBox(width: 8),
            const Text('My Devices'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.green.shade700),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_devices.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 24),
            _buildDevicesList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load devices',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No devices found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No devices have been assigned to your account yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final total = _devices.length;
    final online = _devices.where((d) => d.isOnline).length;
    final locked = _devices.where((d) => d.isPaygLocked).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.teal.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.router_outlined, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Device Overview',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _OverviewStat(count: total, label: 'Total', color: Colors.blue),
              const SizedBox(width: 12),
              _OverviewStat(count: online, label: 'Online', color: Colors.green),
              const SizedBox(width: 12),
              _OverviewStat(count: locked, label: 'PAYG Locked', color: Colors.orange),
            ],
          ),
          if (_isRefreshing) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              color: Colors.green.shade400,
              backgroundColor: Colors.green.shade100,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Devices',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ..._devices.map((device) => _DeviceCard(device: device)),
      ],
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _OverviewStat({
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
          border: Border.all(color: color.withValues(alpha: 0.2)),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final DeviceItem device;

  const _DeviceCard({required this.device});

  Color get _statusColor {
    switch (device.statusLabel.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'registered':
        return Colors.blue;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData get _statusIcon {
    switch (device.statusLabel.toLowerCase()) {
      case 'active':
        return Icons.check_circle_outline;
      case 'registered':
        return Icons.app_registration_outlined;
      case 'inactive':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _statusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon, size: 20, color: _statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        device.deviceImei,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(label: device.statusLabel, color: _statusColor),
              ],
            ),
            const SizedBox(height: 16),

            // Details grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.memory_outlined,
                  label: device.deviceType.replaceAll('_', ' ').toUpperCase(),
                  color: Colors.purple,
                ),
                if (device.location != null)
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: device.location!,
                    color: Colors.teal,
                  ),
                _InfoChip(
                  icon: device.isOnline ? Icons.wifi : Icons.wifi_off,
                  label: device.isOnline ? 'Online' : 'Offline',
                  color: device.isOnline ? Colors.green : Colors.grey,
                ),
                if (device.isPaygLocked)
                  _InfoChip(
                    icon: Icons.lock_outline,
                    label: 'PAYG Locked',
                    color: Colors.orange,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  'Last seen: ${device.formattedLastSeen}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),

            if (device.mqttTopicPrefix != null) ...[
             Row(children: [
               Icon(Icons.cloud_outlined, size: 14, color: Colors.grey.shade400),
               const SizedBox(width: 4),
               Text(
                 device.mqttTopicPrefix!,
                 style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
               ),
             ],)
            ],


            if (device.notes != null && device.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        device.notes!,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (context) => ElevatedButton.icon(
                  onPressed: () => context.push(
                    _telemetryRoute,
                    extra: device,
                  ),
                  icon: const Icon(Icons.sensors, size: 16),
                  label: const Text('View Live Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            if (device.isPaygLocked) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (context) => OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.paygIntro, extra: device),
                    icon: const Icon(Icons.credit_card_outlined, size: 16),
                    label: const Text('Manage Device Lease'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}