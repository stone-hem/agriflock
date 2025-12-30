import 'dart:io';
import 'package:agriflock360/core/network/api_client.dart';
import 'package:agriflock360/core/services/social_auth_service.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/utils/shared_prefs.dart';
import 'package:agriflock360/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

    // 4. Initialize Google Sign-In (CRITICAL - must be done after Firebase)
    // print('Initializing Google Sign-In...');
    // await authService.initializeGoogleSignIn();

    // 5. Initialize ApiClient
    print('Initializing ApiClient...');
    apiClient = ApiClient(storage: secureStorage, navigatorKey: navigatorKey);

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
          child: Text('Initialization Error: $e'),
        ),
      ),
    ));
  }
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
      routerConfig: AppRoutes.createRouter(
        secureStorage: secureStorage,
        navigatorKey: navigatorKey,
      ),
    );
  }
}