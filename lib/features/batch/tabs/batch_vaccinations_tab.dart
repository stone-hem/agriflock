import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchVaccinationsTab extends StatelessWidget {
  final Map<String, dynamic> batch;

  const BatchVaccinationsTab({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vaccination Summary
            Row(
              children: [
                Expanded(
                  child: _VaccinationMetricCard(
                    value: '3',
                    label: 'Completed',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VaccinationMetricCard(
                    value: '2',
                    label: 'Upcoming',
                    color: Colors.orange,
                    icon: Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _VaccinationMetricCard(
                    value: '1',
                    label: 'Overdue',
                    color: Colors.red,
                    icon: Icons.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _VaccinationMetricCard(
                    value: '95%',
                    label: 'Coverage',
                    color: Colors.blue,
                    icon: Icons.health_and_safety,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upcoming & Recent Vaccinations & Recommended Schedule
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(6),
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade600,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        tabs: [
                          _buildTabWithIcon(Icons.upcoming, 'Upcoming'),
                          _buildTabWithIcon(Icons.history, 'History'),
                          _buildTabWithIcon(Icons.schedule, 'Schedule'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Upcoming Tab
                          ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TextButton.icon(
                                  onPressed: () {
                                    context.push('/batches/schedule');
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Schedule New Vaccination'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                ),
                              ),
                              _VaccinationItem(
                                vaccineName: 'Newcastle Disease',
                                date: 'Due: Dec 15, 2023',
                                status: 'Scheduled',
                                statusColor: Colors.orange,
                                dosage: '0.5ml per bird',
                                administered: false,
                                onCancel: () {
                                  _showCancelDialog(context, 'Newcastle Disease', 'Dec 15, 2023');
                                },
                              ),
                              _VaccinationItem(
                                vaccineName: 'Infectious Bronchitis',
                                date: 'Due: Dec 20, 2023',
                                status: 'Scheduled',
                                statusColor: Colors.orange,
                                dosage: '0.3ml per bird',
                                administered: false,
                                onCancel: () {
                                  _showCancelDialog(context, 'Infectious Bronchitis', 'Dec 20, 2023');
                                },
                              ),
                              _VaccinationItem(
                                vaccineName: 'Fowl Pox',
                                date: 'Overdue: Dec 5, 2023',
                                status: 'Overdue',
                                statusColor: Colors.red,
                                dosage: 'Wing-stab method',
                                administered: false,
                                onCancel: () {
                                  _showCancelDialog(context, 'Fowl Pox', 'Dec 5, 2023');
                                },
                              ),
                            ],
                          ),
                          // History Tab
                          ListView(
                            children: [
                              _VaccinationItem(
                                vaccineName: 'Marek\'s Disease',
                                date: 'Administered: Nov 20, 2023',
                                status: 'Completed',
                                statusColor: Colors.green,
                                dosage: '0.2ml per bird',
                                administered: true,
                                onCancel: null,
                              ),
                              _VaccinationItem(
                                vaccineName: 'Gumboro',
                                date: 'Administered: Oct 15, 2023',
                                status: 'Completed',
                                statusColor: Colors.green,
                                dosage: '0.5ml per bird',
                                administered: true,
                                onCancel: null,
                              ),
                              _VaccinationItem(
                                vaccineName: 'Avian Influenza',
                                date: 'Administered: Sep 10, 2023',
                                status: 'Completed',
                                statusColor: Colors.green,
                                dosage: '0.3ml per bird',
                                administered: true,
                                onCancel: null,
                              ),
                            ],
                          ),
                          // Recommended Schedule Tab
                          ListView(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.download),
                                        label: const Text('Adopt All Schedule'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Standard vaccination schedule for poultry',
                                          style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _RecommendedVaccinationItem(
                                vaccineName: 'Marek\'s Disease',
                                timing: 'Day 1 (at hatchery)',
                                method: 'Subcutaneous injection',
                                dosage: '0.2ml per chick',
                                description: 'Protects against Marek\'s disease virus',
                              ),
                              _RecommendedVaccinationItem(
                                vaccineName: 'Newcastle Disease (ND)',
                                timing: 'Day 7-10',
                                method: 'Eye/nose drop or drinking water',
                                dosage: '1 drop or as per vaccine instructions',
                                description: 'First dose for respiratory protection',
                              ),
                              _RecommendedVaccinationItem(
                                vaccineName: 'Infectious Bursal Disease (Gumboro)',
                                timing: 'Day 10-14',
                                method: 'Drinking water',
                                dosage: 'As per vaccine instructions',
                                description: 'Protects immune system development',
                              ),
                              _RecommendedVaccinationItem(
                                vaccineName: 'Newcastle Disease (Booster)',
                                timing: 'Day 21-28',
                                method: 'Drinking water or spray',
                                dosage: '1 dose per bird',
                                description: 'Booster for enhanced immunity',
                              ),
                              _RecommendedVaccinationItem(
                                vaccineName: 'Infectious Bronchitis (IB)',
                                timing: 'Day 14-21',
                                method: 'Eye drop or spray',
                                dosage: '0.3ml per bird',
                                description: 'Protects against respiratory disease',
                              ),
                              _RecommendedVaccinationItem(
                                vaccineName: 'Fowl Pox',
                                timing: 'Week 6-8',
                                method: 'Wing-web stab',
                                dosage: '1 puncture per bird',
                                description: 'Long-lasting immunity against pox',
                              ),
                              _RecommendedVaccinationItem(
                                vaccineName: 'Gumboro (Booster)',
                                timing: 'Day 21-28',
                                method: 'Drinking water',
                                dosage: 'As per vaccine instructions',
                                description: 'Booster for enhanced protection',
                              ),
                              _RecommendedVaccinationItem(
                                vaccineName: 'Avian Influenza',
                                timing: 'Week 8-12 (if required)',
                                method: 'Subcutaneous or intramuscular',
                                dosage: '0.5ml per bird',
                                description: 'Protection against avian flu strains',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/batches/vaccination');
        },
        icon: const Icon(Icons.add),
        label: const Text('Record Vaccination'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String vaccineName, String date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel $vaccineName'),
        content: Text('This vaccination is scheduled for $date. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show reschedule dialog/functionality
              _showRescheduleDialog(context, vaccineName, date);
            },
            child: const Text('Reschedule'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Cancel entirely logic
              _showConfirmCancelDialog(context, vaccineName);
            },
            child: const Text('Cancel Entirely'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep as Scheduled'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, String vaccineName, String date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reschedule $vaccineName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new date for the vaccination:'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: CalendarDatePicker(
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (newDate) {
                  // Handle date selection
                  print('New date selected: $newDate');
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Handle reschedule logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$vaccineName rescheduled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }

  void _showConfirmCancelDialog(BuildContext context, String vaccineName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: Text('Are you sure you want to cancel $vaccineName vaccination? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          FilledButton(
            onPressed: () {
              // Handle cancellation logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$vaccineName vaccination cancelled'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithIcon(IconData icon, String label) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _VaccinationMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _VaccinationMetricCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccinationItem extends StatelessWidget {
  final String vaccineName;
  final String date;
  final String status;
  final Color statusColor;
  final String dosage;
  final bool administered;
  final VoidCallback? onCancel;

  const _VaccinationItem({
    required this.vaccineName,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.dosage,
    required this.administered,
    this.onCancel,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: administered
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              administered ? Icons.health_and_safety : Icons.schedule,
              size: 18,
              color: administered ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccineName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dosage,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!administered && onCancel != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red.shade600, size: 20),
                  onPressed: onCancel,
                  tooltip: 'Cancel vaccination',
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendedVaccinationItem extends StatelessWidget {
  final String vaccineName;
  final String timing;
  final String method;
  final String dosage;
  final String description;

  const _RecommendedVaccinationItem({
    required this.vaccineName,
    required this.timing,
    required this.method,
    required this.dosage,
    required this.description,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timing,
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                child: FilledButton(
                  onPressed: () {
                    // Adopt this specific schedule item
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Adopted $vaccineName schedule'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    'Adopt',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.medical_services,
                  label: 'Method',
                  value: method,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.water_drop,
                  label: 'Dosage',
                  value: dosage,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.info_outline,
                  label: 'Purpose',
                  value: description,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}