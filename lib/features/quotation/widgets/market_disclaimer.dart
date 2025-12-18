import 'package:flutter/material.dart';

class MarketDisclaimerWidget extends StatelessWidget {
  const MarketDisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Market Disclaimer",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "The quoted prices are based on prevailing market rates at the time of preparation. "
                "A market fluctuation margin of up to 15% has been included to accommodate possible "
                "variations in housing construction costs, production inputs, materials, labor, "
                "transportation, and other related expenses.\n\n"
                "Final costs may vary depending on actual market conditions at the time of execution. "
                "Any significant variation beyond this margin will be communicated prior to implementation. "
                "This quotation is indicative and does not represent a fixed-price commitment.",
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
