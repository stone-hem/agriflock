import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SecureStorage _secureStorage = SecureStorage();

  static const String baseUrl = "YOUR_API_URL";

  // Track current Google user from authentication events
  GoogleSignInAccount? _currentGoogleUser;

  // Stream subscription for Google sign-in events
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authEventSubscription;

  // Required scopes for Google Sign In
  final List<String> _googleScopes = [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  /// Initialize Google Sign In - MUST be called during app startup in main()
  Future<void> initializeGoogleSignIn() async {
    print('=== Initializing Google Sign-In ===');

    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      // Initialize with your client IDs (configured in android/app/build.gradle and Info.plist)
      // serverClientId is optional - only needed if you want server auth codes
      await signIn.initialize(
        // clientId: 'YOUR_WEB_CLIENT_ID', // Only needed for web
        // serverClientId: 'YOUR_WEB_CLIENT_ID', // Optional: for server-side auth
      );

      print('Google Sign-In initialized successfully');

      // Listen to authentication events to track current user state
      _authEventSubscription = signIn.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: _handleAuthenticationError,
      );

      // Attempt silent sign-in (if user was previously signed in)
      await signIn.attemptLightweightAuthentication();

      print('Lightweight authentication attempt completed');
    } catch (e) {
      print('Error initializing Google Sign-In: $e');
      rethrow;
    }
  }

  /// Handle authentication events from Google Sign-In
  Future<void> _handleAuthenticationEvent(
      GoogleSignInAuthenticationEvent event,
      ) async {
    print('Authentication event: ${event.runtimeType}');

    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        _currentGoogleUser = event.user;
        print('User signed in: ${event.user.email}');
        break;
      case GoogleSignInAuthenticationEventSignOut():
        _currentGoogleUser = null;
        print('User signed out');
        break;
    }
  }

  /// Handle authentication errors
  Future<void> _handleAuthenticationError(Object error) async {
    print('Authentication error: $error');
    _currentGoogleUser = null;
  }

  /// Sign in with Google using the new API
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('=== Starting Google Sign-In ===');
      final GoogleSignIn signIn = GoogleSignIn.instance;

      // 1. Trigger authentication flow (requires user interaction)
      print('Step 1: Calling authenticate()...');
      await signIn.authenticate();

      // 2. Wait a bit for the authentication event to propagate
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Get the current user from our tracked state
      final GoogleSignInAccount? googleUser = _currentGoogleUser;

      if (googleUser == null) {
        throw Exception("User cancelled Google sign-in or authentication failed");
      }

      print('Step 2: Got Google user: ${googleUser.email}');

      // 4. Check if user has already authorized the required scopes
      print('Step 3: Checking authorization...');
      GoogleSignInClientAuthorization? authorization =
      await googleUser.authorizationClient.authorizationForScopes(_googleScopes);

      // 5. If not authorized, request authorization
      if (authorization == null) {
        print('Step 4: Requesting authorization for scopes...');
        authorization = await googleUser.authorizationClient.authorizeScopes(_googleScopes);
      }

      final String accessToken = authorization.accessToken;

      print('Step 5: Got access token');

      // 6. Sign in to Firebase to verify the Google token
      print('Step 6: Signing in to Firebase...');
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Firebase authentication failed");
      }

      print('Step 7: Firebase authentication successful');

      // 7. Get Firebase ID Token (to send to your backend)
      final firebaseIdToken = await firebaseUser.getIdToken();

      // 8. Prepare data for YOUR backend
      final data = {
        "provider": "google",
        "firebase_uid": firebaseUser.uid,
        "id_token": firebaseIdToken,
        "email": firebaseUser.email ?? googleUser.email,
        "display_name": firebaseUser.displayName ?? googleUser.displayName,
        "photo_url": firebaseUser.photoURL ?? googleUser.photoUrl,
        "access_token": accessToken,
      };

      // 9. Optional: Get server auth code (only if you configured serverClientId)
      try {
        final serverAuth = await googleUser.authorizationClient.authorizeServer(_googleScopes);
        if (serverAuth != null) {
          data["server_auth_code"] = serverAuth.serverAuthCode;
          print('Got server auth code');
        }
      } catch (e) {
        print('Server auth not available: $e');
        // Server auth might not be configured or available on all platforms
      }

      print('Step 8: Sending data to backend...');

      // 10. Send to YOUR backend to get YOUR JWT token
      return await _authenticateWithBackend(data);
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      print('=== Starting Apple Sign-In ===');

      // Request Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'YOUR_CLIENT_ID', // Your Apple Service ID
          redirectUri: Uri.parse('YOUR_REDIRECT_URI'),
        ),
      );

      // Prepare data to send to your backend
      final Map<String, dynamic> requestData = {
        'provider': 'apple',
        'identity_token': credential.identityToken,
        'authorization_code': credential.authorizationCode,
        'user_identifier': credential.userIdentifier,
        'email': credential.email,
        'given_name': credential.givenName,
        'family_name': credential.familyName,
      };

      print('Apple Sign In Data prepared');

      // Send to your backend API
      final response = await _authenticateWithBackend(requestData);

      return response;
    } catch (e) {
      print('Error signing in with Apple: $e');
      throw Exception('Apple sign in failed: $e');
    }
  }

  /// Authenticate with YOUR backend API
  Future<Map<String, dynamic>> _authenticateWithBackend(
      Map<String, dynamic> authData,
      ) async {
    try {
      // UNCOMMENT THIS SECTION WHEN YOU'RE READY TO USE YOUR REAL API
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/auth/social-login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(authData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Store your backend JWT token
        if (responseData['data']?['access_token'] != null) {
          await _secureStorage.write(
            key: 'access_token',
            value: responseData['data']['access_token'],
          );
        }

        return responseData;
      } else {
        throw Exception('Backend authentication failed: ${response.body}');
      }
      */

      // SIMULATED API CALL - Remove this when using real API
      print('\n=== SIMULATED API CALL ===');
      print('POST $baseUrl/auth/social-login');
      print('Request Body: ${jsonEncode(authData)}');

      await Future.delayed(const Duration(seconds: 1));

      final simulatedResponse = {
        'success': true,
        'message': 'Authentication successful',
        'data': {
          'access_token': 'your_backend_jwt_token_here',
          'refresh_token': 'your_backend_refresh_token_here',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'user': {
            'id': 'user_123',
            'email': authData['email'] ?? 'user@example.com',
            'full_name': authData['display_name'] ??
                '${authData['given_name'] ?? ''} ${authData['family_name'] ?? ''}',
            'profile_picture': authData['photo_url'],
            'provider': authData['provider'],
            'firebase_uid': authData['firebase_uid'],
            'is_email_verified': true,
            'created_at': DateTime.now().toIso8601String(),
          }
        }
      };

      print('Simulated Response: ${jsonEncode(simulatedResponse)}');
      print('=== END SIMULATED API CALL ===\n');

      return simulatedResponse;
    } catch (e) {
      print('Backend authentication error: $e');
      rethrow;
    }
  }

  /// Sign out from Firebase and Google
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn.instance.disconnect(),
      ]);
      _currentGoogleUser = null;

      // Clear stored tokens
      await _secureStorage.delete('access_token');
      await _secureStorage.delete('refresh_token');

      print('Successfully signed out');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Clean up subscriptions
  void dispose() {
    _authEventSubscription?.cancel();
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Get current Google user from tracked state
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}