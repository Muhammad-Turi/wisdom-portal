import 'package:flutter/material.dart';
import 'app_color.dart';

class ClassCard extends StatelessWidget {
  final String label;
  final IconData iconData;
  final Color iconBackgroundColor;
  final String number;
  final Color cardColor;

  const ClassCard({
    super.key,
    required this.label,
    required this.cardColor,
    required this.iconBackgroundColor,
    required this.iconData,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 470,
      height: 115,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: AppColor.navy),
              ),
              SizedBox(width: 7),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }
}
