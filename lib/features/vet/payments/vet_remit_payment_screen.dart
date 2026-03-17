import 'package:agriflock/core/utils/format_util.dart';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:agriflock/features/vet/payments/models/vet_pending_payment.dart';
import 'package:agriflock/features/vet/schedules/repo/visit_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:go_router/go_router.dart';

class VetRemitPaymentScreen extends StatefulWidget {
  final VetPendingPayment payment;

  const VetRemitPaymentScreen({super.key, required this.payment});

  @override
  State<VetRemitPaymentScreen> createState() => _VetRemitPaymentScreenState();
}

class _VetRemitPaymentScreenState extends State<VetRemitPaymentScreen> {
  final VisitsRepository _repo = VisitsRepository();
  bool _isProcessing = false;

  String get _currency => widget.payment.currency;
  double get _remitAmount => widget.payment.platformCommission;
  String get _formattedRemit => '$_currency ${FormatUtil.formatAmount(_remitAmount)}';

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ProcessingDialog(),
    );

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      LogUtil.success('Payment method created: ${paymentMethod.id}');

      final email = await SecureStorage().getUserEmail() ?? '';

      final result = await _repo.remitVetPayment(
        paymentId: widget.payment.id,
        cardToken: paymentMethod.id,
        email: email,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      result.when(
        success: (_) => _showResultDialog(success: true),
        failure: (message, _, __) {
          setState(() => _isProcessing = false);
          _showResultDialog(success: false, errorMessage: message);
        },
      );
    } on StripeException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isProcessing = false);
      _showResultDialog(
        success: false,
        errorMessage:
            e.error.localizedMessage ?? 'Card error. Please try again.',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isProcessing = false);
      _showResultDialog(
          success: false, errorMessage: 'Unexpected error. Please try again.');
    }
  }

  void _showResultDialog({required bool success, String? errorMessage}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.cancel,
              size: 64,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              success ? 'Payment Successful!' : 'Payment Failed',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              success
                  ? 'Platform commission of $_formattedRemit (20%) for ${widget.payment.paymentNumber} has been remitted.'
                  : (errorMessage ?? 'Something went wrong.'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (success) context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: success ? Colors.green : Colors.grey,
            ),
            child: Text(success ? 'Done' : 'Close'),
          ),
        ],
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
            const Text('Remit Payment',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(widget.payment.paymentNumber,
                style: TextStyle(fontSize: 12, color: Colors.green.shade600)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.medical_services,
                            color: Colors.green, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Platform Commission Remittance',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            Text(widget.payment.paymentNumber,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _Row(
                    label: 'Total Service Amount',
                    value:
                        '$_currency ${FormatUtil.formatAmount(widget.payment.totalAmount)}',
                    valueColor: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  _Row(
                    label: 'Your Earnings (80%)',
                    value:
                        '$_currency ${FormatUtil.formatAmount(widget.payment.vetEarnings)}',
                    valueColor: Colors.grey.shade600,
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Platform Commission',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('20% to remit',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.orange)),
                        ],
                      ),

                    ],
                  ),
                  Text(
                    _formattedRemit,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Card input
            const Text('Card Details',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const CardField(
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Remit $_formattedRemit',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text('Secured by Stripe',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _Row(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(fontSize: 14, color: valueColor)),
      ],
    );
  }
}

class _ProcessingDialog extends StatelessWidget {
  const _ProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.green),
          SizedBox(height: 16),
          Text('Processing Payment...'),
          SizedBox(height: 4),
          Text('Please do not close this screen.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
