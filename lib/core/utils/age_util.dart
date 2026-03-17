/// Utility for formatting batch age in a human-readable way.
class AgeUtil {
  /// Returns age as "X days" or "X days / Y weeks" when ≥ 7 days.
  /// e.g. 5 → "5 days", 15 → "15 days / 2 weeks", 14 → "14 days / 2 weeks"
  static String formatAge(int days) {
    if (days < 7) return '$days days';
    final weeks = days ~/ 7;
    return '$days days / $weeks weeks';
  }

  /// Returns vaccination schedule as "Day X" or "Day X / Week Y" when ≥ 7 days.
  /// e.g. 5 → "Day 5", 21 → "Day 21 / Week 3"
  static String formatVaccinationDay(int day) {
    if (day < 7) return 'Day $day';
    final week = day ~/ 7;
    return 'Day $day / Week $week';
  }
}
