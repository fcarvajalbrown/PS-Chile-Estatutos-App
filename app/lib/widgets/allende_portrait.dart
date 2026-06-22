import 'package:flutter/material.dart';
import '../theme.dart';

/// An original, stylized poster-style portrait of Salvador Allende, drawn
/// entirely in code (no photograph). It evokes his signature heavy-framed
/// glasses and combed-back hair in the Socialist Party palette. Intended to be
/// used as a circular medallion on the home screen.
class AllendePortrait extends StatelessWidget {
  final double size;
  const AllendePortrait({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Container(
          color: PSColors.paper,
          child: CustomPaint(painter: _AllendePainter()),
        ),
      ),
    );
  }
}

class _AllendePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);

    final faceFill = Paint()..color = PSColors.red;
    final hairFill = Paint()..color = PSColors.redDark;
    final ink = Paint()..color = PSColors.ink;
    final lens = Paint()..color = PSColors.paper;

    // Shoulders / bust as a wide rounded shape rising from the bottom.
    final bust = Path()
      ..moveTo(w * 0.06, h)
      ..quadraticBezierTo(w * 0.10, h * 0.78, w * 0.28, h * 0.72)
      ..quadraticBezierTo(w * 0.40, h * 0.68, w * 0.50, h * 0.68)
      ..quadraticBezierTo(w * 0.60, h * 0.68, w * 0.72, h * 0.72)
      ..quadraticBezierTo(w * 0.90, h * 0.78, w * 0.94, h)
      ..close();
    canvas.drawPath(bust, faceFill);

    // Neck.
    canvas.drawRect(
      Rect.fromLTRB(w * 0.42, h * 0.60, w * 0.58, h * 0.74),
      faceFill,
    );

    // Head.
    final head = Rect.fromCenter(
      center: p(0.50, 0.42),
      width: w * 0.42,
      height: h * 0.50,
    );
    canvas.drawOval(head, faceFill);

    // Ears.
    canvas.drawOval(
      Rect.fromCenter(center: p(0.30, 0.44), width: w * 0.07, height: h * 0.11),
      faceFill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(0.70, 0.44), width: w * 0.07, height: h * 0.11),
      faceFill,
    );

    // Combed-back hair: a cap over the top of the head, swept to one side.
    final hair = Path()
      ..moveTo(w * 0.29, h * 0.40)
      ..quadraticBezierTo(w * 0.27, h * 0.16, w * 0.52, h * 0.16)
      ..quadraticBezierTo(w * 0.74, h * 0.17, w * 0.72, h * 0.34)
      ..quadraticBezierTo(w * 0.66, h * 0.26, w * 0.52, h * 0.27)
      ..quadraticBezierTo(w * 0.37, h * 0.28, w * 0.34, h * 0.40)
      ..close();
    canvas.drawPath(hair, hairFill);

    // Signature heavy-framed glasses.
    final frame = Paint()
      ..color = PSColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    final lensRRectL = RRect.fromRectAndRadius(
      Rect.fromCenter(center: p(0.385, 0.45), width: w * 0.20, height: h * 0.16),
      Radius.circular(w * 0.05),
    );
    final lensRRectR = RRect.fromRectAndRadius(
      Rect.fromCenter(center: p(0.615, 0.45), width: w * 0.20, height: h * 0.16),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(lensRRectL, lens);
    canvas.drawRRect(lensRRectR, lens);
    canvas.drawRRect(lensRRectL, frame);
    canvas.drawRRect(lensRRectR, frame);
    // Bridge.
    canvas.drawLine(p(0.485, 0.45), p(0.515, 0.45), frame);
    // Temples to the ears.
    canvas.drawLine(p(0.285, 0.44), p(0.30, 0.45), frame);
    canvas.drawLine(p(0.70, 0.45), p(0.715, 0.44), frame);

    // Eyes (small) behind the lenses.
    canvas.drawCircle(p(0.385, 0.45), w * 0.018, ink);
    canvas.drawCircle(p(0.615, 0.45), w * 0.018, ink);

    // Mouth line.
    final mouth = Paint()
      ..color = PSColors.redDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.44, 0.585), p(0.56, 0.585), mouth);

    // White collar + a hint of red tie.
    final collar = Paint()..color = PSColors.paper;
    final collarPath = Path()
      ..moveTo(w * 0.50, h * 0.72)
      ..lineTo(w * 0.40, h * 0.80)
      ..lineTo(w * 0.44, h * 0.86)
      ..lineTo(w * 0.50, h * 0.78)
      ..lineTo(w * 0.56, h * 0.86)
      ..lineTo(w * 0.60, h * 0.80)
      ..close();
    canvas.drawPath(collarPath, collar);
    final tie = Path()
      ..moveTo(w * 0.50, h * 0.78)
      ..lineTo(w * 0.465, h)
      ..lineTo(w * 0.535, h)
      ..close();
    canvas.drawPath(tie, Paint()..color = PSColors.redBright);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
