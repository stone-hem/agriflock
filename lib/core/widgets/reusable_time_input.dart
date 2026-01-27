import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReusableTimeInput extends StatefulWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final String? labelText;
  final String? errorText;
  final bool readOnly;
  final IconData? icon;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? topLabel;
  final bool showIconOutline;
  final Color? iconColor;
  final String? suffixText;
  final bool use24HourFormat; // New parameter

  const ReusableTimeInput({
    super.key,
    this.initialTime,
    this.onTimeChanged,
    this.labelText,
    this.errorText,
    this.readOnly = false,
    this.icon,
    this.validator,
    this.enabled = true,
    this.topLabel,
    this.showIconOutline = false,
    this.iconColor,
    this.suffixText,
    this.use24HourFormat = false, // Default to 12-hour format
  });

  @override
  State<ReusableTimeInput> createState() => _ReusableTimeInputState();
}

class _ReusableTimeInputState extends State<ReusableTimeInput> {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late FocusNode _hourFocusNode;
  late FocusNode _minuteFocusNode;

  TimeOfDay? _selectedTime;
  String _selectedPeriod = 'AM'; // AM or PM
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();

    _hourController = TextEditingController();
    _minuteController = TextEditingController();
    _hourFocusNode = FocusNode();
    _minuteFocusNode = FocusNode();

    // Initialize controllers with initial time
    _initializeFromTime(_selectedTime!);

    // Auto-advance from hour to minute when 2 digits entered
    _hourController.addListener(() {
      if (_hourController.text.length == 2 && _hourFocusNode.hasFocus) {
        _minuteFocusNode.requestFocus();
      }
    });

    // Validate and update time when focus is lost
    _hourFocusNode.addListener(() {
      if (!_hourFocusNode.hasFocus) {
        _validateAndUpdateTime();
      }
    });

    _minuteFocusNode.addListener(() {
      if (!_minuteFocusNode.hasFocus) {
        _validateAndUpdateTime();
      }
    });
  }

  void _initializeFromTime(TimeOfDay time) {
    if (widget.use24HourFormat) {
      _hourController.text = time.hour.toString().padLeft(2, '0');
      _minuteController.text = time.minute.toString().padLeft(2, '0');
    } else {
      final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      _hourController.text = hour12.toString().padLeft(2, '0');
      _minuteController.text = time.minute.toString().padLeft(2, '0');
      _selectedPeriod = time.period == DayPeriod.am ? 'AM' : 'PM';
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    super.dispose();
  }

  void _validateAndUpdateTime() {
    final hourText = _hourController.text;
    final minuteText = _minuteController.text;

    if (hourText.isEmpty || minuteText.isEmpty) {
      setState(() => _errorText = 'Please enter both hour and minute');
      return;
    }

    final hour = int.tryParse(hourText);
    final minute = int.tryParse(minuteText);

    if (hour == null || minute == null) {
      setState(() => _errorText = 'Please enter valid numbers');
      return;
    }

    if (widget.use24HourFormat) {
      // 24-hour format validation
      if (hour < 0 || hour > 23) {
        setState(() => _errorText = 'Hour must be 0-23');
        return;
      }
    } else {
      // 12-hour format validation
      if (hour < 1 || hour > 12) {
        setState(() => _errorText = 'Hour must be 1-12');
        return;
      }
    }

    if (minute < 0 || minute > 59) {
      setState(() => _errorText = 'Minute must be 0-59');
      return;
    }

    // Convert to 24-hour format for TimeOfDay
    int hour24;
    if (widget.use24HourFormat) {
      hour24 = hour;
    } else {
      if (_selectedPeriod == 'PM') {
        hour24 = hour == 12 ? 12 : hour + 12;
      } else {
        hour24 = hour == 12 ? 0 : hour;
      }
    }

    final newTime = TimeOfDay(hour: hour24, minute: minute);
    setState(() {
      _selectedTime = newTime;
      _errorText = null;
    });

    widget.onTimeChanged?.call(newTime);
  }

  void _togglePeriod() {
    if (!widget.enabled || widget.readOnly) return;

    setState(() {
      _selectedPeriod = _selectedPeriod == 'AM' ? 'PM' : 'AM';
    });
    _validateAndUpdateTime();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Label
        if (widget.topLabel != null) ...[
          Text(
            widget.topLabel!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Time Input Container
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _errorText != null ? Colors.red.shade400 : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Icon
                if (widget.icon != null || widget.showIconOutline) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: widget.showIconOutline
                        ? BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                        : null,
                    child: Icon(
                      widget.icon ?? Icons.access_time,
                      color: widget.iconColor ?? Colors.green.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Label
                if (widget.labelText != null) ...[
                  Text(
                    widget.labelText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                const Spacer(),

                // Hour Input
                SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _hourController,
                    focusNode: _hourFocusNode,
                    enabled: widget.enabled,
                    readOnly: widget.readOnly,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      hintText: 'HH',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                    onChanged: (value) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                ),

                // Colon separator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

                // Minute Input
                SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _minuteController,
                    focusNode: _minuteFocusNode,
                    enabled: widget.enabled,
                    readOnly: widget.readOnly,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      hintText: 'MM',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                    onChanged: (value) {
                      if (_errorText != null) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                ),

                // AM/PM Toggle (only for 12-hour format)
                if (!widget.use24HourFormat) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _togglePeriod,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedPeriod,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                ],

                // Suffix Text
                if (widget.suffixText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.suffixText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Error Text
        if (_errorText != null || widget.errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              _errorText ?? widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}