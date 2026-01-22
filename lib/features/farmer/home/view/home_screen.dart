import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/utils/shared_prefs.dart';
import 'package:agriflock360/features/farmer/home/model/dashboard_model.dart';
import 'package:agriflock360/features/farmer/home/repo/dashboard_repo.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/action_tile.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/activities_loading.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/activity_item.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/home_skeleton.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/perfomance_graph.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/stat_card.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/stats_loading.dart';
import 'package:agriflock360/features/farmer/home/view/widgets/welcome_section.dart';
import 'package:agriflock360/features/farmer/payg/flow/day_27_decision_modal.dart';
import 'package:agriflock360/features/farmer/payg/flow/future_framing_banner.dart';
import 'package:agriflock360/features/farmer/payg/flow/value_confirmation_banner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardRepository _repository = DashboardRepository();
  final SecureStorage _secureStorage = SecureStorage();

  DashboardSummary? _summary;
  List<DashboardActivity> _activities = [];
  bool _isSummaryLoading = true;
  bool _isActivitiesLoading = true;
  String? _summaryError;
  String? _activitiesError;
  DateTime? _userFirstLoginDate;
  bool _isLoadingUser = true;
  int _daysSinceFirstLogin = 0;
  bool _showDay27Modal = false;

  // Constants for day thresholds
  static const int VALUE_CONFIRMATION_START_DAY = 5;
  static const int VALUE_CONFIRMATION_END_DAY = 10;
  static const int FUTURE_FRAMING_DAY = 21;
  static const int FUTURE_FRAMING_END_DAY = 27;
  static const int DECISION_MODAL_DAY = 27;
  static const int TRANSITION_DAY = 31;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSummary();
    _loadActivities();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final User? userData = await _secureStorage.getUserData();

      if (userData != null && mounted) {
        LogUtil.warning(userData.toJson());

        if (mounted) {
          setState(() {
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
      final lastShown = SharedPrefs.getInt('day27_modal_last_shown') ?? 0;
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
    SharedPrefs.setInt('day27_modal_last_shown', todayDate.millisecondsSinceEpoch);

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
    SharedPrefs.setInt('day27_modal_last_shown', todayDate.millisecondsSinceEpoch);

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

        final lastShown = SharedPrefs.getInt('day31_last_shown') ?? 0;
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        if (lastShown != todayDate.millisecondsSinceEpoch) {
          SharedPrefs.setInt('day31_last_shown', todayDate.millisecondsSinceEpoch);

          final planDetails = {
            'features': [
              'Basic farm management',
              'Up to 3 farms',
              'Basic analytics',
              'Community support',
            ],
            'price': '\$9.99',
            'period': '/month',
          };

          if (mounted) {
            context.push('/day-31-transition', extra: {
              'recommendedPlan': 'Starter Plan',
              'planDetails': planDetails,
            });
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

    try {
      final result = await _repository.refreshDashboard(activityLimit: 5);

      if (!mounted) return;

      switch (result) {
        case Success<Map<String, dynamic>>(data: final data):
          setState(() {
            _summary = data['summary'] as DashboardSummary;
            _activities = data['activities'] as List<DashboardActivity>;
            _summaryError = null;
            _activitiesError = null;
          });
          break;
        case Failure<Map<String, dynamic>>(message: final error):
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to refresh: $error')),
            );
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: ${e.toString()}')),
        );
      }
    }
  }

  bool get _isLoading => _isSummaryLoading || _isActivitiesLoading;
  bool get _hasError => _summaryError != null || _activitiesError != null;
  String? get _error => _summaryError ?? _activitiesError;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getSummaryMessage() {
    if (_summary == null) return 'Loading farm data...';
    if (_summary!.activeBatches == 0) return 'No active batches at the moment';
    return 'Managing ${_summary!.activeBatches} active batch${_summary!.activeBatches > 1 ? "es" : ""} today';
  }

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
            const Text('Agriflock 360'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? HomeSkeleton()
              : _hasError
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $_error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_summaryError != null) _loadSummary();
                    if (_activitiesError != null) _loadActivities();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_shouldShowValueConfirmationBanner)
                    ValueConfirmationBanner(
                      onViewActivity: () => context.push('/activity'),
                    ),

                  if (_shouldShowFutureFramingBanner)
                    FutureFramingBanner(
                      onSeePlans: () => context.push('/plans'),
                    ),

                  if (!_shouldShowValueConfirmationBanner && !_shouldShowFutureFramingBanner)
                    WelcomeSection(
                      greeting: _getGreeting(),
                      summaryMsg: _getSummaryMessage(),
                      daysSinceLogin: _userFirstLoginDate != null ? _daysSinceFirstLogin : null,
                    ),
                  const SizedBox(height: 20),

                  _buildStatsOverview(),
                  const SizedBox(height: 20),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  HomeActionTile(
                    icon: Icons.outbond,
                    title: 'Quick Expense',
                    subtitle: 'Add expenses',
                    color: Colors.red,
                    onTap: () => context.push('/record-expenditure'),
                  ),
                  const SizedBox(height: 20),
                  HomeActionTile(
                    icon: Icons.restaurant,
                    title: 'My Subscription',
                    subtitle: 'Manage my subscriptions',
                    color: Colors.orange,
                    onTap: () => context.push('/payg'),
                  ),
                  const SizedBox(height: 20),

                  FinancialPerformanceGraph(),
                  const SizedBox(height: 20),

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
                  child: Day27DecisionModal(
                    onContinue: _onDay27ModalContinue,
                    onDismiss: _onDay27ModalDismiss,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (_summary == null || _isSummaryLoading) {
      return HomeStatsLoading();
    }

    if (_summaryError != null) {
      return _buildStatsError();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HomeStatCard(
                value: '${_summary!.numberOfFarms}',
                label: 'Farms',
                color: Colors.green.shade100,
                textColor: Colors.green.shade800,
                buttonText: 'View',
               onButtonPressed: (){
                  context.push('/farms');
               },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HomeStatCard(
                value: '${_summary!.numberOfHouses}',
                label: 'Houses',
                color: Colors.teal.shade100,
                textColor: Colors.teal.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HomeStatCard(
                value: '${_summary!.totalBatches}',
                label: 'All Batches',
                color: Colors.purple.shade100,
                textColor: Colors.purple.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: HomeStatCard(
                value: _summary!.totalBirds.toString(),
                label: 'Total Birds',
                color: Colors.blue.shade100,
                textColor: Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HomeStatCard(
                value: _summary!.eggsToday.toString(),
                label: 'Eggs Today',
                color: Colors.orange.shade100,
                textColor: Colors.orange.shade800,
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildStatsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _summaryError ?? 'Failed to load statistics',
        style: TextStyle(color: Colors.red.shade700),
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
            )
          ],
        ),
        const SizedBox(height: 16),
        if (_activities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No recent activities',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ..._activities.map((activity) => HomeActivityItem(
            icon: _getActivityIcon(activity.activityType),
            title: activity.title,
            subtitle: activity.description,
            time: activity.timeAgo,
            color: _getActivityColor(activity.activityType),
          )),
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