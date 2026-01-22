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
    final selection = newValue.selection;

    // Handle selection replacement (when user selects and types)
    if (oldValue.selection.start != oldValue.selection.end) {
      // User had a selection and typed something
      return _handleSelectionReplacement(oldValue, newValue);
    }

    // If user is deleting
    if (text.length < oldText.length) {
      final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
      return _formatWithMask(digitsOnly, true, selection.baseOffset);
    }

    // Remove all non-digit characters for new input
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    // Validate and restrict input in real-time
    digitsOnly = _validateAndRestrictInput(digitsOnly);

    return _formatWithMask(digitsOnly, false, selection.baseOffset);
  }

  TextEditingValue _handleSelectionReplacement(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final selectionStart = oldValue.selection.start;
    final selectionEnd = oldValue.selection.end;
    final newText = newValue.text;
    final oldText = oldValue.text;

    // Determine which section was selected
    int sectionStart, sectionEnd;

    if (selectionStart <= 2) {
      // Day section
      sectionStart = 0;
      sectionEnd = 2;
    } else if (selectionStart <= 5) {
      // Month section
      sectionStart = 3;
      sectionEnd = 5;
    } else {
      // Year section
      sectionStart = 6;
      sectionEnd = 10;
    }

    // Extract the parts
    String beforeSection = oldText.substring(0, sectionStart);
    String afterSection = sectionEnd < oldText.length ? oldText.substring(sectionEnd) : '';

    // Get the new input (what user typed)
    String newInput = newText.replaceAll(RegExp(r'[^\d]'), '');
    String oldDigits = oldText.replaceAll(RegExp(r'[^\d]'), '');

    // Figure out what was actually typed
    String beforeDigits = beforeSection.replaceAll(RegExp(r'[^\d]'), '');
    String afterDigits = afterSection.replaceAll(RegExp(r'[^\d]'), '');

    int expectedLength = beforeDigits.length + afterDigits.length;
    String typedDigits = '';

    if (newInput.length > expectedLength) {
      typedDigits = newInput.substring(beforeDigits.length, newInput.length - afterDigits.length);
    }

    // Reconstruct the digits
    String reconstructed = beforeDigits + typedDigits + afterDigits;

    // Validate and format
    reconstructed = _validateAndRestrictInput(reconstructed);

    // Calculate cursor position based on section
    int cursorPos = sectionStart + typedDigits.length;
    if (typedDigits.length > 0 && sectionStart == 0 && typedDigits.length >= 2) {
      cursorPos = 3; // Move past day and slash
    } else if (typedDigits.length > 0 && sectionStart == 3 && typedDigits.length >= 2) {
      cursorPos = 6; // Move past month and slash
    }

    return _formatWithMask(reconstructed, false, cursorPos);
  }

  String _validateAndRestrictInput(String digits) {
    if (digits.isEmpty) return digits;

    String result = '';

    // Day validation (first 2 digits)
    if (digits.length >= 1) {
      int firstDigit = int.parse(digits[0]);
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
          return result;
        }
        if (day == 0) {
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
          return result;
        }
        if (month == 0) {
          return result;
        }
        result += digits[1];
        digits = digits.substring(2);

        int day = int.parse(result.substring(0, 2));
        int maxDay = _getMaxDayForMonth(month, result.length >= 8 ? int.parse(result.substring(4, 8)) : null);

        if (day > maxDay) {
          return result.substring(0, 2).replaceFirst(result.substring(0, 2), maxDay.toString().padLeft(2, '0')) + result.substring(2);
        }
      } else {
        return result;
      }
    }

    // Year validation (last 4 digits)
    if (digits.length >= 1) {
      result += digits.substring(0, digits.length > 4 ? 4 : digits.length);

      if (result.length == 8) {
        int day = int.parse(result.substring(0, 2));
        int month = int.parse(result.substring(2, 4));
        int year = int.parse(result.substring(4, 8));
        int maxDay = _getMaxDayForMonth(month, year);

        if (day > maxDay) {
          result = maxDay.toString().padLeft(2, '0') + result.substring(2);
        }
      }
    }

    return result;
  }

  int _getMaxDayForMonth(int month, int? year) {
    switch (month) {
      case 2:
        if (year != null) {
          bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
          return isLeapYear ? 29 : 28;
        }
        return 29;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  TextEditingValue _formatWithMask(String digitsOnly, bool isDeleting, int cursorPos) {
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
          formatted += mask[i];
        }
      }
    }

    int newCursorPos = cursorPos;
    if (newCursorPos > formatted.length) {
      newCursorPos = formatted.length;
    }

    // Skip over slashes
    if (!isDeleting && newCursorPos < formatted.length && formatted[newCursorPos] == '/') {
      newCursorPos++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}

enum DateReturnFormat {
  string,
  isoString,
  dateTime,
}

class CustomDateTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final String? value;
  final Function(dynamic)? onChanged;
  final TextEditingController controller;
  final int? minYear;
  final int? maxYear;
  final bool required;
  final String? Function(String?)? customValidator;
  final DateReturnFormat returnFormat;
  final DateTime? initialDate;

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
    this.returnFormat = DateReturnFormat.string,
    this.initialDate,
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

    if (widget.initialDate != null) {
      _initializeWithDate(widget.initialDate!);
    } else if (widget.controller.text.isEmpty) {
      widget.controller.text = 'DD/MM/YYYY';
      widget.controller.selection = const TextSelection.collapsed(offset: 0);
    }

    _focusNode.addListener(_handleFocusChange);
  }

  void _initializeWithDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    widget.controller.text = '$day/$month/$year';
  }

  @override
  void didUpdateWidget(covariant CustomDateTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

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
      if (widget.controller.text == 'DD/MM/YYYY') {
        widget.controller.selection = const TextSelection.collapsed(offset: 0);
      }
    } else {
      setState(() {
        _errorText = _validateDate(widget.controller.text);
      });
    }
  }

  String? _validateDate(String? value) {
    if (widget.customValidator != null) {
      return widget.customValidator!(value);
    }

    if (widget.required && (value == null || value.isEmpty || value == 'DD/MM/YYYY')) {
      return 'This field is required';
    }

    if (value == null || value.isEmpty || value == 'DD/MM/YYYY') {
      return null;
    }

    if (value.contains('D') || value.contains('M') || value.contains('Y')) {
      return 'Please complete the date';
    }

    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Invalid format';
    }

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (month < 1 || month > 12) {
        return 'Month must be between 01 and 12';
      }

      if (day < 1 || day > 31) {
        return 'Day must be between 01 and 31';
      }

      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (day > daysInMonth) {
        return 'Invalid day for ${_getMonthName(month)} $year';
      }

      if (widget.minYear != null && year < widget.minYear!) {
        return 'Year must be ${widget.minYear} or later';
      }

      if (widget.maxYear != null && year > widget.maxYear!) {
        return 'Year must be ${widget.maxYear} or earlier';
      }

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
          return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

        case DateReturnFormat.dateTime:
          return DateTime(year, month, day);

        case DateReturnFormat.string:
        default:
          return dateString;
      }
    } catch (e) {
      return null;
    }
  }

  void _handleChanged(String value) {
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }

    if (widget.onChanged != null) {
      if (!value.contains('D') && !value.contains('M') && !value.contains('Y')) {
        final formattedValue = _parseDateToFormat(value);
        widget.onChanged!(formattedValue);
      } else {
        widget.onChanged!(null);
      }
    }
  }

  void _handleTap() {
    final text = widget.controller.text;
    int currentPos = widget.controller.selection.baseOffset;

    // Only auto-select if the field has actual date data (not just the mask)
    if (text == 'DD/MM/YYYY' ||
        text.contains('D') ||
        text.contains('M') ||
        text.contains('Y')) {
      return; // Don't auto-select on empty/placeholder field
    }

    // Determine which section was tapped and select it
    if (currentPos <= 2) {
      // Day section
      _selectSection(0, 2);
    } else if (currentPos <= 5) {
      // Month section
      _selectSection(3, 5);
    } else {
      // Year section
      _selectSection(6, 10);
    }
  }

  void _selectSection(int start, int end) {
    final text = widget.controller.text;
    if (text.length >= end) {
      widget.controller.selection = TextSelection(
        baseOffset: start,
        extentOffset: end,
      );
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