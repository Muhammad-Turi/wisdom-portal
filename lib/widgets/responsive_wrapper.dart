import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1300,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = _paddingFor(width);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),

            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: horizontalPadding,
              ),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        );
      },
    );
  }

  double _paddingFor(double width) {
    if (width < 600) return 16;
    if (width < 1024) return 24;

    return 40;
  }
}
