import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/farmer/vet/models/dispute_model.dart';
import 'package:agriflock/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';

// ignore_for_file: deprecated_member_use

class MyDisputesScreen extends StatefulWidget {
  const MyDisputesScreen({super.key});

  @override
  State<MyDisputesScreen> createState() => _MyDisputesScreenState();
}

class _MyDisputesScreenState extends State<MyDisputesScreen> {
  final _repo = VetFarmerRepository();

  List<DisputeModel> _disputes = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    final result = await _repo.getMyDisputes();
    if (!mounted) return;
    switch (result) {
      case Success<List<DisputeModel>>(data: final data):
        setState(() {
          _disputes = data;
          _isLoading = false;
        });
      case Failure<List<DisputeModel>>():
        setState(() {
          _error = result.message;
          _isLoading = false;
        });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'open':
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Disputes'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty && _disputes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 56, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text(_error,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 16),
                        OutlinedButton(
                            onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  )
                : _disputes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gavel_outlined,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('No disputes filed',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(
                              'Disputes you file on completed orders will appear here.',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _disputes.length,
                        itemBuilder: (context, index) =>
                            _DisputeCard(dispute: _disputes[index]),
                      ),
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final DisputeModel dispute;
  const _DisputeCard({required this.dispute});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'open':
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(dispute.status);
    final label = DisputeModel.statusLabel(dispute.status);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    DisputeModel.reasonLabel(dispute.reason),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(dispute.description,
                style:
                    TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('Order: ${dispute.orderId.substring(0, 8)}…',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
                const Spacer(),
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(dispute.createdAt.split('T')[0],
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
            if (dispute.resolutionNote != null &&
                dispute.resolutionNote!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resolution Note',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                    const SizedBox(height: 4),
                    Text(dispute.resolutionNote!,
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
