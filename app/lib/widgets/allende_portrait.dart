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
    final hairFill = Paint()..color = PSColors.ink;
    final ink = Paint()..color = PSColors.ink;
    final lens = Paint()..color = PSColors.paper;

    // Suit / shoulders rising from the bottom.
    final suit = Paint()..color = PSColors.redDark;
    final bust = Path()
      ..moveTo(w * 0.02, h)
      ..quadraticBezierTo(w * 0.08, h * 0.80, w * 0.30, h * 0.74)
      ..quadraticBezierTo(w * 0.42, h * 0.70, w * 0.50, h * 0.70)
      ..quadraticBezierTo(w * 0.58, h * 0.70, w * 0.70, h * 0.74)
      ..quadraticBezierTo(w * 0.92, h * 0.80, w * 0.98, h)
      ..close();
    canvas.drawPath(bust, suit);

    // Neck.
    canvas.drawRect(
      Rect.fromLTRB(w * 0.43, h * 0.60, w * 0.57, h * 0.76),
      faceFill,
    );

    // Ears.
    canvas.drawOval(
      Rect.fromCenter(center: p(0.31, 0.46), width: w * 0.07, height: h * 0.12),
      faceFill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: p(0.69, 0.46), width: w * 0.07, height: h * 0.12),
      faceFill,
    );

    // Head: a slightly longer oval, jaw a touch narrower.
    final head = Rect.fromCenter(
      center: p(0.50, 0.44),
      width: w * 0.44,
      height: h * 0.54,
    );
    canvas.drawOval(head, faceFill);

    // Hair: high forehead (receding), volume on the sides and swept across the
    // top toward the left, evoking Allende's combed-back look.
    final hair = Path()
      // left sideburn / side mass
      ..moveTo(w * 0.28, h * 0.52)
      ..quadraticBezierTo(w * 0.25, h * 0.30, w * 0.36, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.14, w * 0.66, h * 0.20)
      ..quadraticBezierTo(w * 0.75, h * 0.24, w * 0.74, h * 0.40)
      // underside of the swept fringe, leaving the forehead bare
      ..quadraticBezierTo(w * 0.70, h * 0.30, w * 0.56, h * 0.30)
      ..quadraticBezierTo(w * 0.44, h * 0.31, w * 0.40, h * 0.40)
      ..quadraticBezierTo(w * 0.36, h * 0.30, w * 0.33, h * 0.40)
      ..close();
    canvas.drawPath(hair, hairFill);

    // Signature heavy black rectangular glasses.
    final frame = Paint()
      ..color = PSColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final lensRRectL = RRect.fromRectAndRadius(
      Rect.fromCenter(center: p(0.375, 0.47), width: w * 0.22, height: h * 0.17),
      Radius.circular(w * 0.04),
    );
    final lensRRectR = RRect.fromRectAndRadius(
      Rect.fromCenter(center: p(0.625, 0.47), width: w * 0.22, height: h * 0.17),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(lensRRectL, lens);
    canvas.drawRRect(lensRRectR, lens);
    canvas.drawRRect(lensRRectL, frame);
    canvas.drawRRect(lensRRectR, frame);
    // Bridge.
    canvas.drawLine(p(0.485, 0.45), p(0.515, 0.45), frame);
    // Temples toward the ears.
    canvas.drawLine(p(0.265, 0.45), p(0.285, 0.46), frame);
    canvas.drawLine(p(0.715, 0.46), p(0.735, 0.45), frame);

    // Eyes behind the lenses.
    canvas.drawCircle(p(0.375, 0.47), w * 0.020, ink);
    canvas.drawCircle(p(0.625, 0.47), w * 0.020, ink);

    // Brow hint above the glasses.
    final brow = Paint()
      ..color = PSColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.32, 0.385), p(0.45, 0.375), brow);
    canvas.drawLine(p(0.55, 0.375), p(0.68, 0.385), brow);

    // Mouth line.
    final mouth = Paint()
      ..color = PSColors.redDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.44, 0.60), p(0.56, 0.60), mouth);

    // White shirt collar with a red tie.
    final collar = Paint()..color = PSColors.paper;
    final collarPath = Path()
      ..moveTo(w * 0.50, h * 0.73)
      ..lineTo(w * 0.40, h * 0.81)
      ..lineTo(w * 0.45, h * 0.88)
      ..lineTo(w * 0.50, h * 0.79)
      ..lineTo(w * 0.55, h * 0.88)
      ..lineTo(w * 0.60, h * 0.81)
      ..close();
    canvas.drawPath(collarPath, collar);
    final tie = Path()
      ..moveTo(w * 0.50, h * 0.79)
      ..lineTo(w * 0.47, h * 0.84)
      ..lineTo(w * 0.455, h)
      ..lineTo(w * 0.545, h)
      ..lineTo(w * 0.53, h * 0.84)
      ..close();
    canvas.drawPath(tie, Paint()..color = PSColors.redBright);

    // Thin badge ring around the medallion.
    final ring = Paint()
      ..color = PSColors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;
    canvas.drawCircle(p(0.5, 0.5), w * 0.475, ring);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
