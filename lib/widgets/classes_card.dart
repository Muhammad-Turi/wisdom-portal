import 'package:flutter/material.dart';

class ClassesCard extends StatelessWidget {
  final String label;
  final String studentCount;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ClassesCard({
    super.key,
    required this.label,
    required this.studentCount,
    required this.onTap,
    required this.onDelete,
    required this.icon,
    this.iconColor = const Color(0xFF00897B),
    this.iconBackgroundColor = const Color(0xFFE0F2F1),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.house_outlined, size: 30, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            studentCount,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.folder,
                    size: 18,
                    color: Colors.indigo,
                  ),
                  label: const Text(
                    "Open Details",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_forever, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
