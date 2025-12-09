import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';

class AuthService {
  // Create GoogleSignIn instance with configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Your API base URL
  static const String baseUrl = 'YOUR_API_BASE_URL'; // e.g., 'https://api.agriflock360.com'

  /// Sign in with Google and authenticate with your backend
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled by user');
      }

      // Step 2: Get authentication tokens (in v7.2.0, you need to get auth tokens separately)
      // First, sign in to get the account
      await _googleSignIn.disconnect(); // Clear any previous session
      await _googleSignIn.signInSilently(); // Try silent sign in first

      // Get the authentication object
      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      if (googleAuth == null || googleAuth.idToken == null) {
        throw Exception('Failed to get authentication tokens');
      }

      // Step 3: Prepare data to send to your backend
      final Map<String, dynamic> requestData = {
        'provider': 'google',
        'id_token': googleAuth.idToken,
        'access_token': googleAuth.accessToken, // Note: This might be null on some platforms
        'email': googleUser.email,
        'display_name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
      };

      print('Google Sign In Data to send to API:');
      print(jsonEncode(requestData));

      // Step 4: Send to your backend API
      final response = await _authenticateWithBackend(requestData);

      return response;
    } catch (e) {
      print('Error signing in with Google: $e');
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Alternative approach using signIn method directly
  Future<Map<String, dynamic>> signInWithGoogleAlt() async {
    try {
      // Initialize GoogleSignIn
      await _googleSignIn.disconnect(); // Clear any existing session

      // Sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled by user');
      }

      // Get the current user after sign in
      final currentUser = _googleSignIn.currentUser;
      if (currentUser == null) {
        throw Exception('Failed to get current user');
      }

      // Get authentication
      final auth = await currentUser.authentication;

      final Map<String, dynamic> requestData = {
        'provider': 'google',
        'id_token': auth.idToken,
        'access_token': auth.accessToken,
        'email': currentUser.email,
        'display_name': currentUser.displayName,
        'photo_url': currentUser.photoUrl,
      };

      print('Google Sign In Data to send to API:');
      print(jsonEncode(requestData));

      return await _authenticateWithBackend(requestData);
    } catch (e) {
      print('Error signing in with Google: $e');
      throw Exception('Google sign in failed: $e');
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
      // Clear any stored tokens from secure storage
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    try {
      // Try to sign in silently to check if user is already authenticated
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  /// Get current user if signed in
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }
}