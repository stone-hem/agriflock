import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_time_input.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_order_model.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
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
    required this.onOrderSuccess,
    required this.request,
  });

  @override
  State<VetOrderBottomSheet> createState() => _VetOrderBottomSheetState();
}

class _VetOrderBottomSheetState extends State<VetOrderBottomSheet> {
  final _selectedDateController = TextEditingController();
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
                          Expanded(
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


                      CustomDateTextField(
                        label: 'Preferred Date',
                        icon: Icons.calendar_today,
                        required: true,
                        initialDate: DateTime.now(),
                        minYear: DateTime.now().year,
                        returnFormat: DateReturnFormat.isoString,
                        maxYear: DateTime.now().year + 1,
                        controller: _selectedDateController,
                      ),
                      const SizedBox(height: 20),

                      // Preferred Time
                      ReusableTimeInput(
                        topLabel: 'Preferred Time',
                        showIconOutline: true,
                        suffixText: '12 hr format',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a time';
                          }
                          return null;
                        },
                        onTimeChanged: (time) {
                          _selectedTime=time;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Additional Information Card
                      _buildAdditionalInfoCard(),
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
                              _selectedDateController.text.isEmpty ||
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

            // Service Costs
            if (widget.estimate.serviceCosts.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.estimate.serviceCosts.map((service) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${service.serviceName} (${service.serviceCode}):',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.estimate.currency} ${service.cost.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],

            // Updated to use correct fields
            _buildEstimateItem('Service Fee:', widget.estimate.serviceFee),
            _buildEstimateItem('Mileage Fee:', widget.estimate.mileageFee),

            // Mileage details if available
            if (widget.estimate.mileageDetails != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  '(${widget.estimate.mileageDetails!})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            if (widget.estimate.prioritySurcharge > 0)
              _buildEstimateItem(
                'Priority Surcharge:',
                widget.estimate.prioritySurcharge,
                isSurcharge: true,
              ),

            // Platform Commission
            _buildEstimateItem(
              'Platform Commission:',
              widget.estimate.platformCommission,
            ),

            // Officer Earnings (optional display)
            _buildEstimateItem(
              'Veterinary Officer Earnings:',
              widget.estimate.officerEarnings,
              isSecondary: true,
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

            // Distance information
            if (widget.estimate.distanceKm > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.directions_car,
                        size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Distance to travel: ${widget.estimate.distanceKm.toStringAsFixed(2)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
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
      {bool isSurcharge = false, bool isSecondary = false}) {
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
                    : isSecondary
                    ? Colors.grey.shade600
                    : Colors.grey.shade700,
                fontSize: 14,
                fontWeight: isSecondary ? FontWeight.normal : FontWeight.w600,
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
                  : isSecondary
                  ? Colors.grey.shade600
                  : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Service Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Birds count and houses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Birds',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${widget.estimate.birdsCount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Houses',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${widget.estimate.housesCount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batches',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${widget.estimate.batchesCount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Bird type if available
            if (widget.estimate.birdType != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.eco, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.6,
                      child: Text(
                        'Bird Type: ${widget.estimate.birdType!}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Service codes if available
            if (widget.estimate.serviceCosts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.estimate.serviceCosts.map((service) =>
                    Chip(
                      label: Text(service.serviceCode),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Future<void> _submitOrder() async {
    if (_selectedDateController.text.isEmpty) {
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
      houseIds: widget.request.houseIds,
      batchIds: widget.request.batchIds,
      serviceIds: widget.request.serviceIds,
      birdsCount: widget.request.birdsCount,
      priorityLevel: widget.request.priorityLevel,
      preferredDate: _selectedDateController.text,
      reasonForVisit: widget.request.reasonForVisit,
      termsAgreed: _termsAgreed, preferredTime: _selectedTime!.format(context),
      participantsCount: widget.request.participantsCount,
    );

    final result = await widget.vetRepository.submitVetOrder(request);

    setState(() {
      _isSubmittingOrder = false;
    });

    switch (result) {
      case Success<VetOrderResponse>(data: final data):
      // Close bottom sheet
        Navigator.of(context).pop();
        context.pushReplacement('/my-vet-orders');
        break;
      case Failure(message: final error):
        ToastUtil.showError('Failed to submit order: $error');
        break;
    }
  }

  @override
  void dispose() {
    _selectedDateController.dispose();
    super.dispose();
  }
}