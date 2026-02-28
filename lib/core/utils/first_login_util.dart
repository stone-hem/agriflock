import 'package:agriflock/app_routes.dart';
import 'package:agriflock/core/model/user_model.dart';
import 'package:agriflock/core/utils/date_util.dart';
import 'package:agriflock/core/utils/secure_storage.dart';

class FirstLoginUtil {
  /// Check if this is the user's first login session
  /// Returns true if:
  /// 1. Both lastLogin and firstLogin are null (brand new user)
  /// 2. lastLogin is null but firstLogin exists (first login after account creation)
  /// 3. lastLogin and firstLogin are the same (first time actually logging in)
  static bool isFirstLogin(User? user) {
    if (user == null) return false;

    // Case 1: Brand new user - both are null
    if (user.lastLogin == null && user.firstLogin == null) {
      return true;
    }

    // Case 2: First login after account creation
    if (user.lastLogin == null && user.firstLogin != null) {
      return true;
    }

    // Case 3: lastLogin equals firstLogin (first time logging in)
    if (user.lastLogin != null && user.firstLogin != null) {
      final parsedLastLogin =DateUtil.parseISODate(user.lastLogin!);
      final parsedFirstLogin =DateUtil.parseISODate(user.firstLogin!);

      // Compare dates ignoring time for accuracy
      final lastLoginDate = DateTime(
        parsedLastLogin!.year,
        parsedLastLogin.month,
        parsedLastLogin.day,
        parsedLastLogin.hour,
        parsedLastLogin.minute,
        parsedLastLogin.second,
      );
      final firstLoginDate = DateTime(
        parsedFirstLogin!.year,
        parsedFirstLogin.month,
        parsedFirstLogin.day,
        parsedFirstLogin.hour,
        parsedFirstLogin.minute,
        parsedFirstLogin.second,
      );

      return lastLoginDate.isAtSameMomentAs(firstLoginDate);
    }

    return false;
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