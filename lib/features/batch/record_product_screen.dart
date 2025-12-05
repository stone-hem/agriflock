import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecordProductScreen extends StatefulWidget {
  final String batchId;
  final Map<String, dynamic>? batch; // Optional: pass batch for name display

  const RecordProductScreen({
    super.key,
    required this.batchId,
    this.batch,
  });

  @override
  State<RecordProductScreen> createState() => _RecordProductScreenState();
}

class _RecordProductScreenState extends State<RecordProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProductType = 'Eggs';
  final List<String> _productTypes = ['Eggs', 'Meat (Birds Sold)', 'Other'];

  final _quantityController = TextEditingController();
  final _crackedEggsController = TextEditingController(); // only for eggs
  final _weightController = TextEditingController(); // for meat or other
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to database / provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_selectedProductType recorded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(); // Go back to batch details
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchName = widget.batch?['name'] ?? 'Batch #${widget.batchId}';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Record Product'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveRecord,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Batch Info Header
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.egg, color: Colors.green, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batchName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Recording collection for this batch',
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
              const SizedBox(height: 32),

              // Product Type
              Text(
                'Product Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProductType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _productTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedProductType = value);
                },
              ),
              const SizedBox(height: 24),

              // Conditional Fields
              if (_selectedProductType == 'Eggs') ...[
                // Quantity (Eggs)
                _buildTextField(
                  controller: _quantityController,
                  label: 'Number of Eggs Collected',
                  hint: 'e.g., 245',
                  keyboardType: TextInputType.number,
                  icon: Icons.format_list_numbered,
                ),
                const SizedBox(height: 20),
                // Cracked / Broken Eggs
                _buildTextField(
                  controller: _crackedEggsController,
                  label: 'Cracked or Broken Eggs (Optional)',
                  hint: 'e.g., 5',
                  keyboardType: TextInputType.number,
                  icon: Icons.broken_image,
                ),
              ],

              if (_selectedProductType == 'Meat (Birds Sold)') ...[
                _buildTextField(
                  controller: _quantityController,
                  label: 'Number of Birds Sold',
                  hint: 'e.g., 12',
                  keyboardType: TextInputType.number,
                  icon: Icons.kebab_dining,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _weightController,
                  label: 'Total Weight (kg) - Optional',
                  hint: 'e.g., 28.5',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  icon: Icons.monitor_weight,
                ),
              ],

              if (_selectedProductType == 'Other')
                _buildTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  hint: 'e.g., 50 trays, 10 crates...',
                  icon: Icons.inventory,
                ),

              const SizedBox(height: 24),

              // Date & Time
              Text(
                'Date & Time',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: _dateTimeTile(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value:
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: _dateTimeTile(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: _selectedTime.format(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'e.g., Grade A eggs, sold to local market...',
                maxLines: 3,
                icon: Icons.note_add,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if ((value == null || value.isEmpty) &&
                (label.contains('Number') || label.contains('Quantity'))) {
              return 'Please enter a value';
            }
            if (keyboardType == TextInputType.number ||
                keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
              if (value != null && double.tryParse(value) == null && value.isNotEmpty) {
                return 'Enter a valid number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _dateTimeTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _crackedEggsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}