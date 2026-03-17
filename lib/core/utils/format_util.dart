/// Utility for formatting numbers with thousand separators.
class FormatUtil {
  /// Formats [value] with thousand-comma separators and 2 decimal places.
  /// e.g. 1234567.89 → "1,234,567.89"
  static String formatAmount(double value) {
    final isNegative = value < 0;
    final abs = value.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '${isNegative ? '-' : ''}${buffer.toString()}.$decPart';
  }
}
