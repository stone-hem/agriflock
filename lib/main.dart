import 'dart:io'; // Add this import at the top
import 'package:agriflock360/core/network/api_client.dart';
import 'package:agriflock360/core/services/auth_service.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/core/utils/shared_prefs.dart';
import 'package:agriflock360/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// Create a global instance of AuthService
final authService = AuthService();
// Create global instances to access throughout the app
late SecureStorage secureStorage;
late ApiClient apiClient;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  await SharedPrefs.init();

  // Initialize SecureStorage and ApiClient
  secureStorage = SecureStorage();
  apiClient = ApiClient(storage: secureStorage, navigatorKey: navigatorKey);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Google Sign-In only for Android
  await authService.initializeGoogleSignIn(
    clientId: DefaultFirebaseOptions.currentPlatform.iosClientId,
    serverClientId:
        '966300580112-mu5f3anb1ff4rce7dts.apps.googleusercontent.com',
  );

  runApp(MyApp());
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
