import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Payment screen for monthly device lease (PAYG) payments.
/// Separate from subscription payments — this is for device rental fees only.
class PaygPaymentScreen extends StatefulWidget {
  const PaygPaymentScreen({super.key});

  @override
  State<PaygPaymentScreen> createState() => _PaygPaymentScreenState();
}

class _PaygPaymentScreenState extends State<PaygPaymentScreen> {
  int _selectedMethod = 0;
  bool _isProcessing = false;
  final TextEditingController _phoneController = TextEditingController();
  // Card payment handled by Stripe CardField — no manual controllers needed

  final List<_PaymentMethod> _paymentMethods = const [
    _PaymentMethod(
      id: 0,
      name: 'M-Pesa',
      icon: Icons.phone_iphone,
      color: Colors.green,
      description: 'Pay via M-Pesa mobile money',
    ),
    _PaymentMethod(
      id: 1,
      name: 'Credit / Debit Card',
      icon: Icons.credit_card,
      color: Colors.blue,
      description: 'Pay with Visa, Mastercard',
    ),
    _PaymentMethod(
      id: 2,
      name: 'Bank Transfer',
      icon: Icons.account_balance,
      color: Colors.orange,
      description: 'Direct bank transfer',
    ),
  ];

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    // For card payments, use Stripe
    if (_selectedMethod == 1) {
      await _processStripeCardPayment();
      return;
    }

    // For M-Pesa / Bank Transfer — show processing dialog and simulate
    setState(() => _isProcessing = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PaygPaymentProcessingDialog(),
    );

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pop(context);
    setState(() => _isProcessing = false);
    _showPaymentResult(true);
  }

  Future<void> _processStripeCardPayment() async {
    setState(() => _isProcessing = true);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PaygPaymentProcessingDialog(),
    );

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      LogUtil.success('PAYG card token: ${paymentMethod.id}');

      // POST to API with the payment method token
      final token = await SecureStorage().getToken();
      const apiBase = 'https://api.agriflock360.com/api/v1';
      final res = await http.post(
        Uri.parse('$apiBase/payg/pay'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'payment_method_id': paymentMethod.id}),
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      final success = res.statusCode == 200 || res.statusCode == 201;
      setState(() => _isProcessing = false);
      _showPaymentResult(success);
    } on StripeException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isProcessing = false);
      ToastUtil.showError(
        e.error.localizedMessage ?? 'Card error. Please try again.',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isProcessing = false);
      ToastUtil.showError('Unexpected error. Please try again.');
    }
  }

  void _showPaymentResult(bool success) {
    showDialog(
      context: context,
      builder: (_) => PaygPaymentResultDialog(
        success: success,
        onDone: () {
          Navigator.pop(context);
          if (success) context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.green,
                child: const Icon(Icons.image, size: 40, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Lease Payment'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentSummary(),
            const SizedBox(height: 32),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildPaymentForm(),
            const SizedBox(height: 32),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.payment, color: Colors.blue),
                const SizedBox(width: 12),
                const Text('Lease Payment Due',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(
                  'KES 2,500',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Lease Period', value: 'Dec 1 – Dec 31, 2024'),
            _SummaryRow(label: 'Due Date', value: 'Dec 15, 2024'),
            _SummaryRow(label: 'Device', value: 'Brooder 001'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 16),
        ..._paymentMethods.map((method) => _PaymentMethodCard(
              method: method,
              isSelected: _selectedMethod == method.id,
              onTap: () => setState(() => _selectedMethod = method.id),
            )),
      ],
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
        Text('M-Pesa Payment',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'M-Pesa Phone Number',
            prefixText: '+254 ',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.phone, color: Colors.green),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will receive an STK push on your phone to complete the payment.',
                  style: TextStyle(color: Colors.green.shade800, fontSize: 14),
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
        Text(
          'Card Details',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const CardField(
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your card is secured by Stripe. We never store card details.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bank Transfer',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BankDetailRow(label: 'Bank Name', value: 'Equity Bank Kenya'),
              _BankDetailRow(label: 'Account Name', value: 'Agriflock 360 Ltd'),
              _BankDetailRow(label: 'Account Number', value: '1234567890'),
              _BankDetailRow(label: 'Branch', value: 'Nairobi Main'),
              _BankDetailRow(label: 'Swift Code', value: 'EQBLKENA'),
              const SizedBox(height: 16),
              Divider(color: Colors.orange.shade200),
              const SizedBox(height: 12),
              Text('Instructions:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800)),
              const SizedBox(height: 8),
              Text(
                '1. Use your lease reference number\n'
                '2. Send exact amount: KES 2,500\n'
                '3. Allow 24 hours for processing',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Pay KES 2,500',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

// ── Local helpers ────────────────────────────────────────────────────────────

class _PaymentMethod {
  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const _PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class _PaymentMethodCard extends StatelessWidget {
  final _PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? method.color : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: method.color.withValues(alpha: 0.1),
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
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(method.description,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? method.color : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: method.color,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BankDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _BankDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500)),
          ),
          Text(value,
              style: TextStyle(
                  color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Dialogs ──────────────────────────────────────────────────────────────────

class PaygPaymentProcessingDialog extends StatelessWidget {
  const PaygPaymentProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Processing Payment',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Please wait…',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class PaygPaymentResultDialog extends StatelessWidget {
  final bool success;
  final VoidCallback onDone;

  const PaygPaymentResultDialog({
    super.key,
    required this.success,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              size: 64,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              success ? 'Payment Successful!' : 'Payment Failed',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              success
                  ? 'Your device has been unlocked. Live data is now streaming.'
                  : 'We could not process your payment. Please try again.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(success ? 'Done' : 'Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
