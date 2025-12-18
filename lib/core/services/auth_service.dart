// import 'package:agriflock360/core/utils/secure_storage.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:google_sign_in/google_sign_in.dart';
// import 'dart:async';
//
// class AuthService {
//   // final FirebaseAuth _auth = FirebaseAuth.instance;
//   final SecureStorage _secureStorage = SecureStorage();
//
//   static const String baseUrl = "YOUR_API_URL";
//
//   // Store the current Google user from the stream
//   GoogleSignInAccount? _currentGoogleUser;
//
//   // Stream subscription for Google sign-in events
//   StreamSubscription<GoogleSignInAuthenticationEvent>? _authEventSubscription;
//
//   // Completer to wait for authentication event
//   Completer<GoogleSignInAccount?>? _authCompleter;
//
//   // Required scopes for Google Sign In
//   final List<String> _googleScopes = [
//     'email',
//     'profile',
//   ];
//
//   /// Initialize Google Sign In - call this during app startup
//   Future<void> initializeGoogleSignIn({
//     String? clientId,
//     String? serverClientId,
//   }) async {
//     print('=== Initializing Google Sign-In ===');
//     print('clientId: $clientId');
//     print('serverClientId: $serverClientId');
//
//     try {
//       final GoogleSignIn signIn = GoogleSignIn.instance;
//
//       await signIn.initialize(
//         clientId: clientId,
//         serverClientId: serverClientId,
//       );
//
//       print('Google Sign-In initialized successfully');
//
//       // Listen to authentication events to track current user
//       _authEventSubscription = signIn.authenticationEvents.listen(
//             (GoogleSignInAuthenticationEvent event) {
//           switch (event) {
//             case GoogleSignInAuthenticationEventSignIn():
//               _currentGoogleUser = event.user;
//               // Complete the auth completer if waiting
//               if (_authCompleter != null && !_authCompleter!.isCompleted) {
//                 _authCompleter!.complete(event.user);
//               }
//               break;
//             case GoogleSignInAuthenticationEventSignOut():
//               _currentGoogleUser = null;
//               // Complete with null if waiting during sign out
//               if (_authCompleter != null && !_authCompleter!.isCompleted) {
//                 _authCompleter!.complete(null);
//               }
//               break;
//           }
//         },
//       );
//
//       // Attempt silent sign-in on startup
//       await signIn.attemptLightweightAuthentication();
//     } catch (e) {
//       print('Error initializing Google Sign-In: $e');
//       rethrow;
//     }
//   }
//
//   Future<Map<String, dynamic>> signInWithGoogle() async {
//     try {
//       final GoogleSignIn signIn = GoogleSignIn.instance;
//
//       // Create a completer to wait for the authentication event
//       _authCompleter = Completer<GoogleSignInAccount?>();
//
//       // 1. Trigger authentication flow (user interaction)
//       await signIn.authenticate();
//
//       // 2. Wait for the authentication event to propagate
//       final GoogleSignInAccount? googleUser = await _authCompleter!.future
//           .timeout(
//         const Duration(seconds: 10),
//         onTimeout: () => null,
//       );
//
//       // Reset completer
//       _authCompleter = null;
//
//       if (googleUser == null) {
//         throw Exception("User cancelled Google sign-in or authentication failed");
//       }
//
//       // 3. Request authorization for the required scopes
//       final GoogleSignInClientAuthorization? authorization =
//       await googleUser.authorizationClient.authorizationForScopes(_googleScopes);
//
//       String? accessToken;
//       if (authorization != null) {
//         accessToken = authorization.accessToken;
//       } else {
//         // If not previously authorized, request authorization
//         final newAuth = await googleUser.authorizationClient.authorizeScopes(_googleScopes);
//         accessToken = newAuth.accessToken;
//       }
//
//       if (accessToken == null) {
//         throw Exception("Failed to get access token");
//       }
//
//       // 4. Sign in to Firebase ONLY to verify the Google token
//       // You're using Firebase just for authentication, not for persistence
//       // final credential = GoogleAuthProvider.credential(
//       //   accessToken: accessToken,
//       // );
//       //
//       // final UserCredential userCredential =
//       // await _auth.signInWithCredential(credential);
//       //
//       // final User? firebaseUser = userCredential.user;
//
//       // if (firebaseUser == null) {
//       //   throw Exception("Firebase authentication failed");
//       // }
//       //
//       // // 5. Get Firebase ID Token (this is what you'll send to your backend)
//       // final firebaseIdToken = await firebaseUser.getIdToken();
//       //
//       // // 6. Prepare data for YOUR backend (not Firebase)
//       // final data = {
//       //   "provider": "google",
//       //   "firebase_uid": firebaseUser.uid,
//       //   "id_token": firebaseIdToken, // Your backend will verify this
//       //   "email": firebaseUser.email ?? googleUser.email,
//       //   "display_name": firebaseUser.displayName ?? googleUser.displayName,
//       //   "photo_url": firebaseUser.photoURL ?? googleUser.photoUrl,
//       //   "access_token": accessToken, // Google's access token
//       // };
//
//       // Optional: Get server auth code if needed for backend
//       // try {
//       //   final serverAuth = await googleUser.authorizationClient.authorizeServer(_googleScopes);
//       //   if (serverAuth != null) {
//       //     data["server_auth_code"] = serverAuth.serverAuthCode;
//       //   }
//       // } catch (e) {
//       //   print('Server auth not available: $e');
//       //   // Server auth might not be available on all platforms
//       // }
//       //
//       // // 7. Send to YOUR backend to get YOUR JWT token
//       // return await _authenticateWithBackend(data);
//     } catch (e) {
//       print("Google Sign-In Error: $e");
//       _authCompleter = null; // Reset on error
//       rethrow;
//     }
//   }
//
//   /// Sign in with Apple
//   Future<Map<String, dynamic>> signInWithApple() async {
//     try {
//       // Step 1: Request Apple Sign In
//       final credential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//         webAuthenticationOptions: WebAuthenticationOptions(
//           clientId: 'YOUR_CLIENT_ID', // Your Apple Service ID
//           redirectUri: Uri.parse('YOUR_REDIRECT_URI'), // Your redirect URI
//         ),
//       );
//
//       // Step 2: Prepare data to send to your backend
//       final Map<String, dynamic> requestData = {
//         'provider': 'apple',
//         'identity_token': credential.identityToken,
//         'authorization_code': credential.authorizationCode,
//         'user_identifier': credential.userIdentifier,
//         'email': credential.email,
//         'given_name': credential.givenName,
//         'family_name': credential.familyName,
//       };
//
//       print('Apple Sign In Data to send to API:');
//       print(jsonEncode(requestData));
//
//       // Step 3: Send to your backend API
//       final response = await _authenticateWithBackend(requestData);
//
//       return response;
//     } catch (e) {
//       print('Error signing in with Apple: $e');
//       throw Exception('Apple sign in failed: $e');
//     }
//   }
//
//   /// Authenticate with YOUR backend API (not Firebase)
//   /// Your backend will:
//   /// 1. Verify the Firebase ID token
//   /// 2. Create/update user in your database
//   /// 3. Return YOUR JWT token for your API
//   Future<Map<String, dynamic>> _authenticateWithBackend(
//       Map<String, dynamic> authData,
//       ) async {
//     try {
//       // UNCOMMENT THIS SECTION WHEN YOU'RE READY TO USE YOUR REAL API
//       /*
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/social-login'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(authData),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//         return responseData;
//       } else {
//         throw Exception('Backend authentication failed: ${response.body}');
//       }
//       */
//
//       // SIMULATED API CALL - Remove this when using real API
//       print('\n=== SIMULATED API CALL ===');
//       print('POST $baseUrl/auth/social-login');
//       print('Request Body: ${jsonEncode(authData)}');
//
//       // Simulate network delay
//       await Future.delayed(const Duration(seconds: 1));
//
//       // SIMULATED RESPONSE - Your backend will return YOUR JWT
//       final simulatedResponse = {
//         'success': true,
//         'message': 'Authentication successful',
//         'data': {
//           'access_token': 'your_backend_jwt_token_here', // YOUR JWT, not Firebase's
//           'refresh_token': 'your_backend_refresh_token_here',
//           'token_type': 'Bearer',
//           'expires_in': 3600,
//           'user': {
//             'id': 'user_123', // Your database user ID
//             'email': authData['email'] ?? 'user@example.com',
//             'full_name': authData['display_name'] ??
//                 '${authData['given_name'] ?? ''} ${authData['family_name'] ?? ''}',
//             'phone': authData['phone'],
//             'profile_picture': authData['photo_url'],
//             'provider': authData['provider'],
//             'firebase_uid': authData['firebase_uid'],
//             'is_email_verified': true,
//             'created_at': DateTime.now().toIso8601String(),
//           }
//         }
//       };
//
//       print('Simulated Response: ${jsonEncode(simulatedResponse)}');
//       print('=== END SIMULATED API CALL ===\n');
//
//       return simulatedResponse;
//     } catch (e) {
//       print('Backend authentication error: $e');
//       rethrow;
//     }
//   }
//
//
//   /// Sign out from Firebase and Google
//   Future<void> signOut() async {
//     try {
//       // Sign out from both Firebase and Google
//       await Future.wait([
//         _auth.signOut(),
//         GoogleSignIn.instance.disconnect(),
//       ]);
//       _currentGoogleUser = null;
//       print('Successfully signed out');
//     } catch (e) {
//       print('Error signing out: $e');
//       rethrow;
//     }
//   }
//
//   /// Clean up subscriptions
//   void dispose() {
//     _authEventSubscription?.cancel();
//     _authCompleter = null;
//   }
//
//   /// Get current Firebase user (temporary, just for Google auth verification)
//   User? get currentUser => _auth.currentUser;
//
//   /// Get current Google user from tracked state
//   GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;
//
//   /// Check if user is signed in (to Google via Firebase)
//   bool get isSignedIn => _auth.currentUser != null;
//
//   /// Stream of auth state changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
// }