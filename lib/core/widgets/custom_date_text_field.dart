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
  late TextEditingController _dayController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;

  late FocusNode _dayFocus;
  late FocusNode _monthFocus;
  late FocusNode _yearFocus;

  String? _errorText;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _dayController = TextEditingController();
    _monthController = TextEditingController();
    _yearController = TextEditingController();

    // Initialize focus nodes
    _dayFocus = FocusNode();
    _monthFocus = FocusNode();
    _yearFocus = FocusNode();

    // Initialize from initialDate or existing controller value
    _initializeDate();

    // Add listeners after initialization
    _dayController.addListener(_updateMainController);
    _monthController.addListener(_updateMainController);
    _yearController.addListener(_updateMainController);

    _dayFocus.addListener(_handleFocusChange);
    _monthFocus.addListener(_handleFocusChange);
    _yearFocus.addListener(_handleFocusChange);
  }

  void _initializeDate() {
    if (widget.initialDate != null) {
      _setDateSilently(widget.initialDate!);
    } else if (widget.controller.text.isNotEmpty &&
        widget.controller.text != 'DD/MM/YYYY') {
      _parseExistingValue(widget.controller.text);
    }
    _isInitialized = true;
  }

  void _setDateSilently(DateTime date) {
    _dayController.text = date.day.toString().padLeft(2, '0');
    _monthController.text = date.month.toString().padLeft(2, '0');
    _yearController.text = date.year.toString();

    // Update main controller based on return format
    widget.controller.text = _formatDateForController(date);
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
    // Try to parse ISO format first (YYYY-MM-DD)
    if (value.contains('-')) {
      final parts = value.split('T')[0].split('-'); // Handle ISO with time
      if (parts.length == 3) {
        _yearController.text = parts[0];
        _monthController.text = parts[1];
        _dayController.text = parts[2];
        return;
      }
    }

    // Try DD/MM/YYYY format
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
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _errorText = _validateDate();
          });
        }
      });
    }
  }

  void _updateMainController() {
    if (!_isInitialized) return;

    final day = _dayController.text;
    final month = _monthController.text;
    final year = _yearController.text;

    // Clear error when user types (using post-frame callback)
    if (_errorText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _errorText = null;
          });
        }
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: _errorText != null ? Colors.red : Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildDateField(
                  controller: _dayController,
                  focusNode: _dayFocus,
                  hintText: 'DD',
                  formatter: _DayInputFormatter(),
                  onChanged: (value) {
                    if (value.length == 2) {
                      _monthFocus.requestFocus();
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '/',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildDateField(
                  controller: _monthController,
                  focusNode: _monthFocus,
                  hintText: 'MM',
                  formatter: _MonthInputFormatter(),
                  onChanged: (value) {
                    if (value.length == 2) {
                      _yearFocus.requestFocus();
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '/',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: _buildDateField(
                  controller: _yearController,
                  focusNode: _yearFocus,
                  hintText: 'YYYY',
                  maxLength: 4,
                  formatter: null,
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

  Widget _buildDateField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    int maxLength = 2,
    TextInputFormatter? formatter,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
        if (formatter != null) formatter,
      ],
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        isDense: true,
      ),
      onChanged: onChanged,
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