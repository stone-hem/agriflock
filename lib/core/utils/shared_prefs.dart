import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _prefs;

  // Initialize SharedPreferences - Call this in main() before runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getter for SharedPreferences instance
  static SharedPreferences get prefs => _prefs;

  // ============================================
  // BOOLEAN OPERATIONS
  // ============================================

  // Save a boolean value
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  // Get a boolean value
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // ============================================
  // STRING OPERATIONS
  // ============================================

  // Save a string value
  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  // Get a string value
  static String? getString(String key) {
    return _prefs.getString(key);
  }

  // ============================================
  // INTEGER OPERATIONS
  // ============================================

  // Save an integer value
  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  // Get an integer value
  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // ============================================
  // DOUBLE OPERATIONS
  // ============================================

  // Save a double value
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  // Get a double value
  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // ============================================
  // STRING LIST OPERATIONS
  // ============================================

  // Save a string list
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  // Get a string list
  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // ============================================
  // REMOVE & CLEAR OPERATIONS
  // ============================================

  // Remove a specific key
  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all data
  static Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  static Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // ============================================
  // APP-SPECIFIC HELPER METHODS
  // ============================================

  // Onboarding
  static Future<bool> setSeenOnboarding(bool value) async {
    return await setBool('seenOnboarding', value);
  }

  static bool hasSeenOnboarding() {
    return getBool('seenOnboarding') ?? false;
  }

  // Get Started Screen
  static Future<bool> setSeenGetStarted(bool value) async {
    return await setBool('seenGetStarted', value);
  }

  static bool hasSeenGetStarted() {
    return getBool('seenGetStarted') ?? false;
  }

  // Theme preference
  static Future<bool> setDarkMode(bool value) async {
    return await setBool('darkMode', value);
  }

  static bool isDarkMode() {
    return getBool('darkMode') ?? false;
  }

  // Language preference
  static Future<bool> setLanguage(String languageCode) async {
    return await setString('language', languageCode);
  }

  static String getLanguage() {
    return getString('language') ?? 'en';
  }

  // Notifications enabled
  static Future<bool> setNotificationsEnabled(bool value) async {
    return await setBool('notificationsEnabled', value);
  }

  static bool areNotificationsEnabled() {
    return getBool('notificationsEnabled') ?? true;
  }

  // Biometric authentication
  static Future<bool> setBiometricEnabled(bool value) async {
    return await setBool('biometricEnabled', value);
  }

  static bool isBiometricEnabled() {
    return getBool('biometricEnabled') ?? false;
  }

  // First time user
  static Future<bool> setFirstTimeUser(bool value) async {
    return await setBool('firstTimeUser', value);
  }

  static bool isFirstTimeUser() {
    return getBool('firstTimeUser') ?? true;
  }

  // Last sync timestamp
  static Future<bool> setLastSyncTime(int timestamp) async {
    return await setInt('lastSyncTime', timestamp);
  }

  static int? getLastSyncTime() {
    return getInt('lastSyncTime');
  }

  // App version (for migration/update checks)
  static Future<bool> setAppVersion(String version) async {
    return await setString('appVersion', version);
  }

  static String? getAppVersion() {
    return getString('appVersion');
  }

  // User preferences as JSON string (for complex objects)
  static Future<bool> setUserPreferences(String jsonString) async {
    return await setString('userPreferences', jsonString);
  }

  static String? getUserPreferences() {
    return getString('userPreferences');
  }

  // Recent searches
  static Future<bool> addRecentSearch(String search) async {
    final searches = getRecentSearches();
    if (!searches.contains(search)) {
      searches.insert(0, search);
      // Keep only last 10 searches
      if (searches.length > 10) {
        searches.removeLast();
      }
    }
    return await setStringList('recentSearches', searches);
  }

  static List<String> getRecentSearches() {
    return getStringList('recentSearches') ?? [];
  }

  static Future<bool> clearRecentSearches() async {
    return await remove('recentSearches');
  }

  // Get initial route based on app state
  static String getInitialRoute() {
    final hasSeenOnboarding = getBool('seenOnboarding') ?? false;
    final hasSeenGetStarted = getBool('seenGetStarted') ?? false;

    if (!hasSeenGetStarted) {
      return '/splash';
    } else if (!hasSeenOnboarding) {
      return '/onboarding';
    } else {
      return '/';
    }
  }

  // ============================================
  // DEBUG HELPERS
  // ============================================

  // Print all stored values (for debugging)
  static void printAll() {
    final keys = getKeys();
    print('=== SharedPreferences Contents ===');
    for (final key in keys) {
      final value = _prefs.get(key);
      print('$key: $value');
    }
    print('================================');
  }

  // Get all data as Map (for debugging)
  static Map<String, dynamic> getAllData() {
    final keys = getKeys();
    final Map<String, dynamic> data = {};
    for (final key in keys) {
      data[key] = _prefs.get(key);
    }
    return data;
  }
}


// ============================================
// USAGE EXAMPLES
// ============================================

/*

// 1. Initialize in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp(const MyApp());
}

// 2. Save data
await SharedPrefs.setBool('seenOnboarding', true);
await SharedPrefs.setString('username', 'john_doe');
await SharedPrefs.setInt('loginCount', 5);
await SharedPrefs.setDouble('rating', 4.5);
await SharedPrefs.setStringList('favorites', ['item1', 'item2']);

// 3. Read data
bool hasSeenOnboarding = SharedPrefs.getBool('seenOnboarding') ?? false;
String? username = SharedPrefs.getString('username');
int loginCount = SharedPrefs.getInt('loginCount') ?? 0;
double rating = SharedPrefs.getDouble('rating') ?? 0.0;
List<String> favorites = SharedPrefs.getStringList('favorites') ?? [];

// 4. Use helper methods
await SharedPrefs.setSeenOnboarding(true);
bool hasSeenOnboarding = SharedPrefs.hasSeenOnboarding();

await SharedPrefs.setDarkMode(true);
bool isDark = SharedPrefs.isDarkMode();

await SharedPrefs.setLanguage('es');
String lang = SharedPrefs.getLanguage();

// 5. Recent searches
await SharedPrefs.addRecentSearch('flutter tutorial');
List<String> searches = SharedPrefs.getRecentSearches();
await SharedPrefs.clearRecentSearches();

// 6. Check if key exists
bool exists = SharedPrefs.containsKey('username');

// 7. Remove specific key
await SharedPrefs.remove('username');

// 8. Clear all data
await SharedPrefs.clear();

// 9. Get initial route
String route = SharedPrefs.getInitialRoute();

// 10. Debug - Print all values
SharedPrefs.printAll();

// 11. Debug - Get all data as map
Map<String, dynamic> allData = SharedPrefs.getAllData();
print(allData);

*/