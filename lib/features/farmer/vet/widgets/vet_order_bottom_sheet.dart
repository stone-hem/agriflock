import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_order_model.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:agriflock360/features/farmer/vet/vet_order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:go_router/go_router.dart';

class VetOrderBottomSheet extends StatefulWidget {
  final VetEstimateResponse estimate;
  final VetFarmer vet;
  final VetEstimateRequest request;

  final VetFarmerRepository vetRepository;
  final VoidCallback onOrderSuccess;

  const VetOrderBottomSheet({
    super.key,
    required this.estimate,
    required this.vet,
    required this.vetRepository,
    required this.onOrderSuccess, required this.request,
  });

  @override
  State<VetOrderBottomSheet> createState() => _VetOrderBottomSheetState();
}

class _VetOrderBottomSheetState extends State<VetOrderBottomSheet> {
  final _selectedDateController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _termsAgreed = false;
  bool _isSubmittingOrder = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimate Generated',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Complete your booking details',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Estimate Card
                      _buildEstimateCard(),
                      const SizedBox(height: 24),

                      // Preferred Date
                      Text(
                        'Preferred Date',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomDateTextField(
                        label: 'Preferred Date',
                        hintText: 'Select your preferred date',
                        icon: Icons.calendar_today,
                        required: true,
                        minYear: DateTime.now().year,
                        returnFormat: DateReturnFormat.dateTime,
                        maxYear: DateTime.now().year + 1,
                        controller: _selectedDateController,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDate = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Preferred Time
                      Text(
                        'Preferred Time',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectTime,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: Colors.grey.shade600),
                              const SizedBox(width: 12),
                              Text(
                                _selectedTime == null
                                    ? 'Select preferred time'
                                    : _selectedTime!.format(context),
                                style: TextStyle(
                                  color: _selectedTime == null
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Terms and Conditions
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _termsAgreed,
                                    onChanged: (value) {
                                      setState(() {
                                        _termsAgreed = value ?? false;
                                      });
                                    },
                                    activeColor: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'I agree to the terms and conditions',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'By submitting this order, you agree to:\n'
                                    '• Payment terms and conditions\n'
                                    '• Service terms and conditions\n'
                                    '• Privacy and data protection agreement\n'
                                    '• Cancellation policy\n'
                                    '• All applicable laws and regulations',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmittingOrder ||
                              !_termsAgreed ||
                              _selectedDate == null ||
                              _selectedTime == null
                              ? null
                              : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmittingOrder
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : const Text(
                            'Submit Booking Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEstimateCard() {
    return Card(
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
                Icon(Icons.receipt, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Cost Breakdown',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEstimateItem(
                'Consultation Fee:', widget.estimate.consultationFee),
            _buildEstimateItem('Service Fee:', widget.estimate.serviceFee),
            _buildEstimateItem('Mileage Fee:', widget.estimate.mileageFee),
            if (widget.estimate.prioritySurcharge > 0)
              _buildEstimateItem(
                'Priority Surcharge:',
                widget.estimate.prioritySurcharge,
                isSurcharge: true,
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Estimated Cost:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.estimate.currency} ${widget.estimate.totalEstimatedCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (widget.estimate.notes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.estimate.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstimateItem(String label, double amount,
      {bool isSurcharge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isSurcharge
                    ? Colors.orange.shade700
                    : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.estimate.currency} ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSurcharge
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a preferred date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a preferred time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingOrder = true;
    });

    final request = VetOrderRequest(
      vetId: widget.vet.id,
      houseId: widget.request.houseId,
      batchIds: widget.request.batchIds,
      serviceIds: widget.request.serviceIds,
      birdsCount: widget.request.birdsCount,
      priorityLevel: widget.request.priorityLevel,
      preferredDate: _selectedDate!.toIso8601String().split('T').first,
      preferredTime: _selectedTime!.format(context),
      reasonForVisit: widget.request.reasonForVisit,
      termsAgreed: _termsAgreed,
    );

    final result = await widget.vetRepository.submitVetOrder(request);

    setState(() {
      _isSubmittingOrder = false;
    });

    switch (result) {
      case Success<VetOrderResponse>(data: final data):
      // Close bottom sheet
        Navigator.of(context).pop();

        // Show success screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VetOrderSuccessScreen(
              order: data,
              onClose: () {
                context.pushReplacement('/my-vet-orders');
              },
            ),
            fullscreenDialog: true,
          ),
        );
        break;
      case Failure(message: final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit order: $error'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _selectedDateController.dispose();
    super.dispose();
  }
}