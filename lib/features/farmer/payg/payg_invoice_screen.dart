import 'package:agriflock/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shows current and past device lease invoices.
class PaygInvoiceScreen extends StatefulWidget {
  const PaygInvoiceScreen({super.key});

  @override
  State<PaygInvoiceScreen> createState() => _PaygInvoiceScreenState();
}

class _PaygInvoiceScreenState extends State<PaygInvoiceScreen> {
  bool _showCurrentInvoice = true;

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
                child:
                    const Icon(Icons.image, size: 40, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Invoice Details'),
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
            _buildInvoiceHeader(),
            const SizedBox(height: 24),
            _buildInvoiceToggle(),
            const SizedBox(height: 24),
            if (_showCurrentInvoice) _buildCurrentInvoice(),
            if (!_showCurrentInvoice) _buildPastInvoices(),
            const SizedBox(height: 32),
            _buildInvoiceActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.receipt_long, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invoice Status',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14)),
                      const SizedBox(height: 4),
                      const Text(
                        '💰 Due in 5 Days',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InvoiceDetailItem(
                    label: 'Invoice #',
                    value: 'INV-2024-0012',
                    icon: Icons.numbers),
                _InvoiceDetailItem(
                    label: 'Device',
                    value: 'Brooder 001',
                    icon: Icons.device_thermostat),
                _InvoiceDetailItem(
                    label: 'Period',
                    value: 'Dec 2024',
                    icon: Icons.calendar_month),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleButton(
            label: 'Current Invoice',
            isSelected: _showCurrentInvoice,
            onTap: () => setState(() => _showCurrentInvoice = true),
          ),
          _ToggleButton(
            label: 'Past Invoices',
            isSelected: !_showCurrentInvoice,
            onTap: () => setState(() => _showCurrentInvoice = false),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentInvoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invoice Details',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Payment Due: Dec 15, 2024',
                style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InvoiceItemRow(
                    description: 'Monthly Lease Payment', amount: 'KES 2,000'),
                _InvoiceItemRow(description: 'Service Fee', amount: 'KES 300'),
                _InvoiceItemRow(
                    description: 'Maintenance Fee', amount: 'KES 200'),
                const Divider(height: 32, color: Colors.grey),
                _InvoiceItemRow(
                    description: 'Total Amount',
                    amount: 'KES 2,500',
                    isTotal: true),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Billing Information',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _BillingInfoRow(
                    label: 'Billed To:',
                    value: 'John Doe\nFarmers Cooperative\nNairobi, Kenya'),
                _BillingInfoRow(label: 'Device ID:', value: 'BRD-001-2024'),
                _BillingInfoRow(label: 'Invoice Date:', value: 'Dec 1, 2024'),
                _BillingInfoRow(
                    label: 'Due Date:',
                    value: 'Dec 15, 2024',
                    isUrgent: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPastInvoices() {
    final pastInvoices = [
      _Invoice(
          id: 'INV-2024-0011',
          date: 'Nov 15, 2024',
          amount: 2500,
          status: _InvoiceStatus.paid,
          device: 'Brooder 001'),
      _Invoice(
          id: 'INV-2024-0010',
          date: 'Oct 15, 2024',
          amount: 2500,
          status: _InvoiceStatus.paid,
          device: 'Brooder 001'),
      _Invoice(
          id: 'INV-2024-0009',
          date: 'Sep 15, 2024',
          amount: 2500,
          status: _InvoiceStatus.paid,
          device: 'Brooder 001'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment History',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 16),
        ...pastInvoices.map((inv) => _PastInvoiceCard(invoice: inv)),
      ],
    );
  }

  Widget _buildInvoiceActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.paygPayment),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 20),
                SizedBox(width: 8),
                Text('Pay Now',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _requestExtension,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.blue.shade300),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text('Request Payment Extension',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _requestExtension() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Payment Extension'),
        content: const Text(
            'Are you sure you want to request a payment extension for this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Extension request submitted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}

// ── Local models & widgets ───────────────────────────────────────────────────

enum _InvoiceStatus { paid, pending, overdue }

class _Invoice {
  final String id;
  final String date;
  final double amount;
  final _InvoiceStatus status;
  final String device;

  const _Invoice({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.device,
  });
}

class _InvoiceDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InvoiceDetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade600),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1))
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceItemRow extends StatelessWidget {
  final String description;
  final String amount;
  final bool isTotal;

  const _InvoiceItemRow({
    required this.description,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(description,
              style: isTotal
                  ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  : TextStyle(color: Colors.grey.shade700)),
          Text(amount,
              style: isTotal
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green.shade700)
                  : const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BillingInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isUrgent;

  const _BillingInfoRow({
    required this.label,
    required this.value,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isUrgent
                      ? Colors.orange.shade700
                      : Colors.grey.shade800,
                )),
          ),
        ],
      ),
    );
  }
}

class _PastInvoiceCard extends StatelessWidget {
  final _Invoice invoice;

  const _PastInvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.status == _InvoiceStatus.paid;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isPaid ? Colors.green : Colors.orange)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.access_time,
                size: 20,
                color: isPaid ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(invoice.id,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      Text('KES ${invoice.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(invoice.date,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isPaid ? Colors.green : Colors.orange)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPaid ? 'Paid' : 'Pending',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isPaid
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                  Text(invoice.device,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
