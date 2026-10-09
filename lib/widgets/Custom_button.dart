import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String? tooltip;
  final double iconSize;
  final Object? heroTag;

  const CustomButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.tooltip,
    this.iconSize = 13.0,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 110,
      child: FloatingActionButton(
        heroTag: heroTag ?? UniqueKey(),
        tooltip: tooltip,
        backgroundColor: Colors.orange.shade500,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: iconColor, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
