import 'package:agriflock360/core/notifications/notification_service.dart';
import 'package:agriflock360/features/farmer/batch/add_batch_screen.dart';
import 'package:agriflock360/features/farmer/batch/adopt_schedule_screen.dart';
import 'package:agriflock360/features/farmer/batch/batch_details_screen.dart';
import 'package:agriflock360/features/farmer/batch/completed_batches_screen.dart';
import 'package:agriflock360/features/farmer/batch/edit_batch_screen.dart';
import 'package:agriflock360/features/farmer/batch/houses_screen.dart';
import 'package:agriflock360/features/farmer/batch/log_feeding_screen.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/recommended_vaccination_model.dart';
import 'package:agriflock360/features/farmer/batch/model/vaccination_list_model.dart';
import 'package:agriflock360/features/farmer/expense/buy_inputs_screen.dart';
import 'package:agriflock360/features/farmer/expense/expenditures_screen.dart';
import 'package:agriflock360/features/farmer/batch/record_vaccination_screen.dart';
import 'package:agriflock360/features/farmer/batch/record_product_screen.dart';
import 'package:agriflock360/features/farmer/batch/update_vaccination_status_screen.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/farm/view/add_farm_screen.dart';
import 'package:agriflock360/features/farmer/farm/view/farms_home_screen.dart';
import 'package:agriflock360/features/farmer/home/view/home_screen.dart';
import 'package:agriflock360/features/farmer/inventory/inventory_screen.dart';
import 'package:agriflock360/features/farmer/more/notifications_screen.dart';
import 'package:agriflock360/features/farmer/more/recent_activity_screen.dart';
import 'package:agriflock360/features/farmer/payg/flow/plan_transition_screen.dart';
import 'package:agriflock360/features/farmer/payg/flow/day_one_welcome_screen.dart';
import 'package:agriflock360/features/farmer/payg/payg_dashboard.dart';
import 'package:agriflock360/features/farmer/payg/payment_history_screen.dart';
import 'package:agriflock360/features/farmer/payg/payment_screen.dart';
import 'package:agriflock360/features/farmer/payg/plans.dart';
import 'package:agriflock360/features/farmer/payg/view_invoice.dart';
import 'package:agriflock360/features/farmer/profile/about_screen.dart';
import 'package:agriflock360/features/farmer/profile/complete_profile_screen.dart';
import 'package:agriflock360/features/farmer/profile/congratulations_screen.dart';
import 'package:agriflock360/features/farmer/profile/help_support_screen.dart';
import 'package:agriflock360/features/farmer/profile/models/profile_model.dart';
import 'package:agriflock360/features/farmer/profile/profile_screen.dart';
import 'package:agriflock360/features/farmer/profile/settings_screen.dart';
import 'package:agriflock360/features/farmer/devices/screens/devices_screen.dart';
import 'package:agriflock360/features/farmer/devices/screens/device_telemetry_screen.dart';
import 'package:agriflock360/features/farmer/devices/models/device_model.dart';
import 'package:agriflock360/features/farmer/profile/update_profile_screen.dart';
import 'package:agriflock360/features/farmer/onboarding/onboarding_setup_screen.dart';
import 'package:agriflock360/features/farmer/quotation/quotation_screen.dart';
import 'package:agriflock360/features/farmer/record/quick_record.dart';
import 'package:agriflock360/features/farmer/home/view/quick_batches_list_screen.dart';
import 'package:agriflock360/features/farmer/batch/record_mortality_screen.dart';
import 'package:agriflock360/features/farmer/report/batch/batch_report_screen.dart';
import 'package:agriflock360/features/farmer/report/farm_reports_screen.dart';
import 'package:agriflock360/features/farmer/report/reports_flow_screen.dart';
import 'package:agriflock360/features/farmer/vet/all_vets_screen.dart';
import 'package:agriflock360/features/farmer/vet/completed_orders_screen.dart';
import 'package:agriflock360/features/farmer/vet/models/my_order_list_item.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/my_orders_screen.dart';
import 'package:agriflock360/features/farmer/vet/vet_details_screen.dart';
import 'package:agriflock360/features/farmer/vet/vet_order_screen.dart';
import 'package:agriflock360/features/farmer/vet/my_order_tracking_screen.dart';
import 'package:agriflock360/features/farmer/vet/browse_vets_screen.dart';
import 'package:agriflock360/features/shared/error_screen.dart';
import 'package:agriflock360/features/shared/shell_scaffold.dart';
import 'package:agriflock360/features/vet/home/vet_home_screen.dart';
import 'package:agriflock360/features/vet/payments/vet_payments_history_screen.dart';
import 'package:agriflock360/features/vet/payments/vet_payments_screen.dart';
import 'package:agriflock360/features/vet/payments/vet_service_payments_screen.dart';
import 'package:agriflock360/features/vet/profile/vet_profile_screen.dart';
import 'package:agriflock360/features/vet/schedules/vet_schedules_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/utils/secure_storage.dart';
import 'core/utils/shared_prefs.dart';

import 'package:agriflock360/features/auth/forgot_password_screen.dart';
import 'package:agriflock360/features/auth/otp_screen.dart';
import 'package:agriflock360/features/auth/quiz/onboarding_quiz_screen.dart';
import 'package:agriflock360/features/auth/reset_password_screen.dart';
import 'package:agriflock360/features/auth/sign_in_screen.dart';
import 'package:agriflock360/features/auth/sign_up_screen.dart';
import 'package:agriflock360/features/auth/vet_verification_pending_screen.dart';
import 'package:agriflock360/features/auth/welcome_screen.dart';

// Navigator keys for ShellRoute
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRoutes {
  // Route paths
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboardingQuiz = '/onboarding-quiz';
  static const String otpVerifyEmailOrPhone = '/verify-email-or-phone';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String createFarm = '/create-farm';
  static const String selectFarmType = '/select-farm-type';

  // Shell tab routes - Farmer
  static const String home = '/home';
  static const String farms = '/farms';
  static const String quotation = '/quotation';
  static const String browseVets = '/browse-vets';
  static const String farmerProfile = '/farmer-profile';

  // Shell tab routes - Vet
  static const String vetHome = '/vet-home';
  static const String vetSchedules = '/vet-schedules';
  static const String vetPaymentsTab = '/vet-payments-tab';
  static const String vetProfile = '/vet-profile';

  // Sub-routes inside shell (rendered full-screen via parentNavigatorKey)
  static const String farmsAdd = '/farms/add';
  static const String farmsInventory = '/farms/inventory';
  static const String farmsInventoryAdd = '/farms/inventory/add';

  // Other routes
  static const String batches = '/batches';
  static const String batchesAdd = '/batches/add';
  static const String batchesList = '/batches/list';
  static const String batchesDetails = '/batches/details';
  static const String batchesArchived = '/batches/archived';
  static const String batchesFeed = '/batches/feed';
  static const String quickDone = '/batches/quick-done';
  static const String adoptSchedule = '/batches/adopt-schedule';
  static const String updateStatus = '/batches/update-status';
  static const String batchesSchedule = '/batches/schedule';
  static const String payg = '/payg';
  static const String paygPayment = '/payg/payment';
  static const String paygHistory = '/payg/history';
  static const String invoice = '/invoice';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String about = '/about';
  static const String activity = '/activity';
  static const String notifications = '/notifications';
  static const String completeProfile = '/complete-profile';
  static const String congratulations = '/complete-profile/congratulations';
  static const String vetOrderDetails = '/vet-order-details';
  static const String vetVerificationPending = '/vet-verification-pending';

  // Define protected routes that require authentication
  static const List<String> _protectedRoutes = [
    // Shell tab routes
    home,
    farms,
    quotation,
    browseVets,
    farmerProfile,
    vetHome,
    vetSchedules,
    vetPaymentsTab,
    vetProfile,
    // Other protected routes
    batches,
    batchesAdd,
    batchesList,
    batchesDetails,
    batchesArchived,
    batchesFeed,
    quickDone,
    adoptSchedule,
    updateStatus,
    batchesSchedule,
    payg,
    paygPayment,
    paygHistory,
    invoice,
    settings,
    farmsAdd,
    farmsInventory,
    farmsInventoryAdd,
    activity,
    notifications,
    vetOrderDetails,
    completeProfile,
  ];

  // Define auth-related routes
  static const List<String> _authRoutes = [
    welcome,
    login,
    signup,
    onboardingQuiz,
    otpVerifyEmailOrPhone,
    forgotPassword,
    resetPassword,
    vetVerificationPending,
  ];

  // Define onboarding routes
  static const List<String> _onboardingRoutes = [
    onboardingQuiz,
    congratulations,
  ];

  /// Get role-based home route
  static Future<String> _getHomeRoute(SecureStorage secureStorage) async {
    final user = await secureStorage.getUserData();
    if (user?.role.name.toLowerCase() == 'extension_officer') {
      return vetHome;
    }

    // Farmer: check subscription state
    final subscriptionState = await secureStorage.getSubscriptionState();
    final isSubscribed = subscriptionState == 'true';
    if (isSubscribed) {
      return quotation; // subscribed farmers land on Quotation
    }

    return home;
  }

  static GoRouter createRouter({
    required SecureStorage secureStorage,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: _getInitialLocation(),
      redirect: (context, state) async {
        final isLoggedIn = await secureStorage.isLoggedIn();
        final hasCompletedOnboarding =
            SharedPrefs.getBool('hasCompletedOnboarding') ?? false;
        final hasSeenWelcome = SharedPrefs.getBool('hasSeenWelcome') ?? false;
        final currentPath = state.matchedLocation;

        // Check route types
        final isProtectedRoute = _protectedRoutes.any(
          (route) => currentPath.startsWith(route),
        );
        final isAuthRoute = _authRoutes.contains(currentPath);
        final isOnboardingRoute = _onboardingRoutes.any(
          (route) => currentPath.startsWith(route),
        );

        // First time user - show welcome screen
        if (!hasSeenWelcome && currentPath != welcome) {
          return welcome;
        }

        // If trying to access protected route without login, redirect to login
        if (!isLoggedIn && isProtectedRoute) {
          return login;
        }

        // If logged in and trying to access auth pages, redirect to home
        if (isLoggedIn &&
            (currentPath == login ||
                currentPath == signup ||
                currentPath == welcome)) {
          // Ensure WebSocket is connected when user is authenticated
          NotificationService.instance.connect();
          return await _getHomeRoute(secureStorage);
        }

        // Connect WS whenever a protected route is navigated to (no-op if already connected)
        if (isLoggedIn && isProtectedRoute) {
          NotificationService.instance.connect();
        }

        // Disconnect WS on logout / redirect to auth
        if (!isLoggedIn && currentPath == login) {
          NotificationService.instance.disconnect();
        }

        // If logged in and trying to access onboarding again
        if (isLoggedIn && hasCompletedOnboarding && isOnboardingRoute) {
          return await _getHomeRoute(secureStorage);
        }

        // Allow access to password reset flows
        // Allow access to public pages
        return null;
      },
      routes: <RouteBase>[
        // ── Auth routes (outside shell, no bottom bar) ──────────
        GoRoute(
          path: welcome,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(path: login, builder: (context, state) {
          final identifier=state.extra as String?;

          return LoginScreen(identifier:identifier);
        }),
        GoRoute(
          path: signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: onboardingQuiz,
          builder: (context, state) {
            final temptToken = state.uri.queryParameters['tempToken'];
            final identifier=state.extra as String;

            if (temptToken == null || temptToken.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Temp Token parameter is missing')),
              );
            }
            final decodedToken = Uri.decodeComponent(temptToken);

            return OnboardingQuestionsScreen(token: decodedToken,identifier:identifier);
          },
        ),
        GoRoute(
          path: otpVerifyEmailOrPhone,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'];
            final userId = state.uri.queryParameters['userId'];

            if (email == null || email.isEmpty) {
              return ErrorScreen(message: 'Email parameter is missing');
            }

            if (userId == null || userId.isEmpty) {
              return ErrorScreen(message: 'User ID parameter is missing');
            }
            final decodedEmail = Uri.decodeComponent(email);
            final decodedUserId = Uri.decodeComponent(userId);

            return OTPVerifyScreen(email: decodedEmail, userId: decodedUserId);
          },
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: resetPassword,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'];
            final token = state.uri.queryParameters['token'];

            return ResetPasswordScreen(
              email: email != null ? Uri.decodeComponent(email) : null,
              token: token != null ? Uri.decodeComponent(token) : null,
            );
          },
        ),
        GoRoute(
          path: vetVerificationPending,
          builder: (context, state) => const VetVerificationPendingScreen(),
        ),
        // ── ShellRoute (shows bottom bar / navigation rail) ─────
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => ShellScaffold(child: child),
          routes: [
            // Farmer tab routes
            GoRoute(
              path: home,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const HomeScreen(),
              ),
            ),
            GoRoute(
              path: farms,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const FarmsHomeScreen(),
              ),
            ),
            GoRoute(
              path: quotation,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const QuotationScreen(),
              ),
            ),
            GoRoute(
              path: browseVets,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const BrowseVetsScreen(),
              ),
            ),
            GoRoute(
              path: farmerProfile,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const ProfileScreen(),
              ),
            ),

            // Vet tab routes
            GoRoute(
              path: vetHome,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const VetHomeScreen(),
              ),
            ),
            GoRoute(
              path: vetSchedules,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const VetSchedulesScreen(),
              ),
            ),
            GoRoute(
              path: vetPaymentsTab,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const VetPaymentsScreen(),
              ),
            ),
            GoRoute(
              path: vetProfile,
              pageBuilder: (context, state) => _fadeTransition(
                state,
                const VetProfileScreen(),
              ),
            ),
          ],
        ),

        // ── Sub-routes rendered full-screen (no bottom bar) ─────
        GoRoute(
          path: farmsAdd,
          parentNavigatorKey: navigatorKey,
          builder: (context, state) => const AddFarmScreen(),
        ),
        GoRoute(
          path: farmsInventory,
          parentNavigatorKey: navigatorKey,
          builder: (context, state) {
            return InventoryScreen();
          },
        ),

        // ── Other top-level routes (outside shell, no bottom bar) ─
        GoRoute(
          path: batches,
          builder: (context, state) {
            if (state.extra is! FarmModel) {
              return const ErrorScreen(
                title: 'Invalid navigation',
                message:
                    'Farm not provided. Please select a farm and try again.',
              );
            }
            final farm = state.extra as FarmModel;
            return HousesScreen(farm: farm);
          },
          routes: [
            GoRoute(
              path: 'add',
              name: 'addBatch',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return AddBatchScreen(
                  farm: extra?['farm'] ?? '',
                  house: extra?['house'],
                );
              },
            ),
            GoRoute(
              path: 'my-completed-batches',
              name: 'completedBatches',
              builder: (context, state) {
                final extra = state.extra as FarmModel;
                return CompletedBatchesScreen(
                  farm: extra,
                );
              },
            ),
            GoRoute(
              path: 'edit',
              name: 'editBatch',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return EditBatchScreen(
                  farm: extra['farm'],
                  batch: extra['batch'],
                  house: extra['house'],
                );
              },
            ),
            GoRoute(
              path: 'details',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return BatchDetailsScreen(
                  farm: extra['farm'],
                  batch: extra['batch'],
                );
              },
            ),
            GoRoute(
              path: ':id/feed',
              builder: (context, state) {
                final batchId = state.pathParameters['id']!;
                final breedId = state.extra as String?;
                return LogFeedingScreen(batchId: batchId, breedId: breedId);
              },
            ),
            GoRoute(
              path: ':id/record-vaccination',
              builder: (context, state) {
                final batchId = state.pathParameters['id']!;
                final breedId = state.extra as String?;
                return VaccinationRecordScreen(batchId: batchId, breedId: breedId);
              },
            ),
            GoRoute(
              path: 'adopt-schedule',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                final batch = extra['batch'] as BatchModel;
                final schedule =
                    extra['schedule'] as RecommendedVaccinationsResponse;
                return AdoptScheduleScreen(
                    vaccineSchedule: schedule, batch: batch);
              },
            ),
            GoRoute(
              path: 'update-status',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                final batch = extra['batch'] as BatchModel;
                final vaccination =
                    extra['vaccination'] as VaccinationListItem;
                return UpdateVaccinationStatusScreen(
                  batch: batch,
                  vaccination: vaccination,
                );
              },
            ),
            GoRoute(
              path: ':id/record-product',
              builder: (context, state) {
                final batchId = state.pathParameters['id']!;
                return RecordProductScreen(batchId: batchId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/record-expenditure',
          builder: (context, state) {
            final farm = state.extra as FarmModel?;
            return BuyInputsPageView(farm: farm);
          },
        ),
        GoRoute(
          path: '/quick-recording',
          builder: (context, state) {
            final farm = state.extra as FarmModel?;
            return UseFromStorePageView(farm: farm);
          },
        ),
        GoRoute(
          path: '/quick-batches',
          builder: (context, state) => const QuickBatchesListScreen(),
        ),
        GoRoute(
          path: '/record-mortality',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return RecordMortalityScreen(
              farm: extra?['farm'] as FarmModel?,
              batch: extra?['batch'] as BatchListItem?,
            );
          },
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsFlowScreen(),
        ),
        GoRoute(
          path: '/batch-report',
          builder: (context, state) {
            final batchId = state.extra as String;
            return BatchReportScreen(batchId: batchId);
          },
        ),
        GoRoute(
          path: '/farm-reports',
          builder: (context, state) {
            final farm = state.extra as FarmModel?;
            if (farm == null) {
              return const ErrorScreen(
                title: 'Farm Required',
                message: 'Please select a farm to view its report.',
              );
            }
            return FarmReportsScreen(farm: farm);
          },
        ),
        GoRoute(
          path: '/my-expenditures',
          builder: (context, state) {
            return ExpendituresScreen();
          },
        ),
        GoRoute(
            path: payg,
            builder: (context, state) => const PAYGDashboard()),
        GoRoute(
          path: paygPayment,
          builder: (context, state) => const PAYGPaymentScreen(),
        ),
        GoRoute(
          path: paygHistory,
          builder: (context, state) => const PaymentHistoryScreen(),
        ),
        GoRoute(
          path: '/day1/welcome-msg-page',
          builder: (context, state) => const Day1WelcomeScreen(),
        ),
        GoRoute(
          path: '/onboarding/setup',
          builder: (context, state) => const OnboardingSetupScreen(),
        ),
        GoRoute(
          path: invoice,
          builder: (context, state) => const ViewInvoiceScreen(),
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: help,
          builder: (context, state) => const HelpSupportScreen(),
        ),
        GoRoute(path: about, builder: (context, state) => const AboutScreen()),
        GoRoute(
          path: '/my-devices',
          builder: (context, state) => const DevicesScreen(),
          routes: [
            GoRoute(
              path: 'telemetry',
              builder: (context, state) {
                if (state.extra is! DeviceItem) {
                  return const ErrorScreen(
                    title: 'Device not found',
                    message: 'Could not load device. Please go back and try again.',
                  );
                }
                return DeviceTelemetryScreen(device: state.extra as DeviceItem);
              },
            ),
          ],
        ),
        GoRoute(
          path: activity,
          builder: (context, state) => const RecentActivityScreen(),
        ),
        GoRoute(
          path: notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
            path: completeProfile,
            builder: (context, state) {
              final extra = state.extra as ProfileData?;
              return CompleteProfileScreen(profileData: extra);
            }),
        GoRoute(
          path: '/update-profile',
          builder: (context, state) => const UpdateProfileScreen(),
        ),
        GoRoute(
          path: congratulations,
          builder: (context, state) => const CongratulationsScreen(),
        ),
        GoRoute(
          path: '/my-order-tracking',
          builder: (context, state) {
            final order = state.extra as MyOrderListItem;
            return MyOrderTrackingScreen(order: order);
          },
        ),
        GoRoute(
          path: '/all-vets',
          builder: (context, state) {
            return AllVetsScreen();
          },
        ),
        GoRoute(
          path: '/vet-details',
          builder: (context, state) {
            final id = state.extra as String;
            return VetDetailsScreen(vetId: id);
          },
        ),
        GoRoute(
          path: '/my-vet-orders',
          builder: (context, state) {
            return MyVetOrdersScreen();
          },
        ),
        GoRoute(
          path: '/my-completed-orders',
          builder: (context, state) {
            return CompletedOrdersScreen();
          },
        ),
        GoRoute(
          path: vetOrderDetails,
          builder: (context, state) {
            final vet = state.extra;
            if (vet is! VetFarmer) {
              return const ErrorScreen(
                message: 'Could Not load the vet',
              );
            }
            return VetOrderScreen(vet: vet);
          },
        ),
        GoRoute(
          path: '/welcome-day1',
          builder: (context, state) => const Day1WelcomeScreen(),
        ),
        GoRoute(
          path: '/plan-transition',
          builder: (context, state) => const PlanTransitionScreen(),
        ),
        GoRoute(
          path: '/plans',
          builder: (context, state) => const PlansPreviewScreen(),
        ),

        // Vet payment routes (outside shell)
        // Shared notifications screen for vet users
        GoRoute(
          path: '/vet/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/vet/payments/history',
          builder: (context, state) => const VetPaymentsHistoryScreen(),
        ),
        GoRoute(
          path: '/vet/payment/service',
          builder: (context, state) => const VetServicePaymentScreen(
            serviceDetails: {
              'farmerName': 'John Peterson',
              'farmName': 'Green Valley Farm',
              'serviceType': 'Regular Checkup',
              'animals': '15 Dairy Cows',
              'serviceDate': 'Dec 15, 2023',
              'invoiceNumber': 'INV-2023-001',
              'totalAmount': 4500.00,
              'paidAmount': 0.00,
              'feeBreakdown': [
                {'type': 'Consultation Fee', 'amount': 2000.00},
                {'type': 'Vaccination Fee', 'amount': 1500.00},
                {'type': 'Mileage Fee', 'amount': 1000.00},
              ],
            },
          ),
        ),
      ],
    );
  }

  static String _getInitialLocation() {
    final hasSeenWelcome = SharedPrefs.getBool('hasSeenWelcome') ?? false;
    return hasSeenWelcome ? login : welcome;
  }
}

// ── Transition helpers ──────────────────────────────────────────

Page<void> _fadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
