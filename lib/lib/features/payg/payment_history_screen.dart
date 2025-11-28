// lib/payg/payment_history_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(),
          const SizedBox(height: 16),

          // Filter Chips
          _buildFilterChips(),
          const SizedBox(height: 16),

          // Payment List
          Expanded(
            child: _buildPaymentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.deepPurple.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _SummaryItem(
            value: 'KES 7,500',
            label: 'Total Paid',
            color: Colors.green,
          ),
          const SizedBox(width: 20),
          _SummaryItem(
            value: '3',
            label: 'Payments',
            color: Colors.blue,
          ),
          const SizedBox(width: 20),
          _SummaryItem(
            value: '100%',
            label: 'Success Rate',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FilterChip(label: 'All', isSelected: true),
          _FilterChip(label: 'This Month'),
          _FilterChip(label: 'Last 3 Months'),
          _FilterChip(label: 'This Year'),
          _FilterChip(label: 'Failed'),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    final payments = [
      _PaymentData(
        amount: 'KES 2,500',
        date: 'Nov 15, 2024',
        status: 'Completed',
        method: 'M-Pesa',
        reference: 'MPE123456789',
        statusColor: Colors.green,
      ),
      _PaymentData(
        amount: 'KES 2,500',
        date: 'Oct 15, 2024',
        status: 'Completed',
        method: 'M-Pesa',
        reference: 'MPE123456788',
        statusColor: Colors.green,
      ),
      _PaymentData(
        amount: 'KES 2,500',
        date: 'Sep 15, 2024',
        status: 'Completed',
        method: 'Credit Card',
        reference: 'CARD1234567',
        statusColor: Colors.green,
      ),
      _PaymentData(
        amount: 'KES 2,500',
        date: 'Aug 15, 2024',
        status: 'Failed',
        method: 'M-Pesa',
        reference: 'MPE123456787',
        statusColor: Colors.red,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return _PaymentHistoryCard(payment: payments[index]);
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

class _PaymentData {
  final String amount;
  final String date;
  final String status;
  final String method;
  final String reference;
  final Color statusColor;

  _PaymentData({
    required this.amount,
    required this.date,
    required this.status,
    required this.method,
    required this.reference,
    required this.statusColor,
  });
}

class _PaymentHistoryCard extends StatelessWidget {
  final _PaymentData payment;

  const _PaymentHistoryCard({
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: payment.statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payment,
                    size: 20,
                    color: payment.statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${payment.method} • ${payment.date}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: payment.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: payment.statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    payment.status,
                    style: TextStyle(
                      color: payment.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.receipt, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  'Reference: ${payment.reference}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Show receipt/download
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('View Receipt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}