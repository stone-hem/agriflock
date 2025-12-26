/// Comprehensive Date Utility for Flutter applications
/// Handles formatting, parsing, calculations, and validations
class DateUtil {
  // Private constructor to prevent instantiation
  DateUtil._();

  // ==================== FORMATTING ====================

  /// Format date to yyyy-MM-dd (e.g., 2024-03-15)
  static String toISODate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Format date to dd/MM/yyyy (e.g., 15/03/2024)
  static String toDDMMYYYY(DateTime date, {String separator = '/'}) {
    return '${date.day.toString().padLeft(2, '0')}$separator'
        '${date.month.toString().padLeft(2, '0')}$separator'
        '${date.year.toString().padLeft(4, '0')}';
  }

  /// Format date to MM/dd/yyyy (e.g., 03/15/2024)
  static String toMMDDYYYY(DateTime date, {String separator = '/'}) {
    return '${date.month.toString().padLeft(2, '0')}$separator'
        '${date.day.toString().padLeft(2, '0')}$separator'
        '${date.year.toString().padLeft(4, '0')}';
  }

  /// Format date to readable format (e.g., Mar 15, 2024)
  static String toReadableDate(DateTime date) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format date to full month name (e.g., March 15, 2024)
  static String toFullDate(DateTime date) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format date with day of week (e.g., Monday, Mar 15, 2024)
  static String toDateWithDay(DateTime date) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${dayNames[date.weekday - 1]}, ${toReadableDate(date)}';
  }

  /// Format date with short day of week (e.g., Mon, Mar 15)
  static String toShortDateWithDay(DateTime date) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dayNames[date.weekday - 1]}, ${monthNames[date.month - 1]} ${date.day}';
  }

  /// Format time to 12-hour format (e.g., 03:45 PM)
  static String to12HourTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  /// Format time to 24-hour format (e.g., 15:45)
  static String to24HourTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format to full datetime (e.g., Mar 15, 2024 at 03:45 PM)
  static String toFullDateTime(DateTime date) {
    return '${toReadableDate(date)} at ${to12HourTime(date)}';
  }

  /// Format to ISO 8601 format (e.g., 2024-03-15T15:45:30.000Z)
  static String toISO8601(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // ==================== PARSING ====================

  /// Parse ISO date string (yyyy-MM-dd) to DateTime
  static DateTime? parseISODate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse dd/MM/yyyy format to DateTime
  static DateTime? parseDDMMYYYY(String dateString, {String separator = '/'}) {
    try {
      final parts = dateString.split(separator);
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// Parse MM/dd/yyyy format to DateTime
  static DateTime? parseMMDDYYYY(String dateString, {String separator = '/'}) {
    try {
      final parts = dateString.split(separator);
      if (parts.length != 3) return null;

      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  // ==================== CALCULATIONS ====================

  /// Calculate age from date of birth
  static int calculateAge(DateTime birthDate, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Get difference in days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Get difference in months between two dates
  static int monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + to.month - from.month;
  }

  /// Get difference in years between two dates
  static int yearsBetween(DateTime from, DateTime to) {
    int years = to.year - from.year;
    if (to.month < from.month || (to.month == from.month && to.day < from.day)) {
      years--;
    }
    return years;
  }

  /// Add days to a date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Add months to a date
  static DateTime addMonths(DateTime date, int months) {
    int newMonth = date.month + months;
    int newYear = date.year;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    int newDay = date.day;
    final lastDayOfMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > lastDayOfMonth) {
      newDay = lastDayOfMonth;
    }

    return DateTime(newYear, newMonth, newDay, date.hour, date.minute, date.second);
  }

  /// Add years to a date
  static DateTime addYears(DateTime date, int years) {
    return DateTime(date.year + years, date.month, date.day, date.hour, date.minute, date.second);
  }

  // ==================== COMPARISONS ====================

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is a weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Check if date is a weekday
  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }

  // ==================== RELATIVE TIME ====================

  /// Get relative time string (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      // Future date
      final futureDiff = date.difference(now);

      if (futureDiff.inSeconds < 60) {
        return 'in ${futureDiff.inSeconds} seconds';
      } else if (futureDiff.inMinutes < 60) {
        return 'in ${futureDiff.inMinutes} ${futureDiff.inMinutes == 1 ? 'minute' : 'minutes'}';
      } else if (futureDiff.inHours < 24) {
        return 'in ${futureDiff.inHours} ${futureDiff.inHours == 1 ? 'hour' : 'hours'}';
      } else if (futureDiff.inDays < 7) {
        return 'in ${futureDiff.inDays} ${futureDiff.inDays == 1 ? 'day' : 'days'}';
      } else if (futureDiff.inDays < 30) {
        final weeks = (futureDiff.inDays / 7).floor();
        return 'in $weeks ${weeks == 1 ? 'week' : 'weeks'}';
      } else if (futureDiff.inDays < 365) {
        final months = (futureDiff.inDays / 30).floor();
        return 'in $months ${months == 1 ? 'month' : 'months'}';
      } else {
        final years = (futureDiff.inDays / 365).floor();
        return 'in $years ${years == 1 ? 'year' : 'years'}';
      }
    } else {
      // Past date
      if (difference.inSeconds < 60) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    }
  }

  /// Get smart relative time (shows "Today", "Yesterday", or date)
  static String getSmartRelativeTime(DateTime date) {
    if (isToday(date)) {
      return 'Today at ${to12HourTime(date)}';
    } else if (isYesterday(date)) {
      return 'Yesterday at ${to12HourTime(date)}';
    } else if (isTomorrow(date)) {
      return 'Tomorrow at ${to12HourTime(date)}';
    } else if (daysBetween(DateTime.now(), date).abs() < 7) {
      return '${toShortDateWithDay(date)} at ${to12HourTime(date)}';
    } else {
      return toFullDateTime(date);
    }
  }

  // ==================== VALIDATIONS ====================

  /// Validate if date is within a range
  static bool isWithinRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end) ||
        isSameDay(date, start) || isSameDay(date, end);
  }

  /// Validate if person is at least certain age
  static bool isAtLeastAge(DateTime birthDate, int minimumAge, {DateTime? referenceDate}) {
    return calculateAge(birthDate, referenceDate: referenceDate) >= minimumAge;
  }

  /// Validate if date is a valid date of birth (not future)
  static bool isValidDateOfBirth(DateTime date) {
    return date.isBefore(DateTime.now()) || isSameDay(date, DateTime.now());
  }

  /// Validate if date string is in correct format
  static bool isValidDateFormat(String dateString, String format) {
    try {
      switch (format.toLowerCase()) {
        case 'iso':
        case 'yyyy-mm-dd':
          return parseISODate(dateString) != null;
        case 'dd/mm/yyyy':
          return parseDDMMYYYY(dateString) != null;
        case 'mm/dd/yyyy':
          return parseMMDDYYYY(dateString) != null;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ==================== HELPERS ====================

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Get first day of week (Monday)
  static DateTime firstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Get last day of week (Sunday)
  static DateTime lastDayOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  /// Get number of days in month
  static int daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Get month name
  static String getMonthName(int month, {bool short = false}) {
    final monthNames = short
        ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        : ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];

    return month >= 1 && month <= 12 ? monthNames[month - 1] : '';
  }

  /// Get day name
  static String getDayName(int weekday, {bool short = false}) {
    final dayNames = short
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return weekday >= 1 && weekday <= 7 ? dayNames[weekday - 1] : '';
  }

  /// Get quarter of the year (1-4)
  static int getQuarter(DateTime date) {
    return ((date.month - 1) ~/ 3) + 1;
  }

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');
    if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
    if (minutes > 0) parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
    if (seconds > 0 && days == 0) parts.add('$seconds ${seconds == 1 ? 'second' : 'seconds'}');

    return parts.isEmpty ? '0 seconds' : parts.join(', ');
  }
}