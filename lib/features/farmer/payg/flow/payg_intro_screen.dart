import 'package:agriflock/app_routes.dart';
import 'package:agriflock/features/farmer/devices/models/device_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Intro screen shown when a farmer taps "Manage Device Lease" on a PAYG-locked device.
/// Explains the PAYG concept and guides them to make their monthly device payment.
class PaygIntroScreen extends StatelessWidget {
  final DeviceItem? device;

  const PaygIntroScreen({super.key, this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ── Hero Banner ──────────────────────────────────────────
          _buildHero(context),

          // ── Content ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device card (if coming from a specific device)
                  if (device != null) ...[
                    _buildDeviceCard(context),
                    const SizedBox(height: 20),
                  ],

                  _buildWhatIsPaygCard(),
                  const SizedBox(height: 16),
                  _buildHowItWorksCard(),
                  const SizedBox(height: 16),
                  if (device?.isPaygLocked == true)
                    _buildLockedWarningCard(),
                  const SizedBox(height: 28),
                  _buildCTA(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.devices_rounded,
                        size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device Lease (PAYG)',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pay As You Go — monthly device payments',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context) {
    final d = device!;
    final isLocked = d.isPaygLocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLocked
              ? Colors.orange.shade300
              : Colors.green.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLocked ? Colors.orange : Colors.green)
                .withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isLocked ? Colors.orange : Colors.green)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
              color: isLocked ? Colors.orange : Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.deviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  d.deviceImei,
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isLocked ? Colors.orange : Colors.green)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (isLocked ? Colors.orange : Colors.green)
                    .withOpacity(0.3),
              ),
            ),
            child: Text(
              isLocked ? 'Locked' : 'Active',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isLocked ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsPaygCard() {
    return _InfoCard(
      icon: Icons.info_outline_rounded,
      iconColor: Colors.blue,
      title: 'What is PAYG?',
      content:
          'Pay As You Go (PAYG) is a flexible device lease programme. Instead of buying devices outright, you pay a small monthly lease fee to keep your devices active and connected. '
          'Payments are due monthly and keep your sensor data streaming to AgriFlock 360.',
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timeline_rounded,
                    color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'How It Works',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StepItem(
            step: '1',
            color: Colors.blue,
            text: 'Your devices are assigned and activated when you first join.',
          ),
          const SizedBox(height: 10),
          _StepItem(
            step: '2',
            color: Colors.green,
            text:
                'A monthly lease invoice is generated for each device on your account.',
          ),
          const SizedBox(height: 10),
          _StepItem(
            step: '3',
            color: Colors.orange,
            text:
                'Pay before the due date via M-Pesa, card, or bank transfer to keep your devices unlocked.',
          ),
          const SizedBox(height: 10),
          _StepItem(
            step: '4',
            color: Colors.purple,
            text:
                'If payment is missed, devices enter a locked state — live data pauses until the balance is cleared.',
          ),
        ],
      ),
    );
  }

  Widget _buildLockedWarningCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade700, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Currently Locked',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Live data streaming is paused. Make a payment to restore full device functionality immediately.',
                  style: TextStyle(
                      fontSize: 13, color: Colors.orange.shade700, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.paygDashboard),
            icon: const Icon(Icons.dashboard_rounded, size: 20),
            label: const Text('Go to PAYG Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.paygPayment),
            icon: const Icon(Icons.payment_rounded, size: 20),
            label: const Text('Make a Payment Now'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1565C0),
              side: const BorderSide(color: Color(0xFF1565C0)),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
                fontSize: 13.5, color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String step;
  final Color color;
  final String text;

  const _StepItem({
    required this.step,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 13.5, color: Colors.grey[700], height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
