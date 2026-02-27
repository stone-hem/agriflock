import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/shared_prefs.dart';
import 'package:agriflock360/core/widgets/alert_button.dart';
import 'package:agriflock360/features/farmer/home/model/batch_home_model.dart';
import 'package:agriflock360/features/farmer/home/model/dashboard_model.dart';
import 'package:agriflock360/features/farmer/home/model/financial_overview_model.dart';
import 'package:agriflock360/features/farmer/home/repo/dashboard_repo.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/activities_loading.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/activity_item.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/batch_overview_carousel.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/perfomance_graph.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/welcome_section.dart';
import 'package:agriflock360/features/farmer/payg/flow/upgrade_decision_modal.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/future_framing_banner.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/value_confirmation_banner.dart';
import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardRepository _repository = DashboardRepository();
  final ScrollController _scrollController = ScrollController();

  DashboardSummary? _summary;
  FinancialOverview? _financialOverview;
  List<DashboardActivity> _activities = [];
  bool _isSummaryLoading = true;
  bool _isActivitiesLoading = true;
  bool _isFinancialLoading = true;
  String? _summaryError;
  String? _activitiesError;
  String? _financialError;
  DateTime? _userFirstLoginDate;
  bool _isLoadingUser = true;
  int _daysSinceFirstLogin = 0;
  String? _userName;
  bool _showDay27Modal = false;
  bool _hasNoSubscription = false;

  List<BatchHomeData> _batches = [];
  bool _isBatchesLoading = true;
  String? _batchesError;

  // Constants for day thresholds (free plan = 90 days)
  static const int VALUE_CONFIRMATION_START_DAY = 5;
  static const int VALUE_CONFIRMATION_END_DAY = 20;
  static const int FUTURE_FRAMING_DAY = 30;
  static const int FUTURE_FRAMING_END_DAY = 33;
  static const int DECISION_MODAL_DAY = 42;
  static const int TRANSITION_DAY = 52;
  static const int FREE_PLAN_TOTAL_DAYS = 60;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSummary();
    _loadActivities();
    _loadFinancialOverview();
    _loadBatches();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final User? userData = await secureStorage.getUserData();

      if (userData != null && mounted) {
        LogUtil.warning(userData.toJson());

        if (mounted) {
          setState(() {
            _userName = userData.name;
            _userFirstLoginDate = _parseDateTime(userData.firstLogin);
            _calculateDaysSinceFirstLogin();
            _checkDay27Modal();
            _isLoadingUser = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _userFirstLoginDate = null;
            _isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _userFirstLoginDate = null;
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _loadBatches() async {
    if (!mounted) return;

    setState(() {
      _isBatchesLoading = true;
      _batchesError = null;
    });

    try {
      final result = await _repository.getUserBatches();

      if (!mounted) return;

      switch (result) {
        case Success<List<BatchHomeData>>(data: final data):
          setState(() {
            _batches = data;
            _isBatchesLoading = false;
          });
          break;
        case Failure<List<BatchHomeData>>(message: final error, cond: final cond):
          setState(() {
            _batchesError = error;
            _isBatchesLoading = false;
            if (cond == 'no_subscription_plan') {
               secureStorage.saveSubscriptionState('no_subscription_plan');
              _hasNoSubscription = true;
            }
            if (cond == 'expired_subscription_plan') {
              secureStorage.saveSubscriptionState('expired_subscription_plan');
              _hasNoSubscription = true;
            }
            secureStorage.saveSubscriptionState('has_subscription_plan');
            _hasNoSubscription = false;

          });
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _batchesError = e.toString();
          _isBatchesLoading = false;
        });
      }
    }
  }

  DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      return null;
    }
  }

  void _calculateDaysSinceFirstLogin() {
    if (_userFirstLoginDate == null) {
      _daysSinceFirstLogin = 0;
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(_userFirstLoginDate!);
    _daysSinceFirstLogin = difference.inDays;
  }

  void _checkDay27Modal() {
    if (_daysSinceFirstLogin >= DECISION_MODAL_DAY) {
      final lastShown = SharedPrefs.getInt('upgrade_modal_last_shown') ?? 0;
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (_daysSinceFirstLogin == DECISION_MODAL_DAY ||
          (_daysSinceFirstLogin > DECISION_MODAL_DAY &&
              lastShown != todayDate.millisecondsSinceEpoch)) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showDay27Modal = true;
            });
          }
        });
      }
    }
  }

  void _onDay27ModalContinue() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    SharedPrefs.setInt(
      'upgrade_modal_last_shown',
      todayDate.millisecondsSinceEpoch,
    );

    if (mounted) {
      setState(() {
        _showDay27Modal = false;
      });
      context.push('/plans');
    }
  }

  void _onDay27ModalDismiss() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    SharedPrefs.setInt(
      'upgrade_modal_last_shown',
      todayDate.millisecondsSinceEpoch,
    );

    if (mounted) {
      setState(() {
        _showDay27Modal = false;
      });
    }
  }

  bool get _shouldShowValueConfirmationBanner {
    return _daysSinceFirstLogin >= VALUE_CONFIRMATION_START_DAY &&
        _daysSinceFirstLogin <= VALUE_CONFIRMATION_END_DAY;
  }

  bool get _shouldShowFutureFramingBanner {
    return _daysSinceFirstLogin >= FUTURE_FRAMING_DAY &&
        _daysSinceFirstLogin <= FUTURE_FRAMING_END_DAY;
  }

  bool get _shouldNavigateToDay31Screen {
    return _daysSinceFirstLogin >= TRANSITION_DAY;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_shouldNavigateToDay31Screen && !_isLoadingUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final lastShown = SharedPrefs.getInt('transition_screen_last_shown') ?? 0;
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        if (lastShown != todayDate.millisecondsSinceEpoch) {
          SharedPrefs.setInt(
            'transition_screen_last_shown',
            todayDate.millisecondsSinceEpoch,
          );

          if (mounted) {
            context.push('/plan-transition');
          }
        }
      });
    }
  }

  Future<void> _loadSummary() async {
    if (!mounted) return;

    setState(() {
      _isSummaryLoading = true;
      _summaryError = null;
    });

    try {
      final result = await _repository.getDashboardSummary();

      if (!mounted) return;

      switch (result) {
        case Success<DashboardSummary>(data: final data):
          setState(() {
            _summary = data;
            _isSummaryLoading = false;
          });
          break;
        case Failure<DashboardSummary>(message: final error):
          setState(() {
            _summaryError = error;
            _isSummaryLoading = false;
          });
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _summaryError = e.toString();
          _isSummaryLoading = false;
        });
      }
    }
  }

  Future<void> _loadFinancialOverview() async {
    if (!mounted) return;

    setState(() {
      _isFinancialLoading = true;
      _financialError = null;
    });

    try {
      final result = await _repository.getFinancialOverview();

      if (!mounted) return;

      switch (result) {
        case Success<FinancialOverview>(data: final data):
          setState(() {
            _financialOverview = data;
            _isFinancialLoading = false;
          });
          break;
        case Failure<FinancialOverview>(message: final error, cond: final cond):
          setState(() {
            _financialError = error;
            _isFinancialLoading = false;
            if (cond == 'no_subscription_plan') {
              _hasNoSubscription = true;
            }
          });
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _financialError = e.toString();
          _isFinancialLoading = false;
        });
      }
    }
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;

    setState(() {
      _isActivitiesLoading = true;
      _activitiesError = null;
    });

    try {
      final result = await _repository.getRecentActivities(limit: 5);

      if (!mounted) return;

      switch (result) {
        case Success<List<DashboardActivity>>(data: final data):
          setState(() {
            _activities = data;
            _isActivitiesLoading = false;
          });
          break;
        case Failure<List<DashboardActivity>>(message: final error):
          setState(() {
            _activitiesError = error;
            _isActivitiesLoading = false;
          });
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _activitiesError = e.toString();
          _isActivitiesLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;

    // Load all sections independently in parallel
    await Future.wait([
      _loadSummary(),
      _loadActivities(),
      _loadFinancialOverview(),
      _loadBatches(),
    ]);
  }


  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }



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
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('Agriflock 360'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
           AlertsButton(),
          SizedBox(width: 8,)
        ],
      ),
      bottomNavigationBar: const ExpenseMarqueeBannerCompact(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome / Banner section — loads independently
                  _buildWelcomeOrBannerSection(),
                  const SizedBox(height: 16),

                  if (_hasNoSubscription)
                    _buildSubscriptionCTA()
                  else ...[
                    Text(
                      'Daily Flock Summary',
                      style: Theme.of(context).textTheme.titleMedium!
                          .copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_isBatchesLoading)
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_batchesError != null)
                      Container(
                        height: MediaQuery.sizeOf(context).height * 0.33,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load batches',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadBatches,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (_batches.isEmpty)
                        Container(
                          height: MediaQuery.sizeOf(context).height * 0.33,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No batches available',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first batch to get started',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              ),
                              FilledButton.icon(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  context.go('/farms');
                                }, label: Text('Create batch' ),
                              ),
                            ],
                          ),
                        )
                      else
                        BatchOverviewCarousel(batches: _batches, outerScrollController: _scrollController),
                    if (!_isBatchesLoading && _batchesError == null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionsGrid(),
                    ],
                    const SizedBox(height: 16),

                    if (_isFinancialLoading)
                      SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_financialError != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Failed to load financial data',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadFinancialOverview,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (_financialOverview != null)
                      FinancialPerformanceGraph(
                        financialData: _financialOverview!,
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 20),
                  ],

                  _buildRecentActivitySection(context),
                ],
              ),
            ),
          ),

          if (_showDay27Modal)
            GestureDetector(
              onTap: _onDay27ModalDismiss,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: UpgradeDecisionModal(
                    onContinue: _onDay27ModalContinue,
                    onDismiss: _onDay27ModalDismiss,
                    currentDay: _daysSinceFirstLogin,
                    totalDays: FREE_PLAN_TOTAL_DAYS,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildWelcomeOrBannerSection() {


    // Show a shimmer placeholder while summary or user data is loading
    if (_isSummaryLoading || _isLoadingUser) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    if (_summaryError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load summary',
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadSummary,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_shouldShowValueConfirmationBanner) {
      return ValueConfirmationBanner(
        onViewActivity: () => context.push('/activity'),
        farms: '${_summary!.numberOfFarms}',
        houses: '${_summary!.numberOfHouses}',
        batches: '${_summary!.totalBatches}',
        birds: '${_summary!.totalBirds}',
      );
    }

    if (_shouldShowFutureFramingBanner) {
      return FutureFramingBanner(
        onSeePlans: () => context.push('/plans'),
        farms: '${_summary!.numberOfFarms}',
        houses: '${_summary!.numberOfHouses}',
        batches: '${_summary!.totalBatches}',
        birds: '${_summary!.totalBirds}',
      );
    }

    return WelcomeSection(
      greeting: _getGreeting(),
      userName: _userName,
      farms: '${_summary!.numberOfFarms}',
      houses: '${_summary!.numberOfHouses}',
      batches: '${_summary!.totalBatches}',
      birds: '${_summary!.totalBirds}',
      daysSinceLogin: _userFirstLoginDate != null
          ? _daysSinceFirstLogin
          : null,
    );
  }

  Widget _buildSubscriptionCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium,
            size: 56,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Subscription Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To access core modules, please select a subscription plan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/plans'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Choose a Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.extent(
      maxCrossAxisExtent: 130,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 4,
      childAspectRatio: 0.72,
      children: [
        _buildQuickActionCard(
          icon: Icons.receipt_long,
          title: 'Expenses',
          subtitle: 'Review and add expenses',
          color: Colors.red,
          onTap: () => context.push('/my-expenditures'),
        ),
        _buildQuickActionCard(
          icon: Icons.edit_note,
          title: 'Daily Record',
          subtitle: 'Record Feed, Vaccination, Medication, Mortality, Weight, Product',
          color: Colors.green,
          onTap: () => context.push('/quick-recording'),
        ),
        _buildQuickActionCard(
          icon: Icons.pets,
          title: 'My Batches',
          subtitle: 'All your batches',
          color: Colors.orange,
          onTap: () => context.push('/quick-batches'),
        ),
        _buildQuickActionCard(
          icon: Icons.assessment,
          title: 'Reports',
          subtitle: 'Batch & farm reports',
          color: Colors.blue,
          onTap: () => context.push('/reports'),
        ),
        _buildQuickActionCard(
          icon: Icons.devices,
          title: 'My Devices',
          subtitle: 'Monitor devices',
          color: Colors.teal,
          onTap: () => context.push('/my-devices'),
        ),
        _buildQuickActionCard(
          icon: Icons.medical_services_outlined,
          title: 'Book Vets',
          subtitle: 'Find and book Extension officers',
          color: Colors.purple,
          onTap: () => context.push('/all-vets'),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecentActivitySection(BuildContext context) {
    if (_isActivitiesLoading) {
      return HomeActivitiesLoading();
    }

    if (_activitiesError != null) {
      return _buildActivitiesError();
    }

    return _buildRecentActivityContent(context);
  }

  Widget _buildActivitiesError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _activitiesError ?? 'Failed to load activities',
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadActivities,
            child: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/activity'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_activities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No recent activities',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          )
        else
          ..._activities.map(
            (activity) => HomeActivityItem(
              icon: _getActivityIcon(activity.activityType),
              title: activity.title,
              subtitle: activity.description,
              time: activity.timeAgo,
              color: _getActivityColor(activity.activityType),
            ),
          ),
      ],
    );
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'batch_created':
      case 'batch_updated':
        return Icons.add_circle_outline;
      case 'farm_created':
      case 'farm_updated':
      case 'farm_deleted':
        return Icons.agriculture;
      case 'houses':
        return Icons.home;
      case 'vaccination':
        return Icons.medical_services;
      case 'feeding':
        return Icons.restaurant;
      case 'egg_collection':
        return Icons.egg;
      case 'weight_check':
        return Icons.monitor_weight;
      case 'bird_sale':
        return Icons.sell;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType) {
      case 'product_recorded':
        return Colors.purple;
      case 'egg_collection':
        return Colors.orange;
      case 'weight_check':
        return Colors.blue;
      case 'bird_sale':
        return Colors.indigo;
      case 'health_check':
        return Colors.blue;
      case 'feed_recorded':
      case 'feeding':
        return Colors.green;
      case 'vaccination':
        return Colors.pink;
      case 'batch_updated':
        return Colors.amber;
      case 'batch_created':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
