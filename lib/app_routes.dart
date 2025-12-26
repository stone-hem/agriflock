import 'package:agriflock360/features/farmer/batch/add_batch_screen.dart';
import 'package:agriflock360/features/farmer/batch/adopt_schedule_screen.dart';
import 'package:agriflock360/features/farmer/batch/batch_details_screen.dart';
import 'package:agriflock360/features/farmer/batch/log_feeding_screen.dart';
import 'package:agriflock360/features/farmer/batch/quick_done_today_screen.dart';
import 'package:agriflock360/features/farmer/batch/record_product_screen.dart';
import 'package:agriflock360/features/farmer/batch/update_vaccination_status_screen.dart';
import 'package:agriflock360/features/farmer/farm/view/add_farm_screen.dart';
import 'package:agriflock360/features/farmer/farm/view/add_inventory_item_screen.dart';
import 'package:agriflock360/features/farmer/farm/view/batch_screen.dart';
import 'package:agriflock360/features/farmer/farm/view/farms_home_screen.dart';
import 'package:agriflock360/features/farmer/farm/view/inventory_screen.dart';
import 'package:agriflock360/features/farmer/more/notifications_screen.dart';
import 'package:agriflock360/features/farmer/more/recent_activity_screen.dart';
import 'package:agriflock360/features/farmer/payg/payg_dashboard.dart';
import 'package:agriflock360/features/farmer/payg/payment_history_screen.dart';
import 'package:agriflock360/features/farmer/payg/payment_screen.dart';
import 'package:agriflock360/features/farmer/payg/view_invoice.dart';
import 'package:agriflock360/features/farmer/profile/about_screen.dart';
import 'package:agriflock360/features/farmer/profile/complete_profile_screen.dart';
import 'package:agriflock360/features/farmer/profile/congratulations_screen.dart';
import 'package:agriflock360/features/farmer/profile/help_support_screen.dart';
import 'package:agriflock360/features/farmer/profile/settings_screen.dart';
import 'package:agriflock360/features/farmer/profile/telemetry_data_screen.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_officer.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_order.dart';
import 'package:agriflock360/features/farmer/vet/vet_details_screen.dart';
import 'package:agriflock360/features/farmer/vet/vet_order_screen.dart';
import 'package:agriflock360/features/farmer/vet/vet_order_tracking_screen.dart';
import 'package:agriflock360/features/farmer/vet/main_vet_screen.dart';
import 'package:agriflock360/features/vet/payments/vet_payments_history_screen.dart';
import 'package:agriflock360/features/vet/payments/vet_service_payments_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/utils/secure_storage.dart';
import 'core/utils/shared_prefs.dart';

import 'package:agriflock360/features/shared/dashboard.dart';
import 'package:agriflock360/features/farmer/device_screen.dart';
import 'package:agriflock360/features/auth/forgot_password_screen.dart';
import 'package:agriflock360/features/auth/otp_screen.dart';
import 'package:agriflock360/features/auth/quiz/onboarding_quiz_screen.dart';
import 'package:agriflock360/features/auth/reset_password_screen.dart';
import 'package:agriflock360/features/auth/sign_in_screen.dart';
import 'package:agriflock360/features/auth/sign_up_screen.dart';
import 'package:agriflock360/features/auth/welcome_screen.dart';

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
  static const String deviceSetup = '/device-setup';
  static const String dashboard = '/dashboard';
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
  static const String telemetry = '/telemetry';
  static const String farms = '/farms';
  static const String farmsAdd = '/farms/add';
  static const String farmsInventory = '/farms/inventory';
  static const String farmsInventoryAdd = '/farms/inventory/add';
  static const String activity = '/activity';
  static const String notifications = '/notifications';
  static const String completeProfile = '/complete-profile';
  static const String congratulations = '/complete-profile/congratulations';
  static const String vetOrderDetails = '/vet-order-details';

  // Define protected routes that require authentication
  static const List<String> _protectedRoutes = [
    dashboard,
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
    telemetry,
    farms,
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
  ];

  // Define onboarding routes
  static const List<String> _onboardingRoutes = [
    onboardingQuiz,
    congratulations,
  ];

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

        // If logged in and trying to access auth pages
        // redirect to dashboard
        if (isLoggedIn &&
            (currentPath == login ||
                currentPath == signup ||
                currentPath == welcome)) {
          return dashboard;
        }

        // If logged in and trying to access onboarding again
        if (isLoggedIn && hasCompletedOnboarding && isOnboardingRoute) {
          return dashboard;
        }

        // Allow access to password reset flows
        // Allow access to public pages
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: welcome,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(path: login, builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: onboardingQuiz,
          builder: (context, state) {
            final temptToken = state.uri.queryParameters['tempToken'];

            if (temptToken == null || temptToken.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Temp Token parameter is missing')),
              );
            }
            final decodedToken = Uri.decodeComponent(temptToken);
            return OnboardingQuestionsScreen(token: decodedToken);
          },
        ),
        GoRoute(
          path: otpVerifyEmailOrPhone,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'];

            if (email == null || email.isEmpty) {
              return const Scaffold(
                body: Center(child: Text('Email parameter is missing')),
              );
            }
            final decodedEmail = Uri.decodeComponent(email);

            return OTPVerifyScreen(email: decodedEmail);
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
          path: deviceSetup,
          builder: (context, state) => const DeviceSetupScreen(),
        ),
        GoRoute(
          path: dashboard,
          builder: (context, state) => const MainDashboard(),
        ),
        GoRoute(
          path: batches,
          builder: (context, state) => const BatchesScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddBatchScreen(),
            ),
            GoRoute(
              path: 'details',
              builder: (context, state) => BatchDetailsScreen(
                batch: {
                  "name": "Layer Batch 1",
                  "breed": "Kienyeji Improved",
                  "quantity": 320,
                  "age": 87,
                  "mortality": 5,
                },
              ),
            ),
            GoRoute(
              path: 'feed',
              builder: (context, state) => const LogFeedingScreen(),
            ),
            GoRoute(
              path: 'quick-done',
              builder: (context, state) => QuickDoneTodayScreen(),
            ),
            GoRoute(
              path: 'adopt-schedule',
              builder: (context, state) => AdoptScheduleScreen(),
            ),
            GoRoute(
              path: 'update-status',
              builder: (context, state) => UpdateVaccinationStatusScreen(
                vaccineName: 'Gumboro',
                scheduledDate: '2025-2-1',
              ),
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
        GoRoute(path: payg, builder: (context, state) => const PAYGDashboard()),
        GoRoute(
          path: paygPayment,
          builder: (context, state) => const PAYGPaymentScreen(),
        ),
        GoRoute(
          path: paygHistory,
          builder: (context, state) => const PaymentHistoryScreen(),
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
          path: telemetry,
          builder: (context, state) => const TelemetryDataScreen(),
        ),
        GoRoute(
          path: farms,
          builder: (context, state) => const FarmsHomeScreen(),
        ),
        GoRoute(
          path: farmsAdd,
          builder: (context, state) => const AddFarmScreen(),
        ),
        GoRoute(
          path: farmsInventory,
          builder: (context, state) => const InventoryScreen(farmId: '233'),
        ),
        GoRoute(
          path: farmsInventoryAdd,
          builder: (context, state) =>
              const AddInventoryItemScreen(farmId: "233"),
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
          builder: (context, state) => const CompleteProfileScreen(),
        ),
        GoRoute(
          path: congratulations,
          builder: (context, state) => const CongratulationsScreen(),
        ),
        GoRoute(
          path: '/vets',
          builder: (context, state) => const MainVetScreen(),
        ),

        GoRoute(
          path: '/vet-order-tracking',
          builder: (context, state) {
            final order = state.extra as VetOrder;
            return VetOrderTrackingScreen(order: order);
          },
        ),

        GoRoute(
          path: '/vet-details',
          builder: (context, state) {
            final vet = state.extra as VetOfficer;
            return VetDetailsScreen(vet: vet);
          },
        ),

        GoRoute(
          path: vetOrderDetails,
          builder: (context, state) {
            final vet = state.extra as VetOfficer;
            return VetOrderScreen(vet: vet);
          },
        ),

        //vet
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
