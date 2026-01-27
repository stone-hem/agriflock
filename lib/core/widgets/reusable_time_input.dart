import 'package:flutter/material.dart';

class ReusableTimeInput extends StatefulWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool readOnly;
  final TimePickerEntryMode initialEntryMode;
  final IconData? icon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool enabled;
  final String? topLabel;
  final bool showIconOutline;
  final Color? iconColor;
  final String? suffixText;

  const ReusableTimeInput({
    super.key,
    this.initialTime,
    this.onTimeChanged,
    this.labelText,
    this.hintText = 'HH:MM',
    this.errorText,
    this.readOnly = false,
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.icon,
    this.validator,
    this.focusNode,
    this.enabled = true,
    this.topLabel,
    this.showIconOutline = false,
    this.iconColor,
    this.suffixText,
  });

  @override
  State<ReusableTimeInput> createState() => _ReusableTimeInputState();
}

class _ReusableTimeInputState extends State<ReusableTimeInput> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  TimeOfDay? _selectedTime;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();
    _textController = TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    // Initialize text if initial time is provided
    if (_selectedTime != null) {
      _textController.text = _formatTime(_selectedTime!);
    }

    // Listen to focus changes
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _textController.text.isNotEmpty) {
        _validateAndParseTime(_textController.text);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _selectTime() async {
    // Hide keyboard if open
    FocusScope.of(context).unfocus();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      initialEntryMode: widget.initialEntryMode,
    );

    if (picked != null) {
      _updateTime(picked);
    }
  }

  void _updateTime(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
      _textController.text = _formatTime(time);
      _errorText = null;
    });

    widget.onTimeChanged?.call(time);
  }

  void _validateAndParseTime(String text) {
    if (text.isEmpty) {
      setState(() => _errorText = 'Please enter a time');
      widget.onTimeChanged?.call(TimeOfDay.now()); // Default to current time
      return;
    }

    final parts = text.split(':');
    if (parts.length != 2) {
      setState(() => _errorText = 'Invalid time format (HH:MM)');
      return;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      setState(() => _errorText = 'Please enter valid numbers');
      return;
    }

    if (hour < 0 || hour > 23) {
      setState(() => _errorText = 'Hour must be 0-23');
      return;
    }

    if (minute < 0 || minute > 59) {
      setState(() => _errorText = 'Minute must be 0-59');
      return;
    }

    final newTime = TimeOfDay(hour: hour, minute: minute);
    _updateTime(newTime);
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

        // Time Input Field with InkWell
        InkWell(
          onTap: widget.enabled ? _selectTime : null,
          borderRadius: BorderRadius.circular(12),
          child: AbsorbPointer(
            absorbing: widget.readOnly,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _errorText != null ? Colors.red.shade400 : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Icon Container
                  if (widget.icon != null || widget.showIconOutline) ...[
                    Container(
                      margin: const EdgeInsets.only(left: 12, right: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: widget.showIconOutline
                          ? BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                          : null,
                      child: Icon(
                        widget.icon??Icons.access_time,
                            color: widget.iconColor ?? Colors.green.shade600,
                            size: 20,
                          ),
                    ),
                  ],

                  // Text Field
                  Expanded(
                    child: TextFormField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: widget.labelText,
                        hintText: widget.hintText,
                        errorText: _errorText ?? widget.errorText,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        suffixText: widget.suffixText,
                        suffixIcon: widget.enabled
                            ? IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: _selectTime,
                          color: Colors.grey.shade600,
                        )
                            : null,
                      ),
                      onChanged: (value) {
                        // Clear error when user types
                        if (_errorText != null) {
                          setState(() => _errorText = null);
                        }
                      },
                      onFieldSubmitted: (value) {
                        _validateAndParseTime(value);
                      },
                      validator: widget.validator,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}