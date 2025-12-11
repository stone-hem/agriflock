// lib/vet/schedules/vet_schedules_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetSchedulesScreen extends StatelessWidget {
  const VetSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('My Schedules'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Navigation
            _buildDateNavigation(),
            const SizedBox(height: 24),

            // Schedule Stats
            _buildScheduleStats(),
            const SizedBox(height: 32),

            // Today's Schedule
            _buildTodaysSchedule(context),
            const SizedBox(height: 32),

            // Upcoming Appointments
            _buildUpcomingAppointments(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.grey.shade700),
            onPressed: () {},
          ),
          Column(
            children: [
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dec 11, 2023',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.grey.shade700),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStats() {
    return Row(
      children: [
        Expanded(
          child: _ScheduleStatCard(
            value: '3',
            label: 'Confirmed',
            color: Colors.green.shade100,
            textColor: Colors.green.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ScheduleStatCard(
            value: '2',
            label: 'Pending',
            color: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ScheduleStatCard(
            value: '1',
            label: 'Completed',
            color: Colors.blue.shade100,
            textColor: Colors.blue.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysSchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Visits",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Add Slot',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ScheduleTimeSlot(
          time: '9:00 AM - 10:30 AM',
          farmerName: 'John Peterson',
          farmName: 'Green Valley Farm',
          status: 'Confirmed',
          birdsCount: '1,240',
          type: 'Regular Checkup',
          color: Colors.green,
        ),
        _ScheduleTimeSlot(
          time: '11:30 AM - 1:00 PM',
          farmerName: 'Maria Rodriguez',
          farmName: 'Sunrise Poultry',
          status: 'Confirmed',
          birdsCount: '890',
          type: 'Vaccination',
          color: Colors.blue,
        ),
        _ScheduleTimeSlot(
          time: '2:00 PM - 3:30 PM',
          farmerName: 'Robert Chen',
          farmName: 'Happy Hens Farm',
          status: 'Pending',
          birdsCount: '2,150',
          type: 'Emergency Visit',
          color: Colors.orange,
        ),
        _ScheduleTimeSlot(
          time: '4:00 PM - 5:30 PM',
          farmerName: 'Available Slot',
          farmName: 'Open for booking',
          status: 'Available',
          birdsCount: '',
          type: 'Book Now',
          color: Colors.grey,
          isAvailable: true,
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Appointments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        _UpcomingAppointmentItem(
          date: 'Tomorrow',
          time: '10:00 AM',
          farmerName: 'David Wilson',
          farmName: 'Wilson Farms',
          type: 'Health Inspection',
          status: 'Confirmed',
        ),
        _UpcomingAppointmentItem(
          date: 'Dec 13',
          time: '2:30 PM',
          farmerName: 'Sarah Miller',
          farmName: 'Miller Poultry',
          type: 'Follow-up Visit',
          status: 'Confirmed',
        ),
        _UpcomingAppointmentItem(
          date: 'Dec 14',
          time: '11:00 AM',
          farmerName: 'James Brown',
          farmName: 'Brown\'s Farm',
          type: 'New Farm Setup',
          status: 'Pending',
        ),
      ],
    );
  }
}

class _ScheduleStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _ScheduleStatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTimeSlot extends StatelessWidget {
  final String time;
  final String farmerName;
  final String farmName;
  final String status;
  final String birdsCount;
  final String type;
  final Color color;
  final bool isAvailable;

  const _ScheduleTimeSlot({
    required this.time,
    required this.farmerName,
    required this.farmName,
    required this.status,
    required this.birdsCount,
    required this.type,
    required this.color,
    this.isAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? Colors.blue.shade100 : Colors.grey.shade200,
          width: isAvailable ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isAvailable ? Colors.blue.shade700 : Colors.grey.shade800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isAvailable) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        farmName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.medical_services, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  type,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (birdsCount.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.pets, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '$birdsCount birds',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      farmerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  farmName,
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Set as Unavailable'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'available':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _UpcomingAppointmentItem extends StatelessWidget {
  final String date;
  final String time;
  final String farmerName;
  final String farmName;
  final String type;
  final String status;

  const _UpcomingAppointmentItem({
    required this.date,
    required this.time,
    required this.farmerName,
    required this.farmName,
    required this.type,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  date.split(' ')[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    fontSize: 12,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  farmName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      type,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Confirmed'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'Confirmed' ? Colors.green : Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}