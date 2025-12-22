import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PAYGPaymentScreen extends StatefulWidget {
  const PAYGPaymentScreen({super.key});

  @override
  State<PAYGPaymentScreen> createState() => _PAYGPaymentScreenState();
}

class _PAYGPaymentScreenState extends State<PAYGPaymentScreen> {
  int _selectedMethod = 0;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 0,
      name: 'M-Pesa',
      icon: Icons.phone_iphone,
      color: Colors.green,
      description: 'Pay via M-Pesa mobile money',
    ),
    PaymentMethod(
      id: 1,
      name: 'Credit/Debit Card',
      icon: Icons.credit_card,
      color: Colors.blue,
      description: 'Pay with Visa, Mastercard',
    ),
    PaymentMethod(
      id: 2,
      name: 'Bank Transfer',
      icon: Icons.account_balance,
      color: Colors.orange,
      description: 'Direct bank transfer',
    ),
  ];

  void _processPayment() {
    // Simulate payment processing
    showDialog(
      context: context,
      builder: (context) => const PaymentProcessingDialog(),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close processing dialog
      _showPaymentResult(true);
    });
  }

  void _showPaymentResult(bool success) {
    showDialog(
      context: context,
      builder: (context) => PaymentResultDialog(
        success: success,
        onDone: () {
          Navigator.pop(context);
          if (success) {
            context.pop(); // Return to dashboard
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title:Row(
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
            const Text('Make Payment'),
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
            // Payment Summary
            _buildPaymentSummary(),
            const SizedBox(height: 32),

            // Payment Method Selection
            _buildPaymentMethods(),
            const SizedBox(height: 24),

            // Payment Form
            _buildPaymentForm(),
            const SizedBox(height: 32),

            // Pay Button
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
                const Text(
                  'Payment Due',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
            _SummaryRow(
              label: 'Lease Period',
              value: 'Dec 1 - Dec 31, 2024',
            ),
            _SummaryRow(
              label: 'Due Date',
              value: 'Dec 15, 2024',
            ),
            _SummaryRow(
              label: 'Device',
              value: 'Brooder 001',
            ),
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
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ..._paymentMethods.map((method) => _PaymentMethodCard(
          method: method,
          isSelected: _selectedMethod == method.id,
          onTap: () {
            setState(() {
              _selectedMethod = method.id;
            });
          },
        )),
      ],
    );
  }

  Widget _buildPaymentForm() {
    if (_selectedMethod == 0) {
      return _buildMpesaForm();
    } else if (_selectedMethod == 1) {
      return _buildCardForm();
    } else {
      return _buildBankTransferForm();
    }
  }

  Widget _buildMpesaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'M-Pesa Payment',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'M-Pesa Phone Number',
            prefixText: '+254 ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.phone, color: Colors.green),
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
                  'You will receive an STK push prompt on your phone to complete the payment.',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 14,
                  ),
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
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.credit_card, color: Colors.blue),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.person, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildBankTransferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Transfer',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
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
              _BankDetailRow(
                label: 'Bank Name',
                value: 'Equity Bank Kenya',
              ),
              _BankDetailRow(
                label: 'Account Name',
                value: 'Agriflock 360 Ltd',
              ),
              _BankDetailRow(
                label: 'Account Number',
                value: '1234567890',
              ),
              _BankDetailRow(
                label: 'Branch',
                value: 'Nairobi Main',
              ),
              _BankDetailRow(
                label: 'Swift Code',
                value: 'EQBLKENA',
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.orange.shade200),
              const SizedBox(height: 12),
              Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Use your lease number as reference\n'
                    '2. Send exact amount: KES 2,500\n'
                    '3. Upload receipt in app after transfer\n'
                    '4. Allow 24 hours for processing',
                style: TextStyle(
                  color: Colors.orange.shade700,
                ),
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
        onPressed: _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Pay KES 2,500',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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

class PaymentMethod {
  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
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
                    Text(
                      method.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      method.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
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

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BankDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _BankDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentProcessingDialog extends StatelessWidget {
  const PaymentProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              'Processing Payment',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we process your payment...',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentResultDialog extends StatelessWidget {
  final bool success;
  final VoidCallback onDone;

  const PaymentResultDialog({
    super.key,
    required this.success,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              success
                  ? 'Your payment has been processed successfully. Your device has been unlocked.'
                  : 'We encountered an issue processing your payment. Please try again.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
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