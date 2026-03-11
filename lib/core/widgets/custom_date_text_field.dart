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
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _dayController = TextEditingController();
    _monthController = TextEditingController();
    _yearController = TextEditingController();

    _dayFocus = FocusNode();
    _monthFocus = FocusNode();
    _yearFocus = FocusNode();

    _initializeDate();

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
    widget.controller.text = _formatDateForController(date);
  }

  String _formatDateForController(DateTime date) {
    switch (widget.returnFormat) {
      case DateReturnFormat.isoString:
        return '${date.year.toString().padLeft(4, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.day.toString().padLeft(2, '0')}';
      case DateReturnFormat.dateTime:
        return date.toIso8601String();
      case DateReturnFormat.string:
        return '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
    }
  }

  void _parseExistingValue(String value) {
    if (value.contains('-')) {
      final parts = value.split('T')[0].split('-');
      if (parts.length == 3) {
        _yearController.text = parts[0];
        _monthController.text = parts[1];
        _dayController.text = parts[2];
        return;
      }
    }
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
    final focused =
        _dayFocus.hasFocus || _monthFocus.hasFocus || _yearFocus.hasFocus;
    setState(() => _isFocused = focused);

    if (!focused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _errorText = _validateDate());
      });
    } else {
      if (_errorText != null) setState(() => _errorText = null);
    }
  }

  void _updateMainController() {
    if (!_isInitialized) return;

    final day = _dayController.text;
    final month = _monthController.text;
    final year = _yearController.text;

    if (_errorText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _errorText = null);
      });
    }

    if (day.isNotEmpty && month.isNotEmpty && year.isNotEmpty) {
      try {
        final date = DateTime(
          int.parse(year),
          int.parse(month),
          int.parse(day),
        );
        widget.controller.text = _formatDateForController(date);
      } catch (_) {
        widget.controller.text =
            '${day.padLeft(2, '0')}/${month.padLeft(2, '0')}/$year';
      }
    } else {
      widget.controller.text =
          '${day.padLeft(2, '0')}/${month.padLeft(2, '0')}/$year';
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

    if (day.isEmpty && month.isEmpty && year.isEmpty) return null;

    if (day.isEmpty || month.isEmpty || year.isEmpty) {
      return 'Please complete the date';
    }

    try {
      final dayInt = int.parse(day);
      final monthInt = int.parse(month);
      final yearInt = int.parse(year);

      if (monthInt < 1 || monthInt > 12) return 'Month must be 01–12';
      if (dayInt < 1 || dayInt > 31) return 'Day must be 01–31';

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
      if (date.year != yearInt ||
          date.month != monthInt ||
          date.day != dayInt) {
        return 'Invalid date';
      }

      return null;
    } catch (_) {
      return 'Invalid date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    final borderColor = hasError
        ? Colors.red.shade400
        : _isFocused
            ? Colors.green.shade600
            : Colors.grey.shade300;
    final borderWidth = (_isFocused || hasError) ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // Label row — matches ReusableInput pattern
        Row(
          children: [
            Icon(widget.icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Single outer container — no nested borders
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSegment(
                  controller: _dayController,
                  focusNode: _dayFocus,
                  hintText: 'DD',
                  formatter: _DayInputFormatter(),
                  onChanged: (v) {
                    if (v.length == 2) _monthFocus.requestFocus();
                  },
                ),
              ),
              _buildSeparator('/'),
              Expanded(
                flex: 2,
                child: _buildSegment(
                  controller: _monthController,
                  focusNode: _monthFocus,
                  hintText: 'MM',
                  formatter: _MonthInputFormatter(),
                  onChanged: (v) {
                    if (v.length == 2) _yearFocus.requestFocus();
                  },
                ),
              ),
              _buildSeparator('/'),
              Expanded(
                flex: 3,
                child: _buildSegment(
                  controller: _yearController,
                  focusNode: _yearFocus,
                  hintText: 'YYYY',
                  maxLength: 4,
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _errorText!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSeparator(String char) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        char,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildSegment({
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
        ?formatter,
      ],
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
          fontSize: 15,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        isDense: true,
        counterText: '',
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
    if (value > 31) return oldValue;
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
    if (value > 12) return oldValue;
    return newValue;
  }
}
