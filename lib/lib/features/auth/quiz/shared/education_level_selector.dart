import 'package:flutter/material.dart';

class EducationLevelSelector extends StatefulWidget {
  final String? selectedEducationLevel;
  final ValueChanged<String> onEducationLevelSelected;

  const EducationLevelSelector({
    super.key,
    required this.selectedEducationLevel,
    required this.onEducationLevelSelected,
  });

  @override
  State<EducationLevelSelector> createState() => _EducationLevelSelectorState();
}

class _EducationLevelSelectorState extends State<EducationLevelSelector> {
  static const Color primaryGreen = Color(0xFF2E7D32);

  // List of education levels
  final List<String> educationLevels = [
    'Diploma',
    'Bachelors Degree',
    'Masters Degree',
    'Doctorate',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with required indicator
        const Row(
          children: [
            Text(
              'Highest Level of Education *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Description
        const Text(
          'Select your highest level of educational qualification',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // Radio buttons list
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            color: Colors.white,
          ),
          child: Column(
            children: educationLevels.map((level) {
              final isSelected = widget.selectedEducationLevel == level;

              return Column(
                children: [
                  // Radio tile
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? primaryGreen : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? primaryGreen : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      level,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? primaryGreen : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      widget.onEducationLevelSelected(level);
                    },
                  ),

                  // Divider (except for last item)
                  if (level != educationLevels.last)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),

        // Validation message (if needed)
        if (widget.selectedEducationLevel == null) ...[
          const SizedBox(height: 8),
          Text(
            'Please select your education level',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ],
    );
  }
}