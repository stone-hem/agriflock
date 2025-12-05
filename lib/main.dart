import 'package:agriflock360/lib/features/auth/quiz/onboarding_quiz_screen.dart';
import 'package:agriflock360/lib/features/batch/active_batches_screen.dart';
import 'package:agriflock360/lib/features/batch/add_batch_screen.dart';
import 'package:agriflock360/lib/features/batch/archived_batches_screen.dart';
import 'package:agriflock360/lib/features/batch/log_feeding_screen.dart';
import 'package:agriflock360/lib/features/batch/record_product_screen.dart';
import 'package:agriflock360/lib/features/batch/record_vaccination_screen.dart';
import 'package:agriflock360/lib/features/batch/schedule_vaccination_screen.dart';
import 'package:agriflock360/lib/features/farm/add_inventory_item_screen.dart';
import 'package:agriflock360/lib/features/farm/create_farm_screen.dart';
import 'package:agriflock360/dashboard.dart';
import 'package:agriflock360/device_screen.dart';
import 'package:agriflock360/lib/features/farm/add_farm_screen.dart';
import 'package:agriflock360/lib/features/farm/farms_home_screen.dart';
import 'package:agriflock360/lib/features/farm/inventory_screen.dart';
import 'package:agriflock360/lib/features/more/notifications_screen.dart';
import 'package:agriflock360/lib/features/more/recent_activity_screen.dart';
import 'package:agriflock360/lib/features/payg/payg_dashboard.dart';
import 'package:agriflock360/lib/features/payg/payment_history_screen.dart';
import 'package:agriflock360/lib/features/payg/payment_screen.dart';
import 'package:agriflock360/lib/features/profile/about_screen.dart';
import 'package:agriflock360/lib/features/profile/complete_profile_screen.dart';
import 'package:agriflock360/lib/features/profile/congratulations_screen.dart';
import 'package:agriflock360/lib/features/profile/help_support_screen.dart';
import 'package:agriflock360/lib/features/profile/settings_screen.dart';
import 'package:agriflock360/lib/features/profile/telemetry_data_screen.dart';
import 'package:agriflock360/lib/features/farm/batch_screen.dart';
import 'package:agriflock360/lib/features/auth/forgot_password_screen.dart';
import 'package:agriflock360/lib/features/auth/otp_screen.dart';
import 'package:agriflock360/lib/features/auth/reset_password_screen.dart';
import 'package:agriflock360/lib/features/auth/sign_in_screen.dart';
import 'package:agriflock360/lib/features/auth/sign_up_screen.dart';
import 'package:agriflock360/lib/features/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'lib/features/batch/batch_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Agriflock 360',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// Router Configuration
final GoRouter _router = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/onboarding-quiz',
      builder: (context, state) => const OnboardingQuestionsScreen(),),
    GoRoute(
      path: '/otp-verify',
      builder: (context, state) => const OTPVerifyScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/create-farm',
      builder: (context, state) => const CreateFarmScreen(),
    ),
    GoRoute(
      path: '/select-farm-type',
      builder: (context, state) => const SelectFarmTypeScreen(),
    ),
    GoRoute(
      path: '/device-setup',
      builder: (context, state) => const DeviceSetupScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const MainDashboard(),
    ),
    GoRoute(
      path: '/batches',
      builder: (context, state) => const BatchesScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddBatchScreen(),
        ),
        GoRoute(
          path: 'list',
          builder: (context, state) => ActiveBatchesScreen(),
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
          path: 'archived',
          builder: (context, state) => ArchivedBatchesScreen(),
        ),
        GoRoute(
          path: 'feed',
          builder: (context, state) => const LogFeedingScreen(),
        ),
        GoRoute(
          path: 'vaccination',
          builder: (context, state) => const RecordVaccinationScreen(),
        ),
        GoRoute(
          path: 'schedule',
          builder: (context, state) => const ScheduleVaccinationScreen(),
        ),
        GoRoute(
          path: '/:id/record-product',
          builder: (context, state) {
            final batchId = state.pathParameters['id']!;
            return RecordProductScreen(batchId: '123');
          },
        ),
      ],
    ),
    GoRoute(path: '/payg', builder: (context, state) => const PAYGDashboard()),
    GoRoute(
      path: '/payg/payment',
      builder: (context, state) => const PAYGPaymentScreen(),
    ),
    GoRoute(
      path: '/payg/history',
      builder: (context, state) => const PaymentHistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/telemetry',
      builder: (context, state) => const TelemetryDataScreen(),
    ),
    GoRoute(
      path: '/farms',
      builder: (context, state) => const FarmsHomeScreen(),
    ),
    GoRoute(
      path: '/farms/add',
      builder: (context, state) => const AddFarmScreen(),
    ),
    GoRoute(
      path: '/farms/inventory',
      builder: (context, state) => const InventoryScreen(farmId: '233'),
    ),
    GoRoute(
      path: '/farms/inventory/add',
      builder: (context, state) => const AddInventoryItemScreen(farmId: "233"),
    ),
    GoRoute(
      path: '/activity',
      builder: (context, state) => const RecentActivityScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(path: '/complete-profile/congratulations', builder: (context, state) => const CongratulationsScreen())
  ],
);
