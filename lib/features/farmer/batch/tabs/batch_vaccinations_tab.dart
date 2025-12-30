import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/vaccination_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/vaccination_repo.dart';
import 'package:agriflock360/features/farmer/batch/shared/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchVaccinationsTab extends StatefulWidget {
  final BatchModel batch;

  const BatchVaccinationsTab({super.key, required this.batch});

  @override
  State<BatchVaccinationsTab> createState() => _BatchVaccinationsTabState();
}

class _BatchVaccinationsTabState extends State<BatchVaccinationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VaccinationRepository _repository = VaccinationRepository();

  bool _isFabVisible = true;
  final Map<int, ScrollController> _scrollControllers = {};

  // State
  VaccinationDashboard? _dashboard;
  VaccinationsResponse? _vaccinations;
  bool _isDashboardLoading = true;
  bool _isVaccinationsLoading = true;
  String? _dashboardError;
  String? _vaccinationsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    for (int i = 0; i < _tabController.length; i++) {
      _scrollControllers[i] = ScrollController();
      _scrollControllers[i]!.addListener(() {
        _handleScroll(_scrollControllers[i]!, i);
      });
    }

    _tabController.addListener(_handleTabChange);

    // Load data
    _loadDashboard();
    _loadVaccinations();
  }

  Future<void> _loadDashboard() async {
    try {
      setState(() {
        _isDashboardLoading = true;
        _dashboardError = null;
      });

      final data = await _repository.getVaccinationDashboard(widget.batch.id);

      setState(() {
        _dashboard = data;
        _isDashboardLoading = false;
      });
    } catch (e) {
      setState(() {
        _dashboardError = e.toString();
        _isDashboardLoading = false;
      });
    }
  }

  Future<void> _loadVaccinations() async {
    try {
      setState(() {
        _isVaccinationsLoading = true;
        _vaccinationsError = null;
      });

      final data = await _repository.getVaccinations(widget.batch.id);

      setState(() {
        _vaccinations = data;
        _isVaccinationsLoading = false;
      });
    } catch (e) {
      setState(() {
        _vaccinationsError = e.toString();
        _isVaccinationsLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _loadDashboard(),
      _loadVaccinations(),
    ]);
  }

  void _handleScroll(ScrollController controller, int tabIndex) {
    if (controller.hasClients) {
      if (controller.position.pixels > 0 && _isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      } else if (controller.position.pixels <= 0 && !_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
  }

  void _handleTabChange() {
    final currentTab = _tabController.index;
    final currentController = _scrollControllers[currentTab];

    if (currentController != null && currentController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentController.position.pixels > 0 && _isFabVisible) {
          setState(() {
            _isFabVisible = false;
          });
        } else if (currentController.position.pixels <= 0 && !_isFabVisible) {
          setState(() {
            _isFabVisible = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardStats(),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(1),
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
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
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: [
                      _buildTabWithIcon(Icons.upcoming, 'Today'),
                      _buildTabWithIcon(Icons.history, 'History'),
                      _buildTabWithIcon(Icons.schedule, 'Schedule'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTodayTab(),
                        _buildHistoryTab(),
                        _buildScheduleTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1 : 0,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result =
              await context.push('/batches/${widget.batch.id}/quick-done');
              if (result == true) {
                _onRefresh();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Quick done'),
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    if (_isDashboardLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_dashboardError != null || _dashboard == null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error loading stats',
                style: TextStyle(color: Colors.grey.shade600)),
            TextButton(
              onPressed: _loadDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${_dashboard!.summary.completed}',
                label: 'Completed',
                color: Colors.green.shade100,
                textColor: Colors.green.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: '${_dashboard!.summary.upcoming}',
                label: 'Upcoming',
                color: Colors.orange.shade100,
                textColor: Colors.orange.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${_dashboard!.summary.overdue}',
                label: 'Overdue',
                color: Colors.red.shade100,
                textColor: Colors.red.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: _dashboard!.summary.coveragePercentage,
                label: 'Coverage',
                color: Colors.blue.shade100,
                textColor: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _isVaccinationsLoading
          ? const Center(child: CircularProgressIndicator())
          : _vaccinationsError != null || _vaccinations == null
          ? _buildErrorView(_vaccinationsError)
          : _buildTodayContent(),
    );
  }

  Widget _buildTodayContent() {
    final dueToday = _vaccinations!.vaccinations
        .where((v) => v.isDueToday)
        .toList();
    final overdue = _vaccinations!.vaccinations
        .where((v) => v.isOverdue)
        .toList();
    final upcoming = _vaccinations!.vaccinations
        .where((v) => v.isUpcoming)
        .toList();

    return ListView(
      controller: _scrollControllers[0],
      children: [
        if (dueToday.isNotEmpty) ...[
          Text(
            'Due Today',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ...dueToday.map((v) => _VaccinationItem(
            vaccination: v,
            onUpdateStatus: () => _navigateToUpdateStatus(v),
          )),
          const SizedBox(height: 24),
        ],
        if (overdue.isNotEmpty) ...[
          Text(
            'Overdue',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ...overdue.map((v) => _VaccinationItem(
            vaccination: v,
            onUpdateStatus: () => _navigateToUpdateStatus(v),
          )),
          const SizedBox(height: 24),
        ],
        if (upcoming.isNotEmpty) ...[
          Text(
            'Upcoming This Week',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ...upcoming.take(5).map((v) => _VaccinationItem(
            vaccination: v,
            onUpdateStatus: () => _navigateToUpdateStatus(v),
          )),
        ],
        if (dueToday.isEmpty && overdue.isEmpty && upcoming.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No vaccinations scheduled',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _isVaccinationsLoading
          ? const Center(child: CircularProgressIndicator())
          : _vaccinationsError != null || _vaccinations == null
          ? _buildErrorView(_vaccinationsError)
          : _buildHistoryContent(),
    );
  }

  Widget _buildHistoryContent() {
    final completed = _vaccinations!.vaccinations
        .where((v) => v.vaccinationStatus == 'completed')
        .toList();

    if (completed.isEmpty) {
      return Center(
        child: Text(
          'No vaccination history',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView(
      controller: _scrollControllers[1],
      children: completed
          .map((v) => _CompletedVaccinationItem(vaccination: v))
          .toList(),
    );
  }

  Widget _buildScheduleTab() {
    return ListView(
      controller: _scrollControllers[2],
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FilledButton.icon(
            onPressed: () async {
              final result = await context.push(
                  '/batches/${widget.batch.id}/adopt-schedule');
              if (result == true) {
                _onRefresh();
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('Adopt All Schedule'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 48),
            ),
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
                Icon(Icons.info_outline,
                    color: Colors.blue.shade700, size: 20),
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
          onAdopt: () => _navigateToAdopt('Marek\'s Disease'),
        ),
        _RecommendedVaccinationItem(
          vaccineName: 'Newcastle Disease (ND)',
          timing: 'Day 7-10',
          method: 'Eye/nose drop or drinking water',
          dosage: '1 drop or as per vaccine instructions',
          description: 'First dose for respiratory protection',
          onAdopt: () => _navigateToAdopt('Newcastle Disease (ND)'),
        ),
        _RecommendedVaccinationItem(
          vaccineName: 'Infectious Bursal Disease (Gumboro)',
          timing: 'Day 10-14',
          method: 'Drinking water',
          dosage: 'As per vaccine instructions',
          description: 'Protects immune system development',
          onAdopt: () => _navigateToAdopt('Infectious Bursal Disease (Gumboro)'),
        ),
        _RecommendedVaccinationItem(
          vaccineName: 'Newcastle Disease (Booster)',
          timing: 'Day 21-28',
          method: 'Drinking water or spray',
          dosage: '1 dose per bird',
          description: 'Booster for enhanced immunity',
          onAdopt: () => _navigateToAdopt('Newcastle Disease (Booster)'),
        ),
        _RecommendedVaccinationItem(
          vaccineName: 'Fowl Pox',
          timing: 'Week 6-8',
          method: 'Wing-web stab',
          dosage: '1 puncture per bird',
          description: 'Long-lasting immunity against pox',
          onAdopt: () => _navigateToAdopt('Fowl Pox'),
        ),
      ],
    );
  }

  Widget _buildErrorView(String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onRefresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithIcon(IconData icon, String label) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  void _navigateToUpdateStatus(Vaccination vaccination) async {
    final result = await context.push(
      '/batches/${widget.batch.id}/update-status',
      extra: vaccination,
    );
    if (result == true) {
      _onRefresh();
    }
  }

  void _navigateToAdopt(String vaccineName) async {
    final result = await context.push(
      '/batches/${widget.batch.id}/adopt-schedule?item=$vaccineName',
    );
    if (result == true) {
      _onRefresh();
    }
  }
}

class _VaccinationItem extends StatelessWidget {
  final Vaccination vaccination;
  final VoidCallback onUpdateStatus;

  const _VaccinationItem({
    required this.vaccination,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = vaccination.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOverdue ? Icons.warning : Icons.schedule,
                  size: 18,
                  color: isOverdue ? Colors.red : Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccination.vaccineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      vaccination.dosage,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOverdue
                          ? 'Was due: ${DateUtil.toMMDDYYYY(vaccination.scheduledDate)}'
                          : 'Due: ${DateUtil.toMMDDYYYY(vaccination.scheduledDate)}',
                      style: TextStyle(
                        color: isOverdue
                            ? Colors.red.shade700
                            : Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight:
                        isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isOverdue ? Colors.red : Colors.blue)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOverdue ? 'Overdue' : 'Scheduled',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onUpdateStatus,
              style: FilledButton.styleFrom(
                backgroundColor: isOverdue ? Colors.red : Colors.green,
              ),
              child: Text(isOverdue ? 'Update Status (Overdue)' : 'Update Status'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedVaccinationItem extends StatelessWidget {
  final Vaccination vaccination;

  const _CompletedVaccinationItem({
    required this.vaccination,
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
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccination.vaccineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      vaccination.dosage,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completed: ${DateUtil.toMMDDYYYY(vaccination.completedDate ?? vaccination.scheduledDate)}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (vaccination.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      vaccination.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
  final VoidCallback onAdopt;

  const _RecommendedVaccinationItem({
    required this.vaccineName,
    required this.timing,
    required this.method,
    required this.dosage,
    required this.description,
    required this.onAdopt,
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
                width: 90,
                child: FilledButton(
                  onPressed: onAdopt,
                  style: FilledButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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