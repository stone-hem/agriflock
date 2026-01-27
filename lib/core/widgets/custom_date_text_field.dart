import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DateReturnFormat {
  string,
  isoString,
  dateTime,
}

class CustomDateTextField extends StatefulWidget {
  final String label;
  final IconData icon;
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
    required this.icon,
    required this.controller,
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
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  String? _errorText;

  @override
  void initState() {
    super.initState();

    // Initialize from initialDate or existing controller value
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialDate != null) {
        _setDateSilently(widget.initialDate!);
      } else if (widget.controller.text.isNotEmpty &&
          widget.controller.text != 'DD/MM/YYYY') {
        _parseExistingValue(widget.controller.text);
      }
    });

    // Add listeners
    _dayController.addListener(_updateMainController);
    _monthController.addListener(_updateMainController);
    _yearController.addListener(_updateMainController);

    _dayFocus.addListener(_handleFocusChange);
    _monthFocus.addListener(_handleFocusChange);
    _yearFocus.addListener(_handleFocusChange);
  }

  void _setDateSilently(DateTime date) {
    // Remove listeners temporarily
    _dayController.removeListener(_updateMainController);
    _monthController.removeListener(_updateMainController);
    _yearController.removeListener(_updateMainController);

    // Set values
    _dayController.text = date.day.toString().padLeft(2, '0');
    _monthController.text = date.month.toString().padLeft(2, '0');
    _yearController.text = date.year.toString();

    // Update main controller based on return format
    widget.controller.text = _formatDateForController(date);

    // Re-add listeners
    _dayController.addListener(_updateMainController);
    _monthController.addListener(_updateMainController);
    _yearController.addListener(_updateMainController);
  }

  String _formatDateForController(DateTime date) {
    switch (widget.returnFormat) {
      case DateReturnFormat.isoString:
        return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case DateReturnFormat.dateTime:
      // For DateTime format, store as ISO string in controller
        return date.toIso8601String();
      case DateReturnFormat.string:
      default:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  void _parseExistingValue(String value) {
    final parts = value.split('/');
    if (parts.length == 3) {
      _dayController.text = parts[0];
      _monthController.text = parts[1];
      _yearController.text = parts[2];
    }
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_dayFocus.hasFocus && !_monthFocus.hasFocus && !_yearFocus.hasFocus) {
      setState(() {
        _errorText = _validateDate();
      });
    }
  }

  void _updateMainController() {
    final day = _dayController.text;
    final month = _monthController.text;
    final year = _yearController.text;

    // Clear error when user types
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }

    // Only update if we have all parts
    if (day.isNotEmpty && month.isNotEmpty && year.isNotEmpty) {
      try {
        final date = DateTime(
          int.parse(year),
          int.parse(month),
          int.parse(day),
        );
        widget.controller.text = _formatDateForController(date);
      } catch (e) {
        // Invalid date, just store the raw format
        widget.controller.text = '${day.padLeft(2, '0')}/${month.padLeft(2, '0')}/$year';
      }
    } else {
      // Partial date
      widget.controller.text = '${day.padLeft(2, '0')}/${month.padLeft(2, '0')}/$year';
    }
  }

  String? _validateDate() {
    if (widget.customValidator != null) {
      return widget.customValidator!(widget.controller.text);
    }

    final day = _dayController.text;
    final month = _monthController.text;
    final year = _yearController.text;

    if (widget.required && (day.isEmpty || month.isEmpty || year.isEmpty)) {
      return 'This field is required';
    }

    if (day.isEmpty && month.isEmpty && year.isEmpty) {
      return null;
    }

    if (day.isEmpty || month.isEmpty || year.isEmpty) {
      return 'Please complete the date';
    }

    try {
      final dayInt = int.parse(day);
      final monthInt = int.parse(month);
      final yearInt = int.parse(year);

      if (monthInt < 1 || monthInt > 12) {
        return 'Month must be between 01 and 12';
      }

      if (dayInt < 1 || dayInt > 31) {
        return 'Day must be between 01 and 31';
      }

      final daysInMonth = DateTime(yearInt, monthInt + 1, 0).day;
      if (dayInt > daysInMonth) {
        return 'Invalid day for ${_getMonthName(monthInt)} $yearInt';
      }

      if (widget.minYear != null && yearInt < widget.minYear!) {
        return 'Year must be ${widget.minYear} or later';
      }

      if (widget.maxYear != null && yearInt > widget.maxYear!) {
        return 'Year must be ${widget.maxYear} or earlier';
      }

      final date = DateTime(yearInt, monthInt, dayInt);
      if (date.year != yearInt || date.month != monthInt || date.day != dayInt) {
        return 'Invalid date';
      }

      return null;
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _errorText != null ? Colors.red : Colors.grey[300]!,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: _errorText != null ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _dayController,
                  focusNode: _dayFocus,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                    _DayInputFormatter(),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'DD',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value.length == 2) {
                      _monthFocus.requestFocus();
                    }
                  },
                ),
              ),
              const Text(
                '/',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _monthController,
                  focusNode: _monthFocus,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                    _MonthInputFormatter(),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'MM',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value.length == 2) {
                      _yearFocus.requestFocus();
                    }
                  },
                ),
              ),
              const Text(
                '/',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _yearController,
                  focusNode: _yearFocus,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'YYYY',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _DayInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    final value = int.tryParse(text);
    if (value == null) return oldValue;

    if (text.length == 1 && value > 3) {
      return TextEditingValue(
        text: '0$text',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    if (value > 31) {
      return oldValue;
    }

    return newValue;
  }
}

class _MonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    final value = int.tryParse(text);
    if (value == null) return oldValue;

    if (text.length == 1 && value > 1) {
      return TextEditingValue(
        text: '0$text',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    if (value > 12) {
      return oldValue;
    }

    return newValue;
  }
}