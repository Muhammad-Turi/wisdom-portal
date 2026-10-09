import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmScope extends StatelessWidget {
  final Widget child;
  const ExitConfirmScope({super.key, required this.child});

  Future<void> _askExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Exit app"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Exit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _askExit(context);
      },
      child: child,
    );
  }
}
