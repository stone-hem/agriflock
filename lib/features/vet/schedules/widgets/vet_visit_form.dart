import 'package:flutter/material.dart';

class VetVisitFormPage extends StatefulWidget {
  const VetVisitFormPage({super.key});

  @override
  State<VetVisitFormPage> createState() => _VetVisitFormPageState();
}

class _VetVisitFormPageState extends State<VetVisitFormPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // ── Shared form state ──────────────────────
  // A. Visit Type
  String _visitType = 'General';

  // B. Farmer Complaints
  final Map<String, bool> _complaints = {
    'Reduced feed intake': false,
    'Reduced water intake': false,
    'Sudden mortality': false,
    'Poor growth': false,
    'Diarrhea': false,
    'Respiratory signs': false,
    'Lameness': false,
    'Egg drop (layers)': false,
    'Other': false,
  };

  // C. Extension Officer Observations
  final Map<String, String> _observations = {
    'Bird behavior': 'Normal',
    'Droppings': 'Normal',
    'Body condition': 'Normal',
    'Feed quality': 'Normal',
    'Water cleanliness': 'Normal',
    'Housing hygiene': 'Normal',
  };
  final TextEditingController _abnormalFindings = TextEditingController();

  // D. Suspected Issue
  final Map<String, bool> _suspectedIssues = {
    'Management related': false,
    'Nutrition related': false,
    'Disease suspected': false,
    'Environmental stress': false,
    'Biosecurity lapse': false,
  };

  // E. Actions Taken
  final Map<String, bool> _actions = {
    'Farmer training provided': false,
    'Management corrections done': false,
    'Medication advised': false,
    'Vet escalation required': false,
    'Follow-up visit scheduled': false,
  };

  // F. Recommendations & Signature
  final TextEditingController _rec1 = TextEditingController();
  final TextEditingController _rec2 = TextEditingController();
  bool _farmerConfirmed = false;

  static const List<_StepMeta> _steps = [
    _StepMeta(icon: Icons.medical_services_outlined, label: 'Visit Type'),
    _StepMeta(icon: Icons.report_problem_outlined, label: 'Complaints'),
    _StepMeta(icon: Icons.visibility_outlined, label: 'Observations'),
    _StepMeta(icon: Icons.search, label: 'Suspected Issue'),
    _StepMeta(icon: Icons.check_circle_outline, label: 'Actions Taken'),
    _StepMeta(icon: Icons.rate_review_outlined, label: 'Sign-off'),
  ];

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentIndex < _steps.length - 1) _goTo(_currentIndex + 1);
  }

  void _back() {
    if (_currentIndex > 0) _goTo(_currentIndex - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _abnormalFindings.dispose();
    _rec1.dispose();
    _rec2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Vet Visit Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ── Step header ──────────────────────────────
          _StepHeader(
            steps: _steps,
            currentIndex: _currentIndex,
            onStepTapped: _goTo,
          ),

          // ── Page content ─────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentIndex = i),
              children: [
                _PageA(
                  visitType: _visitType,
                  onChanged: (v) => setState(() => _visitType = v!),
                ),
                _PageB(
                  complaints: _complaints,
                  onChanged: (k, v) => setState(() => _complaints[k] = v),
                ),
                _PageC(
                  observations: _observations,
                  abnormalFindings: _abnormalFindings,
                  onChanged: (k, v) => setState(() => _observations[k] = v),
                ),
                _PageD(
                  issues: _suspectedIssues,
                  onChanged: (k, v) => setState(() => _suspectedIssues[k] = v),
                ),
                _PageE(
                  actions: _actions,
                  onChanged: (k, v) => setState(() => _actions[k] = v),
                ),
                _PageF(
                  rec1: _rec1,
                  rec2: _rec2,
                  confirmed: _farmerConfirmed,
                  onConfirm: (v) => setState(() => _farmerConfirmed = v!),
                  onSubmit: _submit,
                ),
              ],
            ),
          ),

          // ── Navigation footer ────────────────────────
          _NavFooter(
            currentIndex: _currentIndex,
            total: _steps.length,
            onBack: _back,
            onNext: _next,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final data = {
      'visitType': _visitType,
      'complaints':
      _complaints.entries.where((e) => e.value).map((e) => e.key).toList(),
      'observations': _observations,
      'abnormalFindings': _abnormalFindings.text,
      'suspectedIssues': _suspectedIssues.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
      'actions':
      _actions.entries.where((e) => e.value).map((e) => e.key).toList(),
      'rec1': _rec1.text,
      'rec2': _rec2.text,
      'farmerConfirmed': _farmerConfirmed,
    };
    debugPrint('Form Data: $data');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Visit record submitted successfully'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STEP HEADER  (replaces bottom nav)
// ─────────────────────────────────────────────

class _StepMeta {
  final IconData icon;
  final String label;
  const _StepMeta({required this.icon, required this.label});
}

class _StepHeader extends StatelessWidget {
  final List<_StepMeta> steps;
  final int currentIndex;
  final ValueChanged<int> onStepTapped;

  const _StepHeader({
    required this.steps,
    required this.currentIndex,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title + count
          Row(
            children: [
              Icon(steps[currentIndex].icon, size: 16),
              const SizedBox(width: 6),
              Text(
                'Step ${currentIndex + 1} of ${steps.length}  ·  ${steps[currentIndex].label}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Dot stepper
          Row(
            children: List.generate(steps.length, (i) {
              final done = i < currentIndex;
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onStepTapped(i),
                  child: Row(
                    children: [
                      // Dot
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: active ? 28 : 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: active
                              ? Theme.of(context).primaryColor
                              : done
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check,
                              size: 11, color: Colors.white)
                              : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: active
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // Connector line (except last)
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i < currentIndex
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAV FOOTER  (Back / Next buttons)
// ─────────────────────────────────────────────

class _NavFooter extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _NavFooter({
    required this.currentIndex,
    required this.total,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentIndex == 0;
    final isLast = currentIndex == total - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back button
            if (!isFirst)
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            const Spacer(),
            // Next button (hidden on last page — submit is inside _PageF)
            if (!isLast)
              ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Next',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REUSABLE HELPERS
// ─────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _FormSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFF2E7D32), thickness: 1.5),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

Widget _checkCard(String label, bool value, ValueChanged<bool> onChanged) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(
          color: value ? const Color(0xFF2E7D32) : Colors.grey.shade200),
    ),
    color: value ? const Color(0xFFE8F5E9) : Colors.white,
    child: CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v!),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: value ? FontWeight.w600 : FontWeight.normal,
          color: value ? const Color(0xFF1B5E20) : Colors.black87,
        ),
      ),
      activeColor: const Color(0xFF2E7D32),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

Widget _toggleRow(String label, String value, ValueChanged<String> onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child:
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Normal', label: Text('Normal')),
              ButtonSegment(value: 'Abnormal', label: Text('Abnormal')),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: value == 'Abnormal'
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFE8F5E9),
              selectedForegroundColor: value == 'Abnormal'
                  ? const Color(0xFFC62828)
                  : const Color(0xFF1B5E20),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
//  SECTION PAGES  (unchanged logic)
// ─────────────────────────────────────────────

class _PageA extends StatelessWidget {
  final String visitType;
  final ValueChanged<String?> onChanged;
  const _PageA({required this.visitType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: 'A. Visit Type',
      child: Column(
        children: ['General', 'Emergency', 'Follow-up'].map((type) {
          final selected = visitType == type;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade200,
                width: selected ? 2 : 1,
              ),
            ),
            color: selected ? const Color(0xFFE8F5E9) : Colors.white,
            child: RadioListTile<String>(
              value: type,
              groupValue: visitType,
              onChanged: onChanged,
              title: Text(
                type,
                style: TextStyle(
                  fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
                  color:
                  selected ? const Color(0xFF1B5E20) : Colors.black87,
                ),
              ),
              activeColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PageB extends StatelessWidget {
  final Map<String, bool> complaints;
  final Function(String, bool) onChanged;
  const _PageB({required this.complaints, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: 'B. Farmer Complaints',
      child: Column(
        children: complaints.keys
            .map((k) => _checkCard(k, complaints[k]!, (v) => onChanged(k, v)))
            .toList(),
      ),
    );
  }
}

class _PageC extends StatelessWidget {
  final Map<String, String> observations;
  final TextEditingController abnormalFindings;
  final Function(String, String) onChanged;
  const _PageC({
    required this.observations,
    required this.abnormalFindings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: 'C. Extension Officer Observations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...observations.keys
              .map((k) => _toggleRow(k, observations[k]!, (v) => onChanged(k, v))),
          const SizedBox(height: 10),
          const Text('Abnormal Findings',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: abnormalFindings,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Describe any abnormal findings…',
            ),
          ),
        ],
      ),
    );
  }
}

class _PageD extends StatelessWidget {
  final Map<String, bool> issues;
  final Function(String, bool) onChanged;
  const _PageD({required this.issues, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: 'D. Suspected Issue',
      child: Column(
        children: issues.keys
            .map((k) => _checkCard(k, issues[k]!, (v) => onChanged(k, v)))
            .toList(),
      ),
    );
  }
}

class _PageE extends StatelessWidget {
  final Map<String, bool> actions;
  final Function(String, bool) onChanged;
  const _PageE({required this.actions, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: 'E. Actions Taken',
      child: Column(
        children: actions.keys
            .map((k) => _checkCard(k, actions[k]!, (v) => onChanged(k, v)))
            .toList(),
      ),
    );
  }
}

class _PageF extends StatelessWidget {
  final TextEditingController rec1, rec2;
  final bool confirmed;
  final ValueChanged<bool?> onConfirm;
  final VoidCallback onSubmit;

  const _PageF({
    required this.rec1,
    required this.rec2,
    required this.confirmed,
    required this.onConfirm,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      title: 'F. Recommendations & Sign-off',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommendations',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
              controller: rec1,
              decoration:
              const InputDecoration(labelText: 'Recommendation 1')),
          const SizedBox(height: 12),
          TextField(
              controller: rec2,
              decoration:
              const InputDecoration(labelText: 'Recommendation 2')),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // Digital Signature Placeholder
          // Container(
          //   width: double.infinity,
          //   height: 120,
          //   decoration: BoxDecoration(
          //     border: Border.all(color: Colors.grey.shade300),
          //     borderRadius: BorderRadius.circular(10),
          //     color: Colors.grey.shade50,
          //   ),
          //   child: const Center(
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Icon(Icons.draw_outlined, size: 36, color: Colors.grey),
          //         SizedBox(height: 6),
          //         Text('Vet Digital Signature',
          //             style: TextStyle(color: Colors.grey)),
          //         Text('(Tap to sign)',
          //             style: TextStyle(fontSize: 11, color: Colors.grey)),
          //       ],
          //     ),
          //   ),
          // ),

          const SizedBox(height: 20),

          // Farmer Confirmation
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: confirmed
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade200,
                width: confirmed ? 2 : 1,
              ),
            ),
            color: confirmed ? const Color(0xFFE8F5E9) : Colors.white,
            child: CheckboxListTile(
              value: confirmed,
              onChanged: onConfirm,
              title: const Text('Vet Confirmation',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text(
                  'I confirm that I visited the farm and the above information is accurate.'),
              activeColor: const Color(0xFF2E7D32),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded),
              label: const Text('Submit Repert',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: confirmed ? onSubmit : null,
            ),
          ),
          if (!confirmed)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Farmer confirmation required to submit.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}