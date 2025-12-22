import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetServicePaymentScreen extends StatefulWidget {
  final Map<String, dynamic> serviceDetails;

  const VetServicePaymentScreen({super.key, required this.serviceDetails});

  @override
  State<VetServicePaymentScreen> createState() => _VetServicePaymentScreenState();
}

class _VetServicePaymentScreenState extends State<VetServicePaymentScreen> {
  final TextEditingController _mpesaPhoneController = TextEditingController();
  final TextEditingController _receiptNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedPaymentMethod = 'mpesa';
  String _paymentStatus = 'pending'; // pending, paid, verified
  bool _isProcessingPayment = false;
  bool _isVerifyingPayment = false;

  List<Map<String, dynamic>> get _feeBreakdown => widget.serviceDetails['feeBreakdown'] ?? [];
  double get _totalAmount => widget.serviceDetails['totalAmount'] ?? 0.0;
  double get _paidAmount => widget.serviceDetails['paidAmount'] ?? 0.0;
  double get _pendingAmount => _totalAmount - _paidAmount;

  @override
  void initState() {
    super.initState();
    // Check if payment has already been made
    if (_paidAmount > 0) {
      _paymentStatus = 'paid';
    }
    if (widget.serviceDetails['paymentVerified'] == true) {
      _paymentStatus = 'verified';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            const Text('Service Payment'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Info Card
            _buildServiceInfoCard(),
            const SizedBox(height: 24),

            // Payment Status Banner
            _buildPaymentStatusBanner(),
            const SizedBox(height: 24),

            // Fee Breakdown
            _buildFeeBreakdown(),
            const SizedBox(height: 24),

            // Payment Method Selection
            if (_paymentStatus == 'pending') _buildPaymentMethodSection(),
            const SizedBox(height: 24),

            // M-Pesa Payment Form
            if (_selectedPaymentMethod == 'mpesa' && _paymentStatus == 'pending')
              _buildMpesaPaymentForm(),

            // Bank Payment Verification
            if (_selectedPaymentMethod == 'bank' && _paymentStatus == 'pending')
              _buildBankVerificationForm(),

            // Already Paid Section
            if (_paymentStatus == 'paid') _buildAlreadyPaidSection(),

            // Payment Verified Section
            if (_paymentStatus == 'verified') _buildPaymentVerifiedSection(),

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Payment Due',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.person,
              label: 'Farmer',
              value: widget.serviceDetails['farmerName'] ?? 'N/A',
            ),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Farm',
              value: widget.serviceDetails['farmName'] ?? 'N/A',
            ),
            _DetailRow(
              icon: Icons.medical_services,
              label: 'Service',
              value: widget.serviceDetails['serviceType'] ?? 'N/A',
            ),
            _DetailRow(
              icon: Icons.pets,
              label: 'Animals',
              value: widget.serviceDetails['animals'] ?? 'N/A',
            ),
            _DetailRow(
              icon: Icons.date_range,
              label: 'Service Date',
              value: widget.serviceDetails['serviceDate'] ?? 'N/A',
            ),
            _DetailRow(
              icon: Icons.receipt,
              label: 'Invoice No',
              value: widget.serviceDetails['invoiceNumber'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBanner() {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    switch (_paymentStatus) {
      case 'paid':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        icon = Icons.payment;
        message = 'Payment received - Awaiting verification';
        break;
      case 'verified':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        icon = Icons.verified;
        message = 'Payment verified and confirmed';
        break;
      default:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        icon = Icons.pending_actions;
        message = 'Payment pending - Action required';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fee Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: _feeBreakdown.map((fee) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fee['type'] ?? 'Service Fee',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'KES ${(fee['amount'] ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'KES $_totalAmount',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            if (_paidAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount Paid',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'KES $_paidAmount',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pending Amount',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'KES $_pendingAmount',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.phone_android,
                title: 'M-Pesa',
                subtitle: 'Mobile Money',
                isSelected: _selectedPaymentMethod == 'mpesa',
                onTap: () => setState(() => _selectedPaymentMethod = 'mpesa'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentMethodCard(
                icon: Icons.account_balance,
                title: 'Bank',
                subtitle: 'Transfer/Deposit',
                isSelected: _selectedPaymentMethod == 'bank',
                onTap: () => setState(() => _selectedPaymentMethod = 'bank'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMpesaPaymentForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'M-Pesa Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mpesaPhoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '07XX XXX XXX',
                prefixText: '+254 ',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Text(
              'Instructions:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionStep('1', 'Dial *334# on your phone'),
                  _buildInstructionStep('2', 'Select "Lipa na M-Pesa"'),
                  _buildInstructionStep('3', 'Enter Paybill: 247247'),
                  _buildInstructionStep('4', 'Enter Account: ${widget.serviceDetails['invoiceNumber']}'),
                  _buildInstructionStep('5', 'Enter Amount: KES $_pendingAmount'),
                  _buildInstructionStep('6', 'Enter your M-Pesa PIN'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankVerificationForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Payment Verification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bank Details:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBankDetail('Bank Name', 'Equity Bank Kenya'),
                  _buildBankDetail('Account Name', 'AgriVet Services Ltd'),
                  _buildBankDetail('Account Number', '0140278901234'),
                  _buildBankDetail('Branch', 'Nairobi CBD'),
                  _buildBankDetail('Swift Code', 'EQBLKENA'),
                  _buildBankDetail('Reference', widget.serviceDetails['invoiceNumber'] ?? 'INV-001'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _receiptNumberController,
              decoration: const InputDecoration(
                labelText: 'Payment Receipt Number',
                hintText: 'Enter receipt/trace number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Payment Notes (Optional)',
                hintText: 'Any additional information about the payment',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyPaidSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Received',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Payment of KES $_paidAmount received',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.serviceDetails['paymentMethod'] != null)
              Row(
                children: [
                  Icon(Icons.payment, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Via ${widget.serviceDetails['paymentMethod']}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            if (widget.serviceDetails['paymentDate'] != null)
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'On ${widget.serviceDetails['paymentDate']}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentVerifiedSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Payment Verified & Confirmed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.receipt,
              label: 'Receipt Number',
              value: widget.serviceDetails['receiptNumber'] ?? 'N/A',
            ),
            _DetailRow(
              icon: Icons.person,
              label: 'Verified By',
              value: widget.serviceDetails['verifiedBy'] ?? 'N/A',
            ),
            _DetailRow(
              icon: Icons.date_range,
              label: 'Verification Date',
              value: widget.serviceDetails['verificationDate'] ?? 'N/A',
            ),
            if (widget.serviceDetails['verificationNotes'] != null)
              _DetailRow(
                icon: Icons.note,
                label: 'Notes',
                value: widget.serviceDetails['verificationNotes'] ?? '',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_paymentStatus == 'verified') {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.done),
          label: const Text('Close'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        ),
      );
    }

    return Row(
      children: [
        if (_paymentStatus == 'pending')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (_paymentStatus == 'pending') const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handlePaymentAction,
            icon: Icon(_getActionButtonIcon()),
            label: Text(_getActionButtonText()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: _getActionButtonColor(),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getActionButtonIcon() {
    switch (_paymentStatus) {
      case 'paid':
        return Icons.verified;
      case 'verified':
        return Icons.done;
      default:
        return Icons.payment;
    }
  }

  String _getActionButtonText() {
    switch (_paymentStatus) {
      case 'paid':
        return 'Verify Payment';
      case 'verified':
        return 'Payment Verified';
      default:
        return _selectedPaymentMethod == 'mpesa' ? 'Send M-Pesa Request' : 'Mark as Paid';
    }
  }

  Color _getActionButtonColor() {
    switch (_paymentStatus) {
      case 'paid':
        return Colors.blue.shade600;
      case 'verified':
        return Colors.green.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  Widget _buildInstructionStep(String step, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePaymentAction() async {
    if (_paymentStatus == 'paid') {
      // Verify payment
      setState(() => _isVerifyingPayment = true);
      await _verifyPayment();
      setState(() => _isVerifyingPayment = false);
    } else if (_paymentStatus == 'pending') {
      if (_selectedPaymentMethod == 'mpesa') {
        if (_mpesaPhoneController.text.isEmpty) {
          _showError('Please enter phone number');
          return;
        }
        setState(() => _isProcessingPayment = true);
        await _processMpesaPayment();
        setState(() => _isProcessingPayment = false);
      } else {
        if (_receiptNumberController.text.isEmpty) {
          _showError('Please enter receipt number');
          return;
        }
        setState(() => _isProcessingPayment = true);
        await _markAsPaid();
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _processMpesaPayment() async {
    // Simulate API call to send M-Pesa request
    await Future.delayed(const Duration(seconds: 2));

    // In real app, this would call an API to initiate M-Pesa payment
    setState(() {
      _paymentStatus = 'paid';
    });

    _showSuccess('M-Pesa payment request sent successfully');
  }

  Future<void> _markAsPaid() async {
    // Simulate API call to mark as paid
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _paymentStatus = 'paid';
    });

    _showSuccess('Payment marked as received');
  }

  Future<void> _verifyPayment() async {
    // Simulate API call to verify payment
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _paymentStatus = 'verified';
    });

    _showSuccess('Payment verified successfully');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.orange.shade600 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.orange.shade800 : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}