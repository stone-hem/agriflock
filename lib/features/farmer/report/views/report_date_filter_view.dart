import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:flutter/material.dart';

class ReportDateFilterView extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String period;
  final Function({
    required DateTime startDate,
    required DateTime endDate,
    required String period,
  }) onApply;
  final VoidCallback onBack;

  const ReportDateFilterView({
    super.key,
    this.startDate,
    this.endDate,
    required this.period,
    required this.onApply,
    required this.onBack,
  });

  @override
  State<ReportDateFilterView> createState() => _ReportDateFilterViewState();
}

class _ReportDateFilterViewState extends State<ReportDateFilterView> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late String _selectedPeriod;

  final List<Map<String, String>> _periods = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController(
      text: widget.startDate?.toIso8601String().split('T').first ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.endDate?.toIso8601String().split('T').first ?? '',
    );
    _selectedPeriod = widget.period;
  }

  void _handleApply() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    try {
      final startDate = DateTime.parse(_startDateController.text);
      final endDate = DateTime.parse(_endDateController.text);

      if (startDate.isAfter(endDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Start date cannot be after end date')),
        );
        return;
      }

      widget.onApply(
        startDate: startDate,
        endDate: endDate,
        period: _selectedPeriod,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid date format')),
      );
    }
  }

  void _setQuickRange(String range) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (range) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        _selectedPeriod = 'daily';
        break;
      case 'week':
        start = now.subtract(Duration(days: now.weekday - 1));
        _selectedPeriod = 'weekly';
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        _selectedPeriod = 'monthly';
        break;
      case 'year':
        start = DateTime(now.year, 1, 1);
        _selectedPeriod = 'yearly';
        break;
      default:
        start = now.subtract(const Duration(days: 7));
    }

    setState(() {
      _startDateController.text = start.toIso8601String().split('T').first;
      _endDateController.text = end.toIso8601String().split('T').first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the date range for the report',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Quick select buttons
          Text(
            'Quick Select',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickButton('Today', 'today'),
              const SizedBox(width: 8),
              _buildQuickButton('This Week', 'week'),
              const SizedBox(width: 8),
              _buildQuickButton('This Month', 'month'),
              const SizedBox(width: 8),
              _buildQuickButton('This Year', 'year'),
            ],
          ),
          const SizedBox(height: 24),

          // Custom date range
          Text(
            'Custom Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          CustomDateTextField(
            label: 'Start Date',
            icon: Icons.calendar_today,
            required: true,
            initialDate: widget.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
            minYear: DateTime.now().year - 2,
            maxYear: DateTime.now().year,
            returnFormat: DateReturnFormat.isoString,
            controller: _startDateController,
          ),
          const SizedBox(height: 16),
          CustomDateTextField(
            label: 'End Date',
            icon: Icons.calendar_today,
            required: true,
            initialDate: widget.endDate ?? DateTime.now(),
            minYear: DateTime.now().year - 2,
            maxYear: DateTime.now().year,
            returnFormat: DateReturnFormat.isoString,
            controller: _endDateController,
          ),
          const SizedBox(height: 24),

          // Period selection
          Text(
            'Report Period',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _periods.map((period) {
              final isSelected = _selectedPeriod == period['value'];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedPeriod = period['value']!);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    period['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment),
                  SizedBox(width: 8),
                  Text(
                    'Generate Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, String range) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _setQuickRange(range),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
