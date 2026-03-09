import 'package:agriflock/features/vet/payments/models/vet_pending_payment.dart'
    show VetPaymentsSummary, VetPendingPayment;
import 'package:agriflock/features/vet/schedules/repo/visit_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore_for_file: deprecated_member_use

class VetPendingPaymentsScreen extends StatefulWidget {
  const VetPendingPaymentsScreen({super.key});

  @override
  State<VetPendingPaymentsScreen> createState() =>
      _VetPendingPaymentsScreenState();
}

class _VetPendingPaymentsScreenState extends State<VetPendingPaymentsScreen> {
  final VisitsRepository _repo = VisitsRepository();
  bool _isLoading = true;
  String? _error;
  VetPaymentsSummary? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await _repo.getVetPaymentsSummary();
    if (!mounted) return;
    result.when(
      success: (data) => setState(() {
        _summary = data;
        _isLoading = false;
      }),
      failure: (message, _, __) => setState(() {
        _error = message;
        _isLoading = false;
      }),
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
        title: const Text('Pending Remittances',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final data = _summary!;
    final payments = data.pendingPayments;

    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green.shade400),
            const SizedBox(height: 16),
            const Text('No pending remittances',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('You\'re all caught up!',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pending Remittance',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(
                      '${payments.first.currency} ${data.pendingRemittance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payment cards
          ...payments.map((p) => _PaymentCard(
                payment: p,
                onRemit: () =>
                    context.push('/vet/payment/remit', extra: p),
              )),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final VetPendingPayment payment;
  final VoidCallback onRemit;

  const _PaymentCard({required this.payment, required this.onRemit});

  @override
  Widget build(BuildContext context) {
    final currency = payment.currency;
    final bool isOverdue = payment.remittanceDueDate != null &&
        payment.remittanceDueDate!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isOverdue ? Colors.red.shade200 : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(payment.paymentNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isOverdue ? Colors.red : Colors.orange),
                  ),
                  child: Text(
                    isOverdue ? 'Overdue' : 'Due',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (payment.remittanceDueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 13,
                      color: isOverdue ? Colors.red : Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${_formatDate(payment.remittanceDueDate!)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey.shade600),
                  ),
                ],
              ),
            ],

            const Divider(height: 20),

            // Amount breakdown
            _AmountRow(
              label: 'Total Amount',
              value: '$currency ${payment.totalAmount.toStringAsFixed(2)}',
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 6),
            _AmountRow(
              label: 'Your Earnings (80%)',
              value: '$currency ${payment.vetEarnings.toStringAsFixed(2)}',
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 6),
            _AmountRow(
              label: 'Platform Commission (20%)',
              value:
                  '$currency ${payment.platformCommission.toStringAsFixed(2)}',
              color: Colors.orange.shade700,
              bold: true,
            ),

            if (payment.farmerPaymentMethod != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.payment, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Farmer paid via ${payment.farmerPaymentMethod}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRemit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Remit $currency ${payment.platformCommission.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _AmountRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: color)),
      ],
    );
  }
}
