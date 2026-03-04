import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/features/farmer/subscription/repo/subscription_repo.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';

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
  bool _isProcessing = false;

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

  String get _formattedAmount =>
      '$_currencySymbol ${widget.amount.toStringAsFixed(widget.amount % 1 == 0 ? 0 : 2)}';

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ProcessingDialog(),
    );

    try {
      // Just call createPaymentMethod directly — Stripe uses the native view internally
      // If card is incomplete, StripeException will be thrown automatically
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );

      LogUtil.success('Payment method created: ${paymentMethod.id}');

      final result = await _repo.payFarmSubscription(
        farmSubscriptionPlanId: widget.planId,
        cardToken: paymentMethod.id,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

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
    } on StripeException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isProcessing = false);
      // Stripe will throw a clear error if card is incomplete/invalid
      _showFailureDialog(
          e.error.localizedMessage ?? 'Card error. Please try again.');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isProcessing = false);
      _showFailureDialog('Unexpected error. Please try again.');
    }
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
  void initState() {
    super.initState();
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
            const Text('Subscribe',
                style:
                TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(widget.planName,
                style: TextStyle(fontSize: 12, color: _planColor)),
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
            _buildStripeCardForm(),
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
                    Text(widget.planName,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _planColor)),
                    Text(billingLabel,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formattedAmount,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _planColor),
                  ),
                  Text('/${widget.billingCycleDays} days',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Subscription type', value: widget.planName),
          _SummaryRow(label: 'Billing cycle', value: billingLabel),
          _SummaryRow(
            label: 'Amount due today',
            value: _formattedAmount,
            valueColor: _planColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStripeCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Details',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800]),
        ),
        const SizedBox(height: 4),
        Text(
          'Visa, Mastercard, American Express accepted',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CardField(
            enablePostalCode: false,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.lock_outline, size: 13, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              'Powered by Stripe',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isProcessing
            ? null
            : _processPayment,
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
          'Pay $_formattedAmount',
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
    super.dispose();
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

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
            const CircularProgressIndicator(),
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
              success
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              size: 64,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              success ? 'Subscription Activated!' : 'Payment Failed',
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
