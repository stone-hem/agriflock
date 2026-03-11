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
  final bool use24HourFormat;

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
    this.use24HourFormat = false,
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
  String _selectedPeriod = 'AM';
  String? _errorText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();

    _hourController = TextEditingController();
    _minuteController = TextEditingController();
    _hourFocusNode = FocusNode();
    _minuteFocusNode = FocusNode();

    _initializeFromTime(_selectedTime!);

    _hourController.addListener(() {
      if (_hourController.text.length == 2 && _hourFocusNode.hasFocus) {
        _minuteFocusNode.requestFocus();
      }
    });

    _hourFocusNode.addListener(_handleFocusChange);
    _minuteFocusNode.addListener(_handleFocusChange);
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

  void _handleFocusChange() {
    final focused = _hourFocusNode.hasFocus || _minuteFocusNode.hasFocus;
    setState(() => _isFocused = focused);

    if (!focused) _validateAndUpdateTime();
    if (focused && _errorText != null) setState(() => _errorText = null);
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
      if (hour < 0 || hour > 23) {
        setState(() => _errorText = 'Hour must be 0–23');
        return;
      }
    } else {
      if (hour < 1 || hour > 12) {
        setState(() => _errorText = 'Hour must be 1–12');
        return;
      }
    }

    if (minute < 0 || minute > 59) {
      setState(() => _errorText = 'Minute must be 0–59');
      return;
    }

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
    final hasError = _errorText != null || widget.errorText != null;
    final borderColor = hasError
        ? Colors.red.shade400
        : _isFocused
            ? Colors.green.shade600
            : Colors.grey.shade300;
    final borderWidth = (_isFocused || hasError) ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Label row — matches ReusableInput pattern
        if (widget.topLabel != null || widget.icon != null) ...[
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
              ],
              if (widget.topLabel != null)
                Text(
                  widget.topLabel!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        // Single outer container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Optional inline label
              if (widget.labelText != null) ...[
                Text(
                  widget.labelText!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 12),
              ],

              // Hour field
              SizedBox(
                width: 44,
                child: TextField(
                  controller: _hourController,
                  focusNode: _hourFocusNode,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'HH',
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
                  ),
                  onChanged: (value) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                ),
              ),

              // Colon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),

              // Minute field
              SizedBox(
                width: 44,
                child: TextField(
                  controller: _minuteController,
                  focusNode: _minuteFocusNode,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'MM',
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
                  ),
                  onChanged: (value) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                ),
              ),

              // AM/PM toggle
              if (!widget.use24HourFormat) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _togglePeriod,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      _selectedPeriod,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
              ],

              // Suffix text
              if (widget.suffixText != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.suffixText!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),

        // Error text
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _errorText ?? widget.errorText!,
              style: TextStyle(fontSize: 12, color: Colors.red.shade600),
            ),
          ),
        ],
      ],
    );
  }
}
