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
            "✅ Legal Disclaimer",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "The quoted prices are based on prevailing market rates at the time of preparation. \n\n"
                "Disclaimer on Farm Performance & Financial Projections The information provided herein is for educational and "
                "planning purposes only and is based on assumed averages and historical industry data. Actual poultry production,"
                " feed consumption, costs, and profitability may vary significantly due to management practices, disease outbreaks,"
                " climate conditions, input quality, mortality, and market volatility. No warranty or guarantee is made regarding "
                "expected outcomes. Users are responsible for making independent management decisions and maintaining accurate farm records. "
                "The platform and its partners shall not be held liable for losses arising from the use of this information",
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
