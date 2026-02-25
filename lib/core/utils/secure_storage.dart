import 'dart:ffi';

import 'package:agriflock360/core/model/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _sessionKey = 'session_id';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _currencyKey = 'currency';
  static const String _subscriptionState = 'subscription_state';


  // Token operations
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: _sessionKey, value: sessionId);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Refresh token operations
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getSessionId() async {
    return await _storage.read(key: _sessionKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // Token expiry operations
  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
  }

  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryStr != null) {
      return DateTime.parse(expiryStr);
    }
    return null;
  }

  Future<void> deleteTokenExpiry() async {
    await _storage.delete(key: _tokenExpiryKey);
  }

  // Check if token is expired or about to expire (within 5 minutes)
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return false;

    // Consider token expired if it expires within 5 minutes
    final now = DateTime.now();
    final bufferTime = const Duration(minutes: 5);
    return now.add(bufferTime).isAfter(expiry);
  }

  // User data operations (store as JSON)
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  Future<void> saveUser(User user) async {
    try {
      await saveUserData(user.toJson());
    } catch (e) {
      print('Error saving user object: $e');
      rethrow;
    }
  }

  // CORRECTED: Get user data as User object
  Future<User?> getUserData() async {
    try {
      final data = await _storage.read(key: _userKey);
      if (data != null) {
        final Map<String, dynamic> userMap = jsonDecode(data);
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  // Alternative: Get user data as Map for flexibility
  Future<Map<String, dynamic>?> getUserDataAsMap() async {
    try {
      final data = await _storage.read(key: _userKey);
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error retrieving user data as map: $e');
      return null;
    }
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: _userKey);
  }

  // Individual user fields
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: _nameKey, value: name);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _nameKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  //save currency
  Future<void> saveCurrency(String currency) async {
    await _storage.write(key: _currencyKey, value: currency);
  }

  //get currency
  Future<String> getCurrency() async {
    try{
      return await _storage.read(key: _currencyKey)??'USD';
    }catch(e){
      return 'USD';
    }

  }

  //save subscription state
  Future<void> saveSubscriptionState(String subscriptionState) async {
    await _storage.write(key: _subscriptionState, value: subscriptionState);
  }

  //get currency
  Future<String> getSubscriptionState() async {
    try{
      return await _storage.read(key: _subscriptionState)??'no_subscription_plan';
    }catch(e){
      return 'no_subscription_plan';
    }

  }


  // Save complete login response
  Future<void> saveLoginData({
    required String token,
    String? refreshToken,
    Map<String, dynamic>? userData,
    required String sessionId,
    DateTime? tokenExpiry,
    int? expiresInSeconds, // If API returns expiry in seconds
    required String currency,
  }) async {
    await saveToken(token);
    await saveSessionId(sessionId);
    await saveCurrency(currency);

    // Save refresh token

    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }

    // Save token expiry
    if (tokenExpiry != null) {
      await saveTokenExpiry(tokenExpiry);
    } else if (expiresInSeconds != null) {
      final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));
      await saveTokenExpiry(expiry);
    }

    if (userData != null) {
      await saveUserData(userData);
      // Also save individual fields for quick access
      if (userData['id'] != null) {
        await saveUserId(userData['id'].toString());
      }
      if (userData['email'] != null) {
        await saveUserEmail(userData['email'].toString());
      }
      if (userData['name'] != null) {
        await saveUserName(userData['name'].toString());
      }
    }



  }

  // Update tokens after refresh
  Future<void> updateTokens({
    required String token,
    String? refreshToken,
    DateTime? tokenExpiry,
    int? expiresInSeconds,
  }) async {
    await saveToken(token);

    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }

    if (tokenExpiry != null) {
      await saveTokenExpiry(tokenExpiry);
    } else if (expiresInSeconds != null) {
      final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));
      await saveTokenExpiry(expiry);
    }
  }

  // Read specific value
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Write specific value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Delete specific value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}