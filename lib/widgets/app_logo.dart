import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';

/// Closed-eye smiley with a single sparkle, drawn from the SVG paths in
/// design/design.html. Uses the palette accent so it turns mint in dark mode.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 102, this.color});

  final double width;
  final Color? color;

  // Source viewBox is 552 x 702.
  static const _aspect = 702 / 552;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * _aspect),
      painter: _LogoPainter(color ?? context.palette.accent),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Map the SVG viewBox (-20, -190, 552, 702) onto the canvas.
    canvas.scale(size.width / 552);
    canvas.translate(20, 190);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 56
      ..strokeCap = StrokeCap.round;

    const eyeRadius = Radius.circular(68);
    final eyes = Path()
      ..moveTo(43, 100)
      ..arcToPoint(const Offset(179, 100), radius: eyeRadius)
      ..moveTo(333, 100)
      ..arcToPoint(const Offset(469, 100), radius: eyeRadius);
    canvas.drawPath(eyes, stroke);

    final smile = Path()
      ..moveTo(30, 328)
      ..arcToPoint(
        const Offset(482, 328),
        radius: const Radius.circular(244),
        clockwise: false,
      );
    canvas.drawPath(smile, stroke);

    final sparkle = Path()
      ..moveTo(440, -122)
      ..quadraticBezierTo(440, -62, 500, -62)
      ..quadraticBezierTo(440, -62, 440, -2)
      ..quadraticBezierTo(440, -62, 380, -62)
      ..quadraticBezierTo(440, -62, 440, -122)
      ..close();
    canvas.drawPath(sparkle, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => oldDelegate.color != color;
}
