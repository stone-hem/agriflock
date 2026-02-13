import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetPaymentsHistoryScreen extends StatefulWidget {
  const VetPaymentsHistoryScreen({super.key});

  @override
  State<VetPaymentsHistoryScreen> createState() => _VetPaymentsHistoryScreenState();
}

class _VetPaymentsHistoryScreenState extends State<VetPaymentsHistoryScreen> {
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': 'TXN-001',
      'farmerName': 'John Peterson',
      'farmerId': 'FARM-001',
      'service': 'Regular Checkup',
      'serviceType': 'Livestock Health Check',
      'amount': 150.00,
      'date': 'Dec 10, 2023',
      'time': '10:30 AM',
      'status': 'Completed',
      'isCredit': true,
      'paymentMethod': 'Credit Card',
      'animals': '15 Dairy Cows',
      'location': 'Green Valley Farm, Springfield',
      'duration': '2 hours',
      'notes': 'Routine health check for dairy herd. All cows in good condition.',
      'invoiceNumber': 'INV-2023-001',
    },
    {
      'id': 'TXN-002',
      'farmerName': 'Maria Rodriguez',
      'farmerId': 'FARM-002',
      'service': 'Vaccination Service',
      'serviceType': 'Vaccination Program',
      'amount': 200.00,
      'date': 'Dec 9, 2023',
      'time': '2:15 PM',
      'status': 'Completed',
      'isCredit': true,
      'paymentMethod': 'Mobile Money',
      'animals': '50 Poultry Birds',
      'location': 'Sunrise Poultry Farm, Riverside',
      'duration': '3 hours',
      'notes': 'Administered Newcastle and Fowl Pox vaccines.',
      'invoiceNumber': 'INV-2023-002',
    },
    {
      'id': 'TXN-003',
      'farmerName': 'Robert Chen',
      'farmerId': 'FARM-003',
      'service': 'Emergency Visit',
      'serviceType': 'Emergency Treatment',
      'amount': 300.00,
      'date': 'Dec 8, 2023',
      'time': '9:45 PM',
      'status': 'Pending',
      'isCredit': false,
      'paymentMethod': 'Cash',
      'animals': '3 Beef Cattle',
      'location': 'Chen Cattle Ranch, Hilltop',
      'duration': '4 hours',
      'notes': 'Emergency treatment for colic in cattle.',
      'invoiceNumber': 'INV-2023-003',
    },
    {
      'id': 'TXN-004',
      'farmerName': 'Platform Fee',
      'farmerId': 'PLATFORM',
      'service': 'Service Charge',
      'serviceType': 'Platform Fee',
      'amount': 15.00,
      'date': 'Dec 8, 2023',
      'time': '11:00 AM',
      'status': 'Completed',
      'isCredit': false,
      'paymentMethod': 'Auto-deduct',
      'animals': 'N/A',
      'location': 'Platform Service',
      'duration': 'N/A',
      'notes': 'Monthly platform service fee.',
      'invoiceNumber': 'FEE-2023-001',
    },
    {
      'id': 'TXN-005',
      'farmerName': 'David Wilson',
      'farmerId': 'FARM-004',
      'service': 'Deworming Service',
      'serviceType': 'Parasite Control',
      'amount': 120.00,
      'date': 'Dec 7, 2023',
      'time': '1:30 PM',
      'status': 'Completed',
      'isCredit': true,
      'paymentMethod': 'Bank Transfer',
      'animals': '25 Goats',
      'location': 'Wilson Goat Farm, Meadowview',
      'duration': '1.5 hours',
      'notes': 'Deworming of entire goat herd.',
      'invoiceNumber': 'INV-2023-004',
    },
    {
      'id': 'TXN-006',
      'farmerName': 'Sarah Miller',
      'farmerId': 'FARM-005',
      'service': 'Pregnancy Diagnosis',
      'serviceType': 'Reproductive Health',
      'amount': 80.00,
      'date': 'Dec 6, 2023',
      'time': '10:00 AM',
      'status': 'Completed',
      'isCredit': true,
      'paymentMethod': 'Credit Card',
      'animals': '8 Dairy Cows',
      'location': 'Miller Dairy Farm, Greenfield',
      'duration': '1 hour',
      'notes': 'Ultrasound pregnancy diagnosis.',
      'invoiceNumber': 'INV-2023-005',
    },
    {
      'id': 'TXN-007',
      'farmerName': 'James Brown',
      'farmerId': 'FARM-006',
      'service': 'Hoof Trimming',
      'serviceType': 'Preventive Care',
      'amount': 90.00,
      'date': 'Dec 5, 2023',
      'time': '3:00 PM',
      'status': 'Completed',
      'isCredit': true,
      'paymentMethod': 'Mobile Money',
      'animals': '12 Sheep',
      'location': 'Brown Sheep Farm, Hillcrest',
      'duration': '2 hours',
      'notes': 'Hoof trimming and foot care.',
      'invoiceNumber': 'INV-2023-006',
    },
    {
      'id': 'TXN-008',
      'farmerName': 'Platform Fee',
      'farmerId': 'PLATFORM',
      'service': 'Service Charge',
      'serviceType': 'Platform Fee',
      'amount': 12.50,
      'date': 'Dec 1, 2023',
      'time': '9:00 AM',
      'status': 'Completed',
      'isCredit': false,
      'paymentMethod': 'Auto-deduct',
      'animals': 'N/A',
      'location': 'Platform Service',
      'duration': 'N/A',
      'notes': 'Monthly platform service fee.',
      'invoiceNumber': 'FEE-2023-002',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Completed', 'Pending', 'This Month', 'Last Month'];

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TransactionDetailsModal(transaction: transaction),
    );
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') return _allTransactions;
    if (_selectedFilter == 'Completed') {
      return _allTransactions.where((t) => t['status'] == 'Completed').toList();
    }
    if (_selectedFilter == 'Pending') {
      return _allTransactions.where((t) => t['status'] == 'Pending').toList();
    }
    if (_selectedFilter == 'This Month') {
      return _allTransactions.where((t) => t['date'].contains('Dec')).toList();
    }
    if (_selectedFilter == 'Last Month') {
      // For demo purposes, assume some are from November
      return _allTransactions.where((t) => t['id'] == 'TXN-001' || t['id'] == 'TXN-002').toList();
    }
    return _allTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Export functionality
              _exportTransactions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: Colors.green.shade100,
                      checkmarkColor: Colors.green,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter ? Colors.green.shade800 : Colors.grey.shade700,
                        fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Summary Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Transactions',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_filteredTransactions.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${_filteredTransactions.fold<double>(0, (sum, t) => sum + t['amount']).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                return _TransactionCard(
                  transaction: transaction,
                  onTap: () => _showTransactionDetails(transaction),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _exportTransactions() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export feature coming soon!'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                  color: transaction['isCredit'] ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  transaction['isCredit'] ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 18,
                  color: transaction['isCredit'] ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transaction['farmerName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${transaction['isCredit'] ? '+' : '-'}\$${transaction['amount'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: transaction['isCredit'] ? Colors.green : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['service'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${transaction['date']} • ${transaction['time']}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: transaction['status'] == 'Completed'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction['status'],
                            style: TextStyle(
                              color: transaction['status'] == 'Completed' ? Colors.green : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionDetailsModal extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsModal({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Draggable handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transaction Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Amount and Status
                        Card(
                          color: transaction['isCredit']
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '${transaction['isCredit'] ? '+' : '-'}\$${transaction['amount'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: transaction['isCredit']
                                        ? Colors.green.shade800
                                        : Colors.orange.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: transaction['status'] == 'Completed'
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    transaction['status'],
                                    style: TextStyle(
                                      color: transaction['status'] == 'Completed'
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Details Grid
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              icon: Icons.person,
                              label: 'Farmer',
                              value:
                              '${transaction['farmerName']} (ID: ${transaction['farmerId']})',
                            ),
                            _DetailRow(
                              icon: Icons.medical_services,
                              label: 'Service',
                              value: transaction['service'],
                            ),
                            _DetailRow(
                              icon: Icons.category,
                              label: 'Service Type',
                              value: transaction['serviceType'],
                            ),
                            _DetailRow(
                              icon: Icons.pets,
                              label: 'Animals',
                              value: transaction['animals'],
                            ),
                            _DetailRow(
                              icon: Icons.location_on,
                              label: 'Location',
                              value: transaction['location'],
                            ),
                            _DetailRow(
                              icon: Icons.access_time,
                              label: 'Visit Duration',
                              value: transaction['duration'],
                            ),
                            _DetailRow(
                              icon: Icons.date_range,
                              label: 'Date & Time',
                              value:
                              '${transaction['date']} at ${transaction['time']}',
                            ),
                            _DetailRow(
                              icon: Icons.payment,
                              label: 'Payment Method',
                              value: transaction['paymentMethod'],
                            ),
                            _DetailRow(
                              icon: Icons.receipt,
                              label: 'Invoice Number',
                              value: transaction['invoiceNumber'],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              transaction['notes'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Share functionality
                                  _shareTransaction(context);
                                },
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // View invoice functionality
                                  _viewInvoice(context);
                                },
                                icon: const Icon(Icons.receipt_long),
                                label: const Text('View Invoice'),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.green.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Add extra padding at the bottom for better scrolling
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareTransaction(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing transaction details...'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _viewInvoice(BuildContext context) {
    // TODO: Implement view invoice functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening invoice...'),
        backgroundColor: Colors.green.shade600,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}