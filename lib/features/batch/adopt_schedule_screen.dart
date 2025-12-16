import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdoptScheduleScreen extends StatefulWidget {
  final bool isSingleItem;
  final String? vaccineName;

  const AdoptScheduleScreen({
    super.key,
    this.isSingleItem = false,
    this.vaccineName,
  });

  @override
  State<AdoptScheduleScreen> createState() => _AdoptScheduleScreenState();
}

class _AdoptScheduleScreenState extends State<AdoptScheduleScreen> {
  final Map<String, bool> _selectedItems = {};
  DateTime? _startDate;
  bool _enableReminders = true;
  bool _adjustForAge = true;

  final List<Map<String, String>> _scheduleItems = [
    {
      'name': 'Marek\'s Disease',
      'timing': 'Day 1 (at hatchery)',
      'method': 'Subcutaneous injection',
    },
    {
      'name': 'Newcastle Disease (ND)',
      'timing': 'Day 7-10',
      'method': 'Eye/nose drop',
    },
    {
      'name': 'Infectious Bursal Disease (Gumboro)',
      'timing': 'Day 10-14',
      'method': 'Drinking water',
    },
    {
      'name': 'Newcastle Disease (Booster)',
      'timing': 'Day 21-28',
      'method': 'Drinking water',
    },
    {
      'name': 'Infectious Bronchitis (IB)',
      'timing': 'Day 14-21',
      'method': 'Eye drop',
    },
    {
      'name': 'Fowl Pox',
      'timing': 'Week 6-8',
      'method': 'Wing-web stab',
    },
    {
      'name': 'Gumboro (Booster)',
      'timing': 'Day 21-28',
      'method': 'Drinking water',
    },
    {
      'name': 'Avian Influenza',
      'timing': 'Week 8-12',
      'method': 'Subcutaneous',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isSingleItem && widget.vaccineName != null) {
      // Pre-select the single item
      _selectedItems[widget.vaccineName!] = true;
    } else {
      // Pre-select all items for "Adopt All"
      for (var item in _scheduleItems) {
        _selectedItems[item['name']!] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedItems.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.isSingleItem ? 'Adopt Schedule' : 'Adopt All Schedules'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: selectedCount > 0 ? _adoptSchedule : null,
            child: Text(
              'Adopt ($selectedCount)',
              style: TextStyle(
                color: selectedCount > 0 ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.purple.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.purple.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Batch: 123',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.isSingleItem
                                ? 'Adopt recommended schedule item'
                                : 'Adopt complete vaccination schedule',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Start Date Selection
            Text(
              'Schedule Start Date',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectStartDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _startDate == null
                                ? 'Select start date'
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                            style: TextStyle(
                              color: _startDate == null
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade800,
                            ),
                          ),
                          if (_startDate == null)
                            Text(
                              'Reference date for calculating schedule',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Adjust for current flock age'),
                    subtitle: Text(
                      'Skip vaccinations that should have already been done',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    value: _adjustForAge,
                    onChanged: (value) {
                      setState(() {
                        _adjustForAge = value;
                      });
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  SwitchListTile(
                    title: const Text('Enable reminders'),
                    subtitle: Text(
                      'Get notifications 24 hours before each vaccination',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    value: _enableReminders,
                    onChanged: (value) {
                      setState(() {
                        _enableReminders = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Schedule Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vaccination Items',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (!widget.isSingleItem)
                  Row(
                    children: [
                      TextButton(
                        onPressed: _selectAll,
                        child: const Text('Select All'),
                      ),
                      TextButton(
                        onPressed: _deselectAll,
                        child: const Text('Deselect All'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (widget.isSingleItem && widget.vaccineName != null)
              _buildSingleScheduleItem()
            else
              ..._scheduleItems.map((item) => _buildScheduleItem(item)),

            const SizedBox(height: 24),

            // Summary Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.green.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Selected items', '$selectedCount'),
                    _buildSummaryRow(
                      'Start date',
                      _startDate == null
                          ? 'Not selected'
                          : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                    ),
                    _buildSummaryRow('Reminders', _enableReminders ? 'Enabled' : 'Disabled'),
                    _buildSummaryRow('Age adjustment', _adjustForAge ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleScheduleItem() {
    final item = _scheduleItems.firstWhere(
          (i) => i['name'] == widget.vaccineName,
      orElse: () => _scheduleItems[0],
    );
    return _buildScheduleItem(item, isSingle: true);
  }

  Widget _buildScheduleItem(Map<String, String> item, {bool isSingle = false}) {
    final isSelected = _selectedItems[item['name']] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isSingle ? null : () {
          setState(() {
            _selectedItems[item['name']!] = !isSelected;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (!isSingle)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.purple : Colors.grey.shade400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              if (!isSingle) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['timing']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['method']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _selectAll() {
    setState(() {
      for (var item in _scheduleItems) {
        _selectedItems[item['name']!] = true;
      }
    });
  }

  void _deselectAll() {
    setState(() {
      for (var item in _scheduleItems) {
        _selectedItems[item['name']!] = false;
      }
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _adoptSchedule() {
    final selectedCount = _selectedItems.values.where((v) => v).length;

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Adoption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to adopt $selectedCount vaccination schedule(s).'),
            const SizedBox(height: 12),
            Text(
              'This will create scheduled vaccinations starting from ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            if (_adjustForAge) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Past-due vaccinations will be skipped',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmAdoption(selectedCount);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Adopt'),
          ),
        ],
      ),
    );
  }

  void _confirmAdoption(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Successfully adopted $count vaccination schedule(s)'),
            const Text('All schedules are now active'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    context.pop();
  }
}