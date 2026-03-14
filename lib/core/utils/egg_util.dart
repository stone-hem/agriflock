/// Utility for egg / tray conversions.
///
/// Standard: 1 tray = 30 eggs.
class EggUtil {
  EggUtil._();

  static const int eggsPerTray = 30;

  /// Converts a raw egg count into a human-readable tray string.
  ///
  /// Examples:
  ///   0  → "0 eggs"
  ///   30 → "1 tray"
  ///   32 → "1 tray 2 eggs"
  ///   60 → "2 trays"
  ///   65 → "2 trays 5 eggs"
  static String eggsToTrayString(int eggs) {
    if (eggs <= 0) return '0 eggs';
    final trays = eggs ~/ eggsPerTray;
    final remainder = eggs % eggsPerTray;

    if (trays == 0) {
      return '$remainder ${remainder == 1 ? 'egg' : 'eggs'}';
    }
    final trayPart = '$trays ${trays == 1 ? 'tray' : 'trays'}';
    if (remainder == 0) return trayPart;
    return '$trayPart $remainder ${remainder == 1 ? 'egg' : 'eggs'}';
  }
}
