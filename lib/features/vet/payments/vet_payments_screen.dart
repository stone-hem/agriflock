import 'package:agriflock/core/utils/format_util.dart';
import 'package:agriflock/core/widgets/alert_button.dart';
import 'package:agriflock/features/vet/payments/models/vet_pending_payment.dart';
import 'package:agriflock/features/vet/schedules/repo/visit_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String _fmtAmt(double v) => FormatUtil.formatAmount(v);

String _fmtDt(DateTime dt) {
  const m = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
}

class VetPaymentsScreen extends StatefulWidget {
  const VetPaymentsScreen({super.key});

  @override
  State<VetPaymentsScreen> createState() => _VetPaymentsScreenState();
}

class _VetPaymentsScreenState extends State<VetPaymentsScreen> {
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
            const Text('My Payments'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: AlertsButton(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverview(),
                        const SizedBox(height: 24),
                        if (_summary!.overdueCount > 0) ...[
                          _buildOverdueAlert(),
                          const SizedBox(height: 24),
                        ],
                        _buildPendingSection(),
                        const SizedBox(height: 24),
                        _buildCompletedSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
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

  // ── Overview card ──────────────────────────────────────────────────────────

  Widget _buildOverview() {
    final acc = _summary!.account;
    final sym = acc.currencySymbol.isNotEmpty ? acc.currencySymbol : acc.currency;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade600, Colors.green.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This Month\'s Earnings',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '$sym ${_fmt(acc.totalEarningsThisMonth)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet,
                    size: 32, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: 'Last Month',
                  value: '$sym ${_fmt(acc.totalEarningsLastMonth)}',
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Total Remitted',
                  value: '$sym ${_fmt(acc.totalRemitted)}',
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Pending Remit',
                  value: '$sym ${_fmt(_summary!.pendingRemittance)}',
                  highlight: true,
                ),
              ),
            ],
          ),
          if (acc.lastRemittanceDate != null) ...[
            const SizedBox(height: 12),
            Text(
              'Last remittance: ${_fmtDate(acc.lastRemittanceDate!)}',
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  // ── Overdue alert ──────────────────────────────────────────────────────────

  Widget _buildOverdueAlert() {
    final acc = _summary!.account;
    final sym = acc.currencySymbol.isNotEmpty ? acc.currencySymbol : acc.currency;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_summary!.overdueCount} overdue payment${_summary!.overdueCount > 1 ? 's' : ''} — $sym ${_fmt(_summary!.overdueAmount)} outstanding',
              style: TextStyle(
                  color: Colors.red.shade800, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pending remittances ────────────────────────────────────────────────────

  Widget _buildPendingSection() {
    final pending = _summary!.pendingPayments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pending Remittances',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800)),
            if (pending.length > 2)
              TextButton(
                onPressed: () => context.push('/vet/payments/pending'),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          _emptyBanner(Icons.check_circle, Colors.green,
              'No pending remittances — you\'re all caught up!')
        else ...[
          ...pending.take(2).map((p) => _PendingCard(
                payment: p,
                currencySymbol: _summary!.account.currencySymbol,
                onRemit: () async {
                  await context.push('/vet/payment/remit', extra: p);
                  if (mounted) _load();
                },
              )),
          if (pending.length > 2)
            TextButton(
              onPressed: () => context.push('/vet/payments/pending'),
              child: Text('+ ${pending.length - 2} more pending'),
            ),
        ],
      ],
    );
  }

  // ── Completed transactions ─────────────────────────────────────────────────

  Widget _buildCompletedSection() {
    final completed = _summary!.completedPayments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800)),
            TextButton(
              onPressed: () => context.push('/vet/payments/history'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (completed.isEmpty)
          _emptyBanner(
              Icons.receipt_long, Colors.grey, 'No completed transactions yet')
        else
          ...completed.take(5).map((p) => _TransactionCard(
                payment: p,
                currencySymbol: _summary!.account.currencySymbol,
              )),
      ],
    );
  }

  Widget _emptyBanner(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style:
                    TextStyle(color: color.withOpacity(0.85), fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) => FormatUtil.formatAmount(v);

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ── Overview stat tile ─────────────────────────────────────────────────────

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _OverviewStat(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: highlight ? Colors.orange.shade200 : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ── Pending remittance card ────────────────────────────────────────────────

class _PendingCard extends StatelessWidget {
  final VetPendingPayment payment;
  final String currencySymbol;
  final VoidCallback onRemit;

  const _PendingCard(
      {required this.payment,
      required this.currencySymbol,
      required this.onRemit});

  @override
  Widget build(BuildContext context) {
    final isOverdue = payment.remittanceDueDate != null &&
        payment.remittanceDueDate!.isBefore(DateTime.now());
    final sym = currencySymbol.isNotEmpty ? currencySymbol : payment.currency;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isOverdue ? Colors.red.shade200 : Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.paymentNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Commission: $sym ${_fmtAmt(payment.platformCommission)}',
                  style: TextStyle(
                      color: isOverdue
                          ? Colors.red.shade700
                          : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                if (payment.remittanceDueDate != null)
                  Text(
                    '${isOverdue ? 'Overdue' : 'Due'}: ${_fmtDt(payment.remittanceDueDate!)}',
                    style: TextStyle(
                        fontSize: 12,
                        color: isOverdue
                            ? Colors.red.shade600
                            : Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onRemit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child:
                const Text('Remit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Completed transaction card ─────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final VetPendingPayment payment;
  final String currencySymbol;

  const _TransactionCard(
      {required this.payment, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final sym = currencySymbol.isNotEmpty ? currencySymbol : payment.currency;
    final date = payment.vetRemittedAt ?? payment.farmerPaidAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_downward,
                size: 18, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.paymentNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                if (payment.vetRemittanceMethod != null)
                  Text('via ${payment.vetRemittanceMethod}',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                if (date != null)
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 11, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(_fmtDt(date),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 11)),
                    ],
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+$sym ${_fmtAmt(payment.vetEarnings)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Remitted',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
