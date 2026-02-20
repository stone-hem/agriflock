import 'package:agriflock360/features/auth/shared/auth_text_field.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:flutter/material.dart';

class FarmerBirdTypeStep extends StatefulWidget {
  final TextEditingController houseCapacityController;
  final FocusNode houseCapacityFocus;
  final String? selectedBirdTypeId;
  final ValueChanged<String> onBirdTypeSelected;

  const FarmerBirdTypeStep({
    super.key,
    required this.houseCapacityController,
    required this.houseCapacityFocus,
    required this.selectedBirdTypeId,
    required this.onBirdTypeSelected,
  });

  @override
  State<FarmerBirdTypeStep> createState() => _FarmerBirdTypeStepState();
}

class _FarmerBirdTypeStepState extends State<FarmerBirdTypeStep> {
  final BatchHouseRepository _repo = BatchHouseRepository();

  List<BirdType> _birdTypes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBirdTypes();
  }

  Future<void> _fetchBirdTypes() async {
    final result = await _repo.getBirdTypes();
    result.when(
      success: (types) {
        if (mounted) {
          setState(() {
            _birdTypes = types;
            _isLoading = false;
          });
        }
      },
      failure: (message, response, statusCode) {
        if (mounted) {
          setState(() {
            _errorMessage = message;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Poultry Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about the birds you keep and your house capacity',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 32),

          // ── Bird type cards ─────────────────────────────────────────────
          const Text(
            'Main Bird Type',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          _buildBirdTypeSection(),

          const SizedBox(height: 28),

          // ── House capacity ──────────────────────────────────────────────
          AuthTextField(
            labelText: 'Chicken House Capacity',
            hintText: 'Maximum number of birds your house holds',
            icon: Icons.home_work_outlined,
            keyboardType: TextInputType.number,
            controller: widget.houseCapacityController,
            focusNode: widget.houseCapacityFocus,
            value: '',
          ),
          const SizedBox(height: 24),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 0),
        ],
      ),
    );
  }

  Widget _buildBirdTypeSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchBirdTypes();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_birdTypes.isEmpty) {
      return const Center(
        child: Text(
          'No bird types available',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemCount: _birdTypes.length,
      itemBuilder: (context, index) {
        final birdType = _birdTypes[index];
        final isSelected = widget.selectedBirdTypeId == birdType.id;
        return GestureDetector(
          onTap: () => widget.onBirdTypeSelected(birdType.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.egg_outlined,
                  size: 18,
                  color: isSelected ? Colors.green.shade700 : Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    birdType.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.green.shade800 : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
              ],
            ),
          ),
        );
      },
    );
  }
}
