import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';

class AuthService {
  // Use GoogleSignIn.instance for singleton access
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Your API base URL
  static const String baseUrl = 'YOUR_API_BASE_URL'; // e.g., 'https://api.agriflock360.com'

  // Initialize Google Sign In
  Future<void> initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        // clientId: 'YOUR_CLIENT_ID', // For web apps
        // serverClientId: 'YOUR_SERVER_CLIENT_ID', // For server auth code
      );

      // Listen to authentication events
      _googleSignIn.authenticationEvents.listen((event) {
        print('Google Sign In Event: $event');
      });
    } catch (e) {
      print('Error initializing Google Sign In: $e');
    }
  }

  /// Sign in with Google and authenticate with your backend
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Step 1: Initialize if not already done
      // if (!_googleSignIn.isInitialized) {
        await initializeGoogleSignIn();
      // }

      // Step 2: Check if we can authenticate
      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception('Google Sign In not supported on this platform');
      }

      // Step 3: Authenticate with Google
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Step 4: Get authorization for scopes
      final scopes = ['email', 'profile'];
      final GoogleSignInClientAuthorization authorization = await googleUser
          .authorizationClient
          .authorizeScopes(scopes);

      // Step 5: Get authentication tokens from authorization headers
      final Map<String, String>? authHeaders = await googleUser
          .authorizationClient
          .authorizationHeaders(scopes);

      if (authHeaders == null) {
        throw Exception('Failed to get authorization headers');
      }

      // Extract tokens from headers (simplified - actual implementation may vary)
      final idToken = _extractIdTokenFromHeaders(authHeaders);
      final accessToken = _extractAccessTokenFromHeaders(authHeaders);

      // Step 6: Prepare data to send to your backend
      final Map<String, dynamic> requestData = {
        'provider': 'google',
        'id_token': idToken,
        'access_token': accessToken,
        'email': googleUser.email,
        'display_name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
      };

      print('Google Sign In Data to send to API:');
      print(jsonEncode(requestData));

      // Step 7: Send to your backend API
      final response = await _authenticateWithBackend(requestData);

      return response;
    } catch (e) {
      print('Error signing in with Google: $e');
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Alternative simplified sign in method
  Future<Map<String, dynamic>> signInWithGoogleSimple() async {
    try {
      // Initialize Google Sign In
      await initializeGoogleSignIn();

      // Authenticate
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled by user');
      }

      // Get authorization for basic scopes
      final scopes = ['email', 'profile'];
      final authorization = await googleUser
          .authorizationClient
          .authorizeScopes(scopes);

      // Get user info
      final userInfo = {
        'provider': 'google',
        'email': googleUser.email,
        'display_name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
        'id': googleUser.id,
      };

      // Get server auth code if available (for server-side verification)
      final serverAuth = await googleUser.authorizationClient.authorizeServer(scopes);
      if (serverAuth != null) {
        userInfo['server_auth_code'] = serverAuth.serverAuthCode;
      }

      print('Google User Info: $userInfo');

      // Authenticate with backend
      final response = await _authenticateWithBackend(userInfo);
      return response;
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  /// Sign in with Apple and authenticate with your backend
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      // Step 1: Request Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'YOUR_CLIENT_ID', // Your Apple Service ID
          redirectUri: Uri.parse('YOUR_REDIRECT_URI'), // Your redirect URI
        ),
      );

      // Step 2: Prepare data to send to your backend
      final Map<String, dynamic> requestData = {
        'provider': 'apple',
        'identity_token': credential.identityToken,
        'authorization_code': credential.authorizationCode,
        'user_identifier': credential.userIdentifier,
        'email': credential.email,
        'given_name': credential.givenName,
        'family_name': credential.familyName,
      };

      print('Apple Sign In Data to send to API:');
      print(jsonEncode(requestData));

      // Step 3: Send to your backend API
      final response = await _authenticateWithBackend(requestData);

      return response;
    } catch (e) {
      print('Error signing in with Apple: $e');
      throw Exception('Apple sign in failed: $e');
    }
  }

  /// Authenticate with your backend API
  Future<Map<String, dynamic>> _authenticateWithBackend(
      Map<String, dynamic> authData,
      ) async {
    try {
      // SIMULATED API CALL - Replace with actual API endpoint
      print('\n=== SIMULATED API CALL ===');
      print('POST $baseUrl/auth/social-login');
      print('Request Body: ${jsonEncode(authData)}');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // SIMULATED RESPONSE
      final simulatedResponse = {
        'success': true,
        'message': 'Authentication successful',
        'data': {
          'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          'refresh_token': 'refresh_token_here',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'user': {
            'id': 'user_123',
            'email': authData['email'] ?? 'user@example.com',
            'full_name': authData['display_name'] ??
                '${authData['given_name'] ?? ''} ${authData['family_name'] ?? ''}',
            'phone': null,
            'profile_picture': authData['photo_url'],
            'provider': authData['provider'],
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

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      print('Successfully signed out from Google');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Check if user is signed in
  // Future<bool> isSignedIn() async {
  //   try {
  //     // Get current user
  //     final currentUser = _googleSignIn.currentUser;
  //     return currentUser != null;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  /// Get current user if signed in
  // Future<GoogleSignInAccount?> getCurrentUser() async {
  //   return _googleSignIn.currentUser;
  // }

  /// Helper method to extract ID token from authorization headers
  String? _extractIdTokenFromHeaders(Map<String, String> headers) {
    // This is a simplified example. You may need to parse the actual headers
    // based on how Google returns them in your specific setup.
    final authHeader = headers['Authorization'];
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }
    return null;
  }

  /// Helper method to extract access token from authorization headers
  String? _extractAccessTokenFromHeaders(Map<String, String> headers) {
    // This is a simplified example. The actual extraction may vary.
    return headers['X-Access-Token'];
  }
}