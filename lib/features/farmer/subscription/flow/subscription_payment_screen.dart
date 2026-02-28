import 'package:agriflock/features/farmer/subscription/repo/subscription_repo.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Payment screen specifically for feature subscription plans (Silver / Gold / Platinum).
/// Receives plan details via route extra and processes the subscription payment.
class SubscriptionPaymentScreen extends StatefulWidget {
  final String planId;
  final String planName;
  final String planType;
  final double amount;
  final String currency;
  final int billingCycleDays;
  final bool isOnboarding;

  const SubscriptionPaymentScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.planType,
    required this.amount,
    required this.currency,
    required this.billingCycleDays,
    required this.isOnboarding,
  });

  @override
  State<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState
    extends State<SubscriptionPaymentScreen> {
  final SubscriptionRepository _repo = SubscriptionRepository();

  int _selectedMethod = 0;
  bool _isProcessing = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Color get _planColor {
    switch (widget.planType.toUpperCase()) {
      case 'SILVER':
        return const Color(0xFF5C7CFA);
      case 'GOLD':
        return const Color(0xFFF59F00);
      case 'PLATINUM':
        return const Color(0xFF7C3AED);
      default:
        return Colors.green;
    }
  }

  String get _currencySymbol {
    switch (widget.currency.toUpperCase()) {
      case 'KES':
        return 'KSh';
      case 'USD':
        return '\$';
      default:
        return widget.currency;
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Show processing dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ProcessingDialog(),
    );

    // Simulate payment gateway call, then call subscription API
    await Future.delayed(const Duration(seconds: 2));
    final result = await _repo.subscribeToPlan(widget.planId);

    if (!mounted) return;
    Navigator.of(context).pop(); // close processing dialog

    result.when(
      success: (_) async {
        await secureStorage.saveSubscriptionState('has_subscription_plan');
        if (!mounted) return;
        _showSuccessDialog();
      },
      failure: (message, _, __) {
        setState(() => _isProcessing = false);
        _showFailureDialog(message);
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        success: true,
        planName: widget.planName,
        onDone: () {
          Navigator.of(context).pop();
          if (widget.isOnboarding) {
            context.go('/onboarding/setup');
          } else {
            context.go('/home');
          }
        },
      ),
    );
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => _ResultDialog(
        success: false,
        planName: widget.planName,
        errorMessage: message,
        onDone: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscribe',
              style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text(
              widget.planName,
              style: TextStyle(fontSize: 12, color: _planColor),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanSummary(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 20),
            _buildPaymentForm(),
            const SizedBox(height: 32),
            _buildPayButton(),
            const SizedBox(height: 16),
            _buildSecureNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummary() {
    final billingLabel = widget.billingCycleDays == 30
        ? 'Monthly'
        : widget.billingCycleDays == 365
            ? 'Annual'
            : '${widget.billingCycleDays}-day cycle';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _planColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _planColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _planColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.workspace_premium_rounded,
                    color: _planColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.planName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _planColor,
                      ),
                    ),
                    Text(
                      billingLabel,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_currencySymbol ${widget.amount.toStringAsFixed(widget.amount % 1 == 0 ? 0 : 2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _planColor,
                    ),
                  ),
                  Text(
                    '/${widget.billingCycleDays} days',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 10),
          _SummaryRow(
              label: 'Subscription type', value: widget.planName),
          _SummaryRow(
              label: 'Billing cycle', value: billingLabel),
          _SummaryRow(
            label: 'Amount due today',
            value:
                '$_currencySymbol ${widget.amount.toStringAsFixed(widget.amount % 1 == 0 ? 0 : 2)}',
            valueColor: _planColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      _PaymentMethodOption(
          id: 0,
          name: 'M-Pesa',
          icon: Icons.phone_android_rounded,
          color: Colors.green,
          description: 'Pay via M-Pesa mobile money'),
      _PaymentMethodOption(
          id: 1,
          name: 'Credit / Debit Card',
          icon: Icons.credit_card_rounded,
          color: Colors.blue,
          description: 'Visa, Mastercard'),
      _PaymentMethodOption(
          id: 2,
          name: 'Bank Transfer',
          icon: Icons.account_balance_rounded,
          color: Colors.orange,
          description: 'Direct bank transfer'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        ...methods.map((m) => _buildMethodCard(m)),
      ],
    );
  }

  Widget _buildMethodCard(_PaymentMethodOption method) {
    final isSelected = _selectedMethod == method.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method.color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: method.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(method.icon, size: 20, color: method.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(method.description,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? method.color : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: method.color,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedMethod) {
      case 0:
        return _buildMpesaForm();
      case 1:
        return _buildCardForm();
      default:
        return _buildBankTransferForm();
    }
  }

  Widget _buildMpesaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('M-Pesa Details',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800])),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'M-Pesa Phone Number',
            prefixText: '+254 ',
            prefixIcon:
                const Icon(Icons.phone_android_rounded, color: Colors.green),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  color: Colors.green.shade600, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You will receive an M-Pesa STK push to complete the payment.',
                  style:
                      TextStyle(fontSize: 13, color: Colors.green.shade800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Details',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800])),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            prefixIcon:
                const Icon(Icons.credit_card_rounded, color: Colors.blue),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'MM/YY',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon:
                const Icon(Icons.person_rounded, color: Colors.blue),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bank Transfer Details',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade800)),
          const SizedBox(height: 12),
          _BankRow(label: 'Bank', value: 'Equity Bank Kenya'),
          _BankRow(label: 'Account Name', value: 'Agriflock 360 Ltd'),
          _BankRow(label: 'Account No.', value: '1234567890'),
          _BankRow(label: 'Branch', value: 'Nairobi Main'),
          _BankRow(label: 'Swift Code', value: 'EQBLKENA'),
          Divider(color: Colors.orange.shade200, height: 24),
          Text(
            'Use your account ID as the payment reference.\nAllow 24 hours for processing.',
            style: TextStyle(
                fontSize: 12.5, color: Colors.orange.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _planColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _planColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                'Pay $_currencySymbol ${widget.amount.toStringAsFixed(widget.amount % 1 == 0 ? 0 : 2)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSecureNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Text(
          'Payments are encrypted and secure',
          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

// ── Local helper widgets ────────────────────────────────────────────────────

class _PaymentMethodOption {
  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const _PaymentMethodOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  final String label;
  final String value;

  const _BankRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: Colors.orange.shade700)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800)),
          ),
        ],
      ),
    );
  }
}

class _ProcessingDialog extends StatelessWidget {
  const _ProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 20),
            const Text('Processing Payment',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Please wait…',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final bool success;
  final String planName;
  final String? errorMessage;
  final VoidCallback onDone;

  const _ResultDialog({
    required this.success,
    required this.planName,
    required this.onDone,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              size: 64,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              success
                  ? 'Subscription Activated!'
                  : 'Payment Failed',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              success
                  ? 'Your $planName subscription is now active. Welcome to full farm management!'
                  : (errorMessage ??
                      'Something went wrong. Please try again.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(success ? 'Get Started' : 'Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
