import 'package:flutter/material.dart';

class VetTermsDialog extends StatefulWidget {
  final Function(bool accepted) onTermsResponse;
  final bool showDeclineButton;

  const VetTermsDialog({
    super.key,
    required this.onTermsResponse,
    this.showDeclineButton = true,
  });

  @override
  State<VetTermsDialog> createState() => _VetTermsDialogState();
}

class _VetTermsDialogState extends State<VetTermsDialog> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.gavel,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Extension Officer Terms & Code of Conduct',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade200),
                ),
                child: const Text(
                  'Please note: This is required for all extension officers using AgriFlock 360',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms Content
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTermSection(
                        title: '1. Role Definition',
                        content: 'Extension officers using AgriFlock 360 are independent professionals who offer poultry advisory, vaccination, and technical services to farmers through the AgriFlock 360 platform. AgriFlock 360 is a technology marketplace and does not employ extension officers.',
                      ),
                      _buildTermSection(
                        title: '2. Eligibility & Onboarding Requirements',
                        content: '- Must be an active poultry extension officer (government, NGO, private, or cooperative)\n- Must own a smartphone capable of running the AgriFlock 360 app\n- Must provide accurate personal and professional information\n- Must complete basic onboarding and module activation',
                      ),
                      _buildTermSection(
                        title: '3. Professional Conduct',
                        content: '- Act ethically and professionally at all times\n- Provide accurate, science-based advice\n- Do not misrepresent qualifications\n- Respect farmers\' property, birds, and privacy',
                      ),
                      _buildTermSection(
                        title: '4. Service Delivery Standards',
                        content: '- Confirm flock details before service\n- Use approved vaccines and methods\n- Record all services accurately in the app\n- Follow poultry welfare and biosecurity standards',
                      ),
                      _buildTermSection(
                        title: '5. Payments & Earnings',
                        content: '- Extension officers set or agree on service price within platform guidelines\n- Officers earn 80% per completed job\n- AgriFlock 360 earns 20% as platform commission\n- Payments must be mobile money (logged in-app)',
                      ),
                      _buildTermSection(
                        title: '6. Ratings & Accountability',
                        content: '- Farmers rate services after completion\n- Consistently low ratings may result in reduced visibility, suspension, or removal\n- False reporting or malpractice leads to immediate suspension',
                      ),
                      _buildTermSection(
                        title: '7. Non-Exclusivity',
                        content: 'Extension officers are free to work outside AgriFlock 360. However, all services conducted via the platform must be logged for transparency and accountability.',
                      ),
                      _buildTermSection(
                        title: '8. Liability Disclaimer',
                        content: 'AgriFlock 360 is not responsible for the quality of physical services delivered. Extension officers are solely responsible for services provided, subject to platform monitoring.',
                      ),
                      _buildTermSection(
                        title: '9. Termination',
                        content: 'AgriFlock 360 reserves the right to suspend or terminate access for violations of these terms or unethical conduct.',
                      ),
                      _buildTermSection(
                        title: '10. Agreement',
                        content: 'By activating the Extension Module, the officer agrees to abide by these Terms & Code of Conduct.',
                      ),
                      const SizedBox(height: 20),
                      _buildAcceptanceCheckbox(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  if (widget.showDeclineButton) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => widget.onTermsResponse(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Decline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acceptedTerms
                          ? () => widget.onTermsResponse(true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildTermSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'I have read and agree to the Terms & Code of Conduct',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}