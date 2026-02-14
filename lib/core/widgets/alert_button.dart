import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlertsButton extends StatelessWidget {
  final int alertCount;

  const AlertsButton({super.key, this.alertCount = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The main button
        Container(
          decoration: BoxDecoration(
            color: alertCount > 0
                ? Colors.red.shade600.withOpacity(0.12)
                : Colors.grey.shade700.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: alertCount > 0
                  ? Colors.red.shade400.withOpacity(0.55)
                  : Colors.grey.shade400.withOpacity(0.4),
              width: 1.2,
            ),
          ),
          child: IconButton(
            iconSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: alertCount > 0
                      ? Colors.red.shade600
                      : Colors.grey.shade700,
                  size: 18,
                ),
                Text(
                  'Check alerts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: alertCount > 0
                        ? Colors.red.shade600
                        : Colors.grey.shade700,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ),

        // Badge — only shown when alertCount > 0
        if (alertCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: alertCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius:
                alertCount > 9 ? BorderRadius.circular(9) : null,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade300.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                alertCount > 99 ? '99+' : '$alertCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}