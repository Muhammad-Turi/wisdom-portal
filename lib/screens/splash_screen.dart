import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'lib/assets/images/school_logo.png',
                        width: width < 600 ? width * 0.6 : 300,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Wisdom Portal',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color.fromARGB(255, 21, 30, 44),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Empowering Minds, Shaping Futures',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 0.8,
                          color: Color(0xFFD6A928),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
