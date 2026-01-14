import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateTextFormatter extends TextInputFormatter {
  static const String mask = 'DD/MM/YYYY';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;
    final oldText = oldValue.text;

    // If user is deleting
    if (text.length < oldText.length) {
      final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
      return _formatWithMask(digitsOnly, true);
    }

    // Remove all non-digit characters for new input
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    // Validate and restrict input in real-time
    digitsOnly = _validateAndRestrictInput(digitsOnly);

    return _formatWithMask(digitsOnly, false);
  }

  String _validateAndRestrictInput(String digits) {
    if (digits.isEmpty) return digits;

    String result = '';

    // Day validation (first 2 digits)
    if (digits.length >= 1) {
      int firstDigit = int.parse(digits[0]);
      // First digit of day can only be 0-3
      if (firstDigit > 3) {
        result += '0${digits[0]}';
        if (digits.length > 1) {
          digits = digits.substring(1);
        }
      } else {
        result += digits[0];
      }

      if (digits.length >= 2) {
        int day = int.parse(result + digits[1]);
        if (day > 31) {
          // If day exceeds 31, keep only first digit
          return result;
        }
        if (day == 0) {
          // Don't allow day 00
          return result;
        }
        result += digits[1];
        digits = digits.substring(2);
      } else {
        return result;
      }
    }

    // Month validation (next 2 digits)
    if (digits.length >= 1) {
      int firstDigit = int.parse(digits[0]);
      // First digit of month can only be 0 or 1
      if (firstDigit > 1) {
        result += '0${digits[0]}';
        if (digits.length > 1) {
          digits = digits.substring(1);
        }
      } else {
        result += digits[0];
      }

      if (digits.length >= 2) {
        int month = int.parse(result.substring(2) + digits[1]);
        if (month > 12) {
          // If month exceeds 12, keep only first digit
          return result;
        }
        if (month == 0) {
          // Don't allow month 00
          return result;
        }
        result += digits[1];
        digits = digits.substring(2);

        // Now validate day based on month and year (if available)
        int day = int.parse(result.substring(0, 2));
        int maxDay = _getMaxDayForMonth(month, result.length >= 8 ? int.parse(result.substring(4, 8)) : null);

        if (day > maxDay) {
          // Adjust day to max allowed for this month
          return result.substring(0, 2).replaceFirst(result.substring(0, 2), maxDay.toString().padLeft(2, '0')) + result.substring(2);
        }
      } else {
        return result;
      }
    }

    // Year validation (last 4 digits) - allow any year
    if (digits.length >= 1) {
      // Limit year to 4 digits
      result += digits.substring(0, digits.length > 4 ? 4 : digits.length);

      // Re-validate day if we now have complete year for leap year check
      if (result.length == 8) {
        int day = int.parse(result.substring(0, 2));
        int month = int.parse(result.substring(2, 4));
        int year = int.parse(result.substring(4, 8));
        int maxDay = _getMaxDayForMonth(month, year);

        if (day > maxDay) {
          // Adjust day to max allowed for this month/year
          result = maxDay.toString().padLeft(2, '0') + result.substring(2);
        }
      }
    }

    return result;
  }

  int _getMaxDayForMonth(int month, int? year) {
    switch (month) {
      case 2: // February
        if (year != null) {
          // Check for leap year
          bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
          return isLeapYear ? 29 : 28;
        }
        return 29; // Assume leap year if year not provided yet
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  TextEditingValue _formatWithMask(String digitsOnly, bool isDeleting) {
    // Limit to 8 digits
    final limitedDigits = digitsOnly.length > 8 ? digitsOnly.substring(0, 8) : digitsOnly;

    String formatted = '';
    int digitIndex = 0;

    for (int i = 0; i < mask.length; i++) {
      if (mask[i] == '/') {
        formatted += '/';
      } else {
        if (digitIndex < limitedDigits.length) {
          formatted += limitedDigits[digitIndex];
          digitIndex++;
        } else {
          // Use placeholder characters
          formatted += mask[i];
        }
      }
    }

    // Calculate cursor position
    int newCursorPos = 0;
    if (digitIndex > 0) {
      int formattedDigitCount = 0;
      for (int i = 0; i < formatted.length && formattedDigitCount < digitIndex; i++) {
        if (formatted[i] != '/') {
          formattedDigitCount++;
        }
        newCursorPos = i + 1;
      }

      // Skip over slash if cursor is on it (except when deleting)
      if (!isDeleting && newCursorPos < formatted.length && formatted[newCursorPos] == '/') {
        newCursorPos++;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}

// Enum to specify return format
enum DateReturnFormat {
  string,      // Returns "DD/MM/YYYY" string (default)
  isoString,   // Returns ISO string "YYYY-MM-DD"
  dateTime,    // Returns DateTime object
}

class CustomDateTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final String? value;
  final Function(dynamic)? onChanged; // Changed to dynamic to support different return types
  final TextEditingController controller;
  final int? minYear;
  final int? maxYear;
  final bool required;
  final String? Function(String?)? customValidator;
  final DateReturnFormat returnFormat; // New parameter to specify return format
  final DateTime? initialDate; // New parameter to set initial date

  const CustomDateTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.value,
    this.onChanged,
    this.minYear,
    this.maxYear,
    this.required = false,
    this.customValidator,
    this.returnFormat = DateReturnFormat.string, // Default to string format
    this.initialDate, // Optional initial date
  });

  @override
  State<CustomDateTextField> createState() => _CustomDateTextFieldState();
}

class _CustomDateTextFieldState extends State<CustomDateTextField> {
  String? _errorText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize with initial date if provided
    if (widget.initialDate != null) {
      _initializeWithDate(widget.initialDate!);
    } else if (widget.controller.text.isEmpty) {
      // Initialize with mask if empty and no initial date
      widget.controller.text = 'DD/MM/YYYY';
      widget.controller.selection = const TextSelection.collapsed(offset: 0);
    }

    _focusNode.addListener(_handleFocusChange);
  }

  void _initializeWithDate(DateTime date) {
    // Format date as "DD/MM/YYYY"
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    widget.controller.text = '$day/$month/$year';

    // Trigger onChanged with appropriate format if callback exists
    if (widget.onChanged != null) {
      _triggerOnChangedWithFormattedDate();
    }
  }

  void _triggerOnChangedWithFormattedDate() {
    final formattedValue = _parseDateToFormat(widget.controller.text);
    widget.onChanged!(formattedValue);
  }

  @override
  void didUpdateWidget(covariant CustomDateTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update if initialDate changes
    if (widget.initialDate != oldWidget.initialDate && widget.initialDate != null) {
      _initializeWithDate(widget.initialDate!);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // When focused, select the first placeholder position
      if (widget.controller.text == 'DD/MM/YYYY') {
        widget.controller.selection = const TextSelection.collapsed(offset: 0);
      }
    } else {
      // When focus lost, validate
      setState(() {
        _errorText = _validateDate(widget.controller.text);
      });
    }
  }

  String? _validateDate(String? value) {
    // Custom validator takes precedence
    if (widget.customValidator != null) {
      return widget.customValidator!(value);
    }

    if (widget.required && (value == null || value.isEmpty || value == 'DD/MM/YYYY')) {
      return 'This field is required';
    }

    if (value == null || value.isEmpty || value == 'DD/MM/YYYY') {
      return null;
    }

    // Check if still contains placeholder characters
    if (value.contains('D') || value.contains('M') || value.contains('Y')) {
      return 'Please complete the date';
    }

    // Check format
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Invalid format';
    }

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Validate ranges
      if (month < 1 || month > 12) {
        return 'Month must be between 01 and 12';
      }

      if (day < 1 || day > 31) {
        return 'Day must be between 01 and 31';
      }

      // Check days in month (including leap year)
      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (day > daysInMonth) {
        return 'Invalid day for ${_getMonthName(month)} $year';
      }

      // Validate year constraints
      if (widget.minYear != null && year < widget.minYear!) {
        return 'Year must be ${widget.minYear} or later';
      }

      if (widget.maxYear != null && year > widget.maxYear!) {
        return 'Year must be ${widget.maxYear} or earlier';
      }

      // Check if date is valid
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return 'Invalid date';
      }

      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Helper method to parse date string and return in requested format
  dynamic _parseDateToFormat(String dateString) {
    if (dateString.isEmpty ||
        dateString == 'DD/MM/YYYY' ||
        dateString.contains('D') ||
        dateString.contains('M') ||
        dateString.contains('Y')) {
      return null;
    }

    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      switch (widget.returnFormat) {
        case DateReturnFormat.isoString:
        // Return as ISO string "YYYY-MM-DD"
          return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

        case DateReturnFormat.dateTime:
        // Return as DateTime object
          return DateTime(year, month, day);

        case DateReturnFormat.string:
        default:
        // Return as original "DD/MM/YYYY" string
          return dateString;
      }
    } catch (e) {
      return null;
    }
  }

  void _handleChanged(String value) {
    // Clear error when user starts typing
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }

    if (widget.onChanged != null) {
      // Only callback with actual date, not the mask
      if (!value.contains('D') && !value.contains('M') && !value.contains('Y')) {
        // Parse and return in requested format
        final formattedValue = _parseDateToFormat(value);
        widget.onChanged!(formattedValue);
      } else {
        // If incomplete, pass null
        widget.onChanged!(null);
      }
    }
  }

  void _handleTap() {
    final text = widget.controller.text;
    final currentPos = widget.controller.selection.baseOffset;

    // If user taps on a slash, move cursor past it
    if (currentPos < text.length && text[currentPos] == '/') {
      widget.controller.selection = TextSelection.collapsed(offset: currentPos + 1);
    }
    // If user taps on a completed digit, find next placeholder
    else if (currentPos < text.length &&
        text[currentPos] != 'D' &&
        text[currentPos] != 'M' &&
        text[currentPos] != 'Y' &&
        text[currentPos] != '/') {
      // Find next placeholder position
      int nextPos = currentPos;
      for (int i = currentPos; i < text.length; i++) {
        if (text[i] == 'D' || text[i] == 'M' || text[i] == 'Y') {
          nextPos = i;
          break;
        }
      }
      widget.controller.selection = TextSelection.collapsed(offset: nextPos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              DateTextFormatter(),
              LengthLimitingTextInputFormatter(10),
            ],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: _errorText != null ? Colors.red : Colors.green,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorText: _errorText,
              errorStyle: const TextStyle(fontSize: 12),
            ),
            onChanged: _handleChanged,
            onTap: _handleTap,
          ),
        ),
      ],
    );
  }
}