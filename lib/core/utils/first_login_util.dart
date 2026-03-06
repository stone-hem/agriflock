import 'package:agriflock/app_routes.dart';
import 'package:agriflock/core/model/user_model.dart';
import 'package:agriflock/core/utils/secure_storage.dart';

class FirstLoginUtil {
  /// Check if this is the user's first login session.
  /// Only true when both [lastLogin] and [firstLogin] are null (brand-new account).
  static bool isFirstLogin(User? user) {
    if (user == null) return false;
    return user.lastLogin == null && user.firstLogin == null;
  }

  static bool isVetLogin(User? user) {
    if (user == null) return false;
    final roleName = user.role.name.toLowerCase();
    return roleName == 'extension_officer' || roleName == 'vet';
  }


  /// Get the appropriate redirect path based on login status
  static Future<String> getRedirectPath() async {
    final SecureStorage secureStorage = SecureStorage();
    final User? user = await secureStorage.getUserData();

    if(isVetLogin(user)){
      return AppRoutes.vetHome;
    }

    if (isFirstLogin(user)) {
      return '/welcome-day1';
    }

    final subscriptionState = await secureStorage.getSubscriptionState();
    final isSubscribed = subscriptionState == 'no_subscription_plan' || subscriptionState == 'expired_subscription_plan';
    if (isSubscribed) {
      return AppRoutes.browseVets; // non subscribed farmers land  vets
    }

    return AppRoutes.home;
  }
}