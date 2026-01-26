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
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  String? _errorText;
  bool _hasLostFocus = false;
  DateTime? _lastInitializedDate;

  @override
  void initState() {
    super.initState();

    if (widget.initialDate != null) {
      _initializeWithDate(widget.initialDate!);
      _lastInitializedDate = widget.initialDate;
    } else if (widget.controller.text.isNotEmpty && widget.controller.text != 'DD/MM/YYYY') {
      _parseExistingValue(widget.controller.text);
    }

    // Add listeners to update main controller
    _dayController.addListener(_updateMainController);
    _monthController.addListener(_updateMainController);
    _yearController.addListener(_updateMainController);

    // Add focus listeners for validation
    _dayFocus.addListener(_handleFocusChange);
    _monthFocus.addListener(_handleFocusChange);
    _yearFocus.addListener(_handleFocusChange);
  }

  void _initializeWithDate(DateTime date) {
    // Temporarily remove listeners to avoid cascading updates
    _dayController.removeListener(_updateMainController);
    _monthController.removeListener(_updateMainController);
    _yearController.removeListener(_updateMainController);

    // Set the values
    _dayController.text = date.day.toString().padLeft(2, '0');
    _monthController.text = date.month.toString().padLeft(2, '0');
    _yearController.text = date.year.toString();

    // Re-add listeners
    _dayController.addListener(_updateMainController);
    _monthController.addListener(_updateMainController);
    _yearController.addListener(_updateMainController);

    // Manually update the main controller once
    _silentUpdateMainController();
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
  void didUpdateWidget(covariant CustomDateTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only reinitialize if initialDate changed and is different from what we last initialized
    if (widget.initialDate != null && widget.initialDate != _lastInitializedDate) {
      _initializeWithDate(widget.initialDate!);
      _lastInitializedDate = widget.initialDate;
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
      // All fields lost focus
      setState(() {
        _hasLostFocus = true;
        _errorText = _validateDate();
      });
    }
  }

  // Silent update - used during initialization, doesn't trigger onChanged
  void _silentUpdateMainController() {
    final day = _dayController.text.padLeft(2, '0');
    final month = _monthController.text.padLeft(2, '0');
    final year = _yearController.text;
    widget.controller.text = '$day/$month/$year';
  }

  void _updateMainController() {
    final day = _dayController.text.padLeft(2, '0');
    final month = _monthController.text.padLeft(2, '0');
    final year = _yearController.text;

    // Update the main controller
    widget.controller.text = '$day/$month/$year';

    // Clear error when user types
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }

    // Call onChanged callback
    if (widget.onChanged != null) {
      final formattedValue = _parseDateToFormat();

      // Use post frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged!(formattedValue);
        }
      });
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

  dynamic _parseDateToFormat() {
    final day = _dayController.text;
    final month = _monthController.text;
    final year = _yearController.text;

    if (day.isEmpty || month.isEmpty || year.isEmpty) {
      return null;
    }

    try {
      final dayInt = int.parse(day);
      final monthInt = int.parse(month);
      final yearInt = int.parse(year);

      switch (widget.returnFormat) {
        case DateReturnFormat.isoString:
          return '${yearInt.toString().padLeft(4, '0')}-${monthInt.toString().padLeft(2, '0')}-${dayInt.toString().padLeft(2, '0')}';

        case DateReturnFormat.dateTime:
          return DateTime(yearInt, monthInt, dayInt);

        case DateReturnFormat.string:
        default:
          return '${dayInt.toString().padLeft(2, '0')}/${monthInt.toString().padLeft(2, '0')}/$yearInt';
      }
    } catch (e) {
      return null;
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
            border: Border.all(
              color: _errorText != null ? Colors.red : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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

// Input formatter for day field
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

    // If first digit is > 3, prepend with 0
    if (text.length == 1 && value > 3) {
      return TextEditingValue(
        text: '0$text',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    // Don't allow day > 31
    if (value > 31) {
      return oldValue;
    }

    return newValue;
  }
}

// Input formatter for month field
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

    // If first digit is > 1, prepend with 0
    if (text.length == 1 && value > 1) {
      return TextEditingValue(
        text: '0$text',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    // Don't allow month > 12
    if (value > 12) {
      return oldValue;
    }

    return newValue;
  }
}