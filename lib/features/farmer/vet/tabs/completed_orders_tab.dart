import 'package:flutter/material.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_order.dart';

class CompletedOrdersTab extends StatefulWidget {
  final List<VetOrder> vetOrders;
  final Function(VetOrder) onOrderUpdated;

  const CompletedOrdersTab({
    super.key,
    required this.vetOrders,
    required this.onOrderUpdated,
  });

  @override
  State<CompletedOrdersTab> createState() => _CompletedOrdersTabState();
}

class _CompletedOrdersTabState extends State<CompletedOrdersTab> {
  final now = DateTime.now();

  late final List<VetOrder> _vetOrders = [
    VetOrder(
      id: 'ORD001',
      vetId: '1',
      vetName: 'Dr. Sarah Johnson',
      serviceType: 'Vaccination Service',
      priority: 'Normal',
      scheduledDate: now.add(const Duration(days: 1)),
      scheduledTime: const TimeOfDay(hour: 10, minute: 30),
      status: OrderStatus.confirmed,
      totalCost: 12500,
      consultationFee: 5000,
      serviceFee: 3500,
      mileageFee: 1200,
      prioritySurcharge: 0,
      houseName: 'Main Poultry House',
      batchName: 'Batch 123 - Broilers',
      reason: 'Annual vaccination program',
      notes: 'Please bring avian flu vaccines',
      vetLocation: VetLocation(
        latitude: -1.286389,
        longitude: 36.817223,
        address: '123 Farm Road, Agricultural Zone',
      ),
      farmerLocation: FarmerLocation(
        latitude: -1.2921,
        longitude: 36.8219,
        address: 'My Farm, Kiambu Road',
      ),
      estimatedArrivalTime: now.add(const Duration(hours: 25)),
      isPaid: true,
      userRating: 5,
      userComment: 'Noting',
    ),
    VetOrder(
      id: 'ORD002',
      vetId: '2',
      vetName: 'Dr. Michael Chen',
      serviceType: 'Emergency Visit',
      priority: 'Emergency',
      scheduledDate: now,
      scheduledTime: const TimeOfDay(hour: 14, minute: 0),
      status: OrderStatus.enRoute,
      totalCost: 18200,
      consultationFee: 5000,
      serviceFee: 8000,
      mileageFee: 1500,
      prioritySurcharge: 3700,
      houseName: 'Secondary Poultry House',
      batchName: 'Batch 124 - Layers',
      reason: 'Sudden mortality in layers',
      notes: 'Birds showing respiratory symptoms',
      vetLocation: VetLocation(
        latitude: -1.300000,
        longitude: 36.783333,
        address: '456 Poultry Lane, Farm District',
      ),
      farmerLocation: FarmerLocation(
        latitude: -1.2921,
        longitude: 36.8219,
        address: 'My Farm, Kiambu Road',
      ),
      estimatedArrivalTime: now.add(const Duration(minutes: 45)),
      isPaid: true,
      userRating: 3,
      userComment: '',
    ),
    VetOrder(
      id: 'ORD003',
      vetId: '3',
      vetName: 'Dr. Maria Rodriguez',
      serviceType: 'Routine Check-up',
      priority: 'Urgent',
      scheduledDate: now.add(const Duration(days: 3)),
      scheduledTime: const TimeOfDay(hour: 9, minute: 0),
      status: OrderStatus.pending,
      totalCost: 9600,
      consultationFee: 5000,
      serviceFee: 2000,
      mileageFee: 2000,
      prioritySurcharge: 600,
      houseName: 'Main Poultry House',
      batchName: 'Batch 125 - Broilers',
      reason: 'Monthly health check',
      notes: 'Focus on weight gain monitoring',
      vetLocation: VetLocation(
        latitude: -1.250000,
        longitude: 36.850000,
        address: '789 Ranch Street, Rural Area',
      ),
      farmerLocation: FarmerLocation(
        latitude: -1.2921,
        longitude: 36.8219,
        address: 'My Farm, Kiambu Road',
      ),
      estimatedArrivalTime: now.add(const Duration(days: 3, hours: 1)),
      isPaid: true,
      userRating: 5,
      userComment: 'yey',
    ),
    VetOrder(
      id: 'ORD004',
      vetId: '1',
      vetName: 'Dr. Sarah Johnson',
      serviceType: 'Consultation',
      priority: 'Normal',
      scheduledDate: now.subtract(const Duration(days: 5)),
      scheduledTime: const TimeOfDay(hour: 11, minute: 0),
      status: OrderStatus.completed,
      totalCost: 8500,
      consultationFee: 5000,
      serviceFee: 1500,
      mileageFee: 1200,
      prioritySurcharge: 0,
      houseName: 'Quarantine House',
      batchName: 'Batch 127 - Recovery',
      reason: 'Follow-up on treatment progress',
      notes: 'All birds recovered well',
      vetLocation: VetLocation(
        latitude: -1.286389,
        longitude: 36.817223,
        address: '123 Farm Road, Agricultural Zone',
      ),
      farmerLocation: FarmerLocation(
        latitude: -1.2921,
        longitude: 36.8219,
        address: 'My Farm, Kiambu Road',
      ),
      estimatedArrivalTime: now.subtract(const Duration(days: 5, hours: 1)),
      serviceCompletedDate: now.subtract(const Duration(days: 5)),
      isPaid: false,
      userRating: 0,
      userComment: '',
    ),
    VetOrder(
      id: 'ORD005',
      vetId: '2',
      vetName: 'Dr. Michael Chen',
      serviceType: 'Disease Diagnosis',
      priority: 'Urgent',
      scheduledDate: now.subtract(const Duration(days: 2)),
      scheduledTime: const TimeOfDay(hour: 15, minute: 30),
      status: OrderStatus.completed,
      totalCost: 11200,
      consultationFee: 5000,
      serviceFee: 3500,
      mileageFee: 1500,
      prioritySurcharge: 1200,
      houseName: 'Main Poultry House',
      batchName: 'Batch 128 - Layers',
      reason: 'Suspected Newcastle disease',
      notes: 'Samples collected for lab testing',
      vetLocation: VetLocation(
        latitude: -1.300000,
        longitude: 36.783333,
        address: '456 Poultry Lane, Farm District',
      ),
      farmerLocation: FarmerLocation(
        latitude: -1.2921,
        longitude: 36.8219,
        address: 'My Farm, Kiambu Road',
      ),
      estimatedArrivalTime: now.subtract(const Duration(days: 2, hours: 2)),
      serviceCompletedDate: now.subtract(const Duration(days: 2)),
      isPaid: true,
      userRating: 5,
      userComment: 'Excellent service! Quick diagnosis and helpful advice.',
    ),
    VetOrder(
      id: 'ORD006',
      vetId: '3',
      vetName: 'Dr. Maria Rodriguez',
      serviceType: 'Preventive Medicine',
      priority: 'Normal',
      scheduledDate: now.subtract(const Duration(days: 7)),
      scheduledTime: const TimeOfDay(hour: 13, minute: 0),
      status: OrderStatus.completed,
      totalCost: 9700,
      consultationFee: 5000,
      serviceFee: 2000,
      mileageFee: 2000,
      prioritySurcharge: 700,
      houseName: 'Secondary Poultry House',
      batchName: 'Batch 129 - Broilers',
      reason: 'Seasonal preventive treatment',
      notes: 'Applied deworming and vitamin supplements',
      vetLocation: VetLocation(
        latitude: -1.250000,
        longitude: 36.850000,
        address: '789 Ranch Street, Rural Area',
      ),
      farmerLocation: FarmerLocation(
        latitude: -1.2921,
        longitude: 36.8219,
        address: 'My Farm, Kiambu Road',
      ),
      estimatedArrivalTime: now.subtract(const Duration(days: 7, hours: 1)),
      serviceCompletedDate: now.subtract(const Duration(days: 7)),
      isPaid: true,
      userRating: 4,
      userComment: 'Good service but a bit late for the appointment.',
    ),
  ];
  List<VetOrder> get completedOrders => _vetOrders
      .where((order) => order.status == OrderStatus.completed)
      .toList();

  void _showPaymentDialog(VetOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vet: ${order.vetName}'),
            Text('Service: ${order.serviceType}'),
            const SizedBox(height: 16),
            Text(
              'Total Amount:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            Text(
              '\$${(order.totalCost / 100).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildFeeBreakdown(order),
            const SizedBox(height: 16),
            const Text(
              'Select Payment Method:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodItem(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              subtitle: 'Pay with Visa, MasterCard, or Amex',
            ),
            _buildPaymentMethodItem(
              icon: Icons.mobile_friendly,
              title: 'Mobile Money',
              subtitle: 'M-Pesa, Airtel Money, etc.',
            ),
            _buildPaymentMethodItem(
              icon: Icons.account_balance,
              title: 'Bank Transfer',
              subtitle: 'Direct bank transfer',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _processPayment(order);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(VetOrder order) {
    double rating = order.userRating.toDouble();
    final commentController = TextEditingController(text: order.userComment);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Rate Your Experience'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.vetName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    order.serviceType,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'How would you rate this service?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            rating = (index + 1).toDouble();
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          size: 30,
                          color: index < rating
                              ? Colors.amber
                              : Colors.grey.shade400,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    rating == 0
                        ? 'Tap a star to rate'
                        : '${rating.toStringAsFixed(1)} Stars',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: rating == 0 ? Colors.grey : Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Comment
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Additional Comments (Optional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your feedback helps improve our service and helps other farmers.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: rating == 0
                    ? null
                    : () {
                        _submitRating(order, rating, commentController.text);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Submit Rating'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: () {},
      ),
    );
  }

  Widget _buildFeeBreakdown(VetOrder order) {
    return Column(
      children: [
        _buildFeeItem('Consultation Fee', order.consultationFee),
        _buildFeeItem('Service Fee', order.serviceFee),
        _buildFeeItem('Mileage Fee', order.mileageFee),
        if (order.prioritySurcharge > 0)
          _buildFeeItem('Priority Surcharge', order.prioritySurcharge),
        const Divider(),
        _buildFeeItem('Total', order.totalCost, isTotal: true),
      ],
    );
  }

  Widget _buildFeeItem(String label, int amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${(amount / 100).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(VetOrder order) {
    // Simulate payment processing
    final updatedOrder = order.copyWith(isPaid: true);
    widget.onOrderUpdated(updatedOrder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment of \$${(order.totalCost / 100).toStringAsFixed(2)} completed!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _submitRating(VetOrder order, double rating, String comment) {
    final updatedOrder = order.copyWith(
      userRating: rating.toInt(),
      userComment: comment,
    );
    widget.onOrderUpdated(updatedOrder);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildOrderCard(VetOrder order) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.vetName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        order.serviceType,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Completed Date
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completed on ${order.serviceCompletedDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // House & Batch
            Row(
              children: [
                Icon(Icons.home_work, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${order.houseName} • ${order.batchName}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cost
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total Cost: \$${(order.totalCost / 100).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating Display (if rated)
            if (order.userRating > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${order.userRating}.0',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          order.userComment.isNotEmpty
                              ? order.userComment
                              : 'No comment provided',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontStyle: order.userComment.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            // Action Buttons
            const SizedBox(height: 16),
            Row(
              children: [
                if (!order.isPaid)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showPaymentDialog(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, size: 18),
                          SizedBox(width: 8),
                          Text('Pay Now'),
                        ],
                      ),
                    ),
                  ),
                if (!order.isPaid && order.userRating == 0)
                  const SizedBox(width: 12),
                if (order.userRating == 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showRatingDialog(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 18),
                          SizedBox(width: 8),
                          Text('Rate Service'),
                        ],
                      ),
                    ),
                  ),
                if (order.isPaid && order.userRating > 0)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Completed & Rated',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.amber.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Completed Services',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review completed veterinary services, make payments, and rate your experience',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: completedOrders.length.toString(),
                  label: 'Total Services',
                  icon: Icons.medical_services,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: completedOrders
                      .where((o) => o.isPaid)
                      .length
                      .toString(),
                  label: 'Paid',
                  icon: Icons.payment,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: completedOrders
                      .where((o) => o.userRating > 0)
                      .length
                      .toString(),
                  label: 'Rated',
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Needs Payment'),
                  selected: false,
                  onSelected: (selected) {},
                  backgroundColor: Colors.red.shade50,
                  selectedColor: Colors.red,
                  labelStyle: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Needs Rating'),
                  selected: false,
                  onSelected: (selected) {},
                  backgroundColor: Colors.amber.shade50,
                  selectedColor: Colors.amber,
                  labelStyle: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Paid & Rated'),
                  selected: false,
                  onSelected: (selected) {},
                  backgroundColor: Colors.green.shade50,
                  selectedColor: Colors.green,
                  labelStyle: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Recent'),
                  selected: false,
                  onSelected: (selected) {},
                  backgroundColor: Colors.blue.shade50,
                  selectedColor: Colors.blue,
                  labelStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Orders List
          Text(
            'Completed Orders',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${completedOrders.length} service${completedOrders.length == 1 ? '' : 's'} completed',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),

          if (completedOrders.isEmpty)
            _buildEmptyState()
          else
            ...completedOrders.map(_buildOrderCard),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Completed Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed veterinary services will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
