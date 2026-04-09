import 'dart:async';

import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/auth/repo/manual_auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ManualAuthRepository _authRepo = ManualAuthRepository();

  // Static flag so initialize() is only called once across all instances
  static bool _googleInitialized = false;

  final List<String> _googleScopes = [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  /// Sign in with Google
  Future<Result<Map<String, dynamic>>> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      // Set up a Completer BEFORE calling authenticate() so we
      // never miss the auth event regardless of timing.
      final userCompleter = Completer<GoogleSignInAccount>();

      final sub = GoogleSignIn.instance.authenticationEvents.listen(
        (event) {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            if (!userCompleter.isCompleted) {
              userCompleter.complete(event.user);
            }
          }
        },
        onError: (Object e) {
          if (!userCompleter.isCompleted) {
            userCompleter.completeError(e);
          }
        },
      );

      try {
        await GoogleSignIn.instance.authenticate();
      } on PlatformException catch (e) {
        await sub.cancel();
        if (e.code == 'sign_in_cancelled') {
          return const Failure(message: 'Sign in was cancelled', statusCode: 0);
        }
        return const Failure(
          message: 'Google sign in failed. Please try again.',
          statusCode: 0,
        );
      }

      // Await the user event — should arrive immediately after authenticate()
      final GoogleSignInAccount googleUser = await userCompleter.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Sign in timed out. Please try again.'),
      );

      await sub.cancel();

      // Get authorization (access token)
      GoogleSignInClientAuthorization? authorization =
          await googleUser.authorizationClient.authorizationForScopes(_googleScopes);

      authorization ??=
          await googleUser.authorizationClient.authorizeScopes(_googleScopes);

      final String accessToken = authorization.accessToken;

      // Sign in to Firebase with the Google access token
      final credential = GoogleAuthProvider.credential(accessToken: accessToken);
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return const Failure(message: 'Firebase authentication failed', statusCode: 0);
      }

      final String? firebaseIdToken = await firebaseUser.getIdToken();

      final Map<String, dynamic> authData = {
        'provider': 'google',
        'firebase_uid': firebaseUser.uid,
        'id_token': firebaseIdToken,
        'email': firebaseUser.email ?? googleUser.email,
        'display_name': firebaseUser.displayName ?? googleUser.displayName,
        'photo_url': firebaseUser.photoURL ?? googleUser.photoUrl,
        'access_token': accessToken,
      };

      // Optional: server auth code
      try {
        final serverAuth =
            await googleUser.authorizationClient.authorizeServer(_googleScopes);
        if (serverAuth != null) {
          authData['server_auth_code'] = serverAuth.serverAuthCode;
        }
      } catch (_) {}
      LogUtil.warning(authData);
      return _authRepo.socialLogin(authData: authData);
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_cancelled') {
        return const Failure(message: 'Sign in was cancelled', statusCode: 0);
      }
      return const Failure(message: 'Google sign in failed. Please try again.', statusCode: 0);
    } catch (e) {
      return const Failure(message: 'Google sign in failed. Please try again.', statusCode: 0);
    }
  }

  /// Sign in with Apple
  Future<Result<Map<String, dynamic>>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final Map<String, dynamic> authData = {
        'provider': 'apple',
        'identity_token': credential.identityToken,
        'authorization_code': credential.authorizationCode,
        'user_identifier': credential.userIdentifier,
        'email': credential.email,
        'given_name': credential.givenName,
        'family_name': credential.familyName,
      };

      return _authRepo.socialLogin(authData: authData);
    } catch (e) {
      return Failure(message: 'Apple sign in failed: $e', statusCode: 0);
    }
  }

  /// Sign out from Firebase and Google
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn.instance.disconnect(),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
