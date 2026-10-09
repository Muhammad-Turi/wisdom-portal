import 'package:flutter/material.dart';
import 'app_color.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final IconData iconData;
  final Color iconBackgroundColor;
  final String number;
  final Color cardColor;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.label,
    required this.cardColor,
    required this.iconBackgroundColor,
    required this.iconData,
    required this.number,

    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 150,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(iconData, color: AppColor.navy),
                ),
                if (onTap != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
