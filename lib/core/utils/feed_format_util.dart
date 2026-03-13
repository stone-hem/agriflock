/// Utility for formatting feed quantities using 50 kg bag units.
class FeedFormatUtil {
  /// Formats a feed quantity into a human-readable bags + kgs string.
  ///
  /// The [unit] parameter (e.g. "kgs", "kg") is used to decide whether
  /// bag-conversion applies. Non-kg units are returned as-is.
  ///
  /// Examples (kg unit):
  ///   100   → "2 bags"
  ///   56    → "1 bag 6kgs"
  ///   40    → "40kgs"
  ///   12.5  → "12.5kgs"
  static String formatQuantity(num quantity, String unit) {
    final normUnit = unit.trim().toLowerCase();
    if (normUnit == 'kg' || normUnit == 'kgs') {
      return _formatKg(quantity);
    }
    // Non-kg unit — just show the number + unit.
    final numStr = quantity == quantity.truncate()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '$numStr $unit';
  }

  /// Formats a raw kg value into bags + remainder kgs.
  ///
  /// Bag size is fixed at 50 kg.
  ///   56  → "1 bag 6kgs"
  ///   100 → "2 bags"
  ///   40  → "40kgs"
  static String formatKg(num kg) => _formatKg(kg);

  static String _formatKg(num kg) {
    if (kg >= 50) {
      final bags = (kg / 50).floor();
      final remainder = kg - bags * 50;
      final bagLabel = bags == 1 ? 'bag' : 'bags';
      if (remainder == 0) return '$bags $bagLabel';
      final remStr = remainder == remainder.truncate()
          ? remainder.toInt().toString()
          : remainder.toStringAsFixed(1);
      return '$bags $bagLabel ${remStr}kgs';
    }
    return kg == kg.truncate()
        ? '${kg.toInt()}kgs'
        : '${kg.toStringAsFixed(1)}kgs';
  }
}
