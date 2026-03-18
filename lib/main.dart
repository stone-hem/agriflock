import 'dart:io';
import 'package:agriflock/core/constants/app_constants.dart';
import 'package:agriflock/core/network/api_client.dart';
import 'package:agriflock/core/notifications/fcm_service.dart';
import 'package:agriflock/core/notifications/notification_service.dart';
import 'package:agriflock/core/services/social_auth_service.dart';
import 'package:agriflock/core/theme/theme.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:agriflock/core/utils/shared_prefs.dart';
import 'package:agriflock/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

// Create global instances
final authService = SocialAuthService();
late SecureStorage secureStorage;
late ApiClient apiClient;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== App Initialization Starting ===');

  try {
    //0 env
    await dotenv.load(fileName: ".env");
    // 1. Initialize SharedPreferences
    print('Initializing SharedPreferences...');
    await SharedPrefs.init();

    // 2. Initialize SecureStorage
    print('Initializing SecureStorage...');
    secureStorage = SecureStorage();

    // 3. Initialize Firebase
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // . Initialize Google Sign-In (CRITICAL - must be done after Firebase)
    // print('Initializing Google Sign-In...');
    // await authService.initializeGoogleSignIn();
    // 4. Stripe
    if(!dotenv.env.containsKey('STRIPE_PUBLISHABLE_KEY')){
      throw Exception('STRIPE_PUBLISHABLE_KEY is not set');
    }
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
    await Stripe.instance.applySettings();

    // 5. Initialize ApiClient
    print('Initializing ApiClient...');
    apiClient = ApiClient(storage: secureStorage, navigatorKey: navigatorKey);

    // 6. Initialize & connect NotificationService (if already logged in)
    print('Initializing NotificationService...');
    NotificationService.instance.initialize(secureStorage);
    final isLoggedIn = await secureStorage.isLoggedIn();
    if (isLoggedIn) {
      NotificationService.instance.connect();
      NotificationService.instance.fetchAndSeed();
    }

    // 7. Initialize FCM push notifications
    print('Initializing FCM...');
    await FCMService.instance.initialize(
      storage: secureStorage,
      navigatorKey: navigatorKey,
    );

    print('=== App Initialization Complete ===');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('=== INITIALIZATION ERROR ===');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    // You might want to show an error screen here
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Application crashed please report this to the developers'),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = AppRoutes.createRouter(
    secureStorage: secureStorage,
    navigatorKey: navigatorKey,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Agriflock 360',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}