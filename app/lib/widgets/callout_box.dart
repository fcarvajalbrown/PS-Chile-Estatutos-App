import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

/// A "For Dummies"-style boxed aside: an icon + label + short text, color-coded
/// by type. Used in the reader to break up dense article text.
class CalloutBox extends StatelessWidget {
  final Callout callout;
  const CalloutBox({super.key, required this.callout});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(callout.type);
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 2),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: style.color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(style.icon, size: 18, color: style.color),
              const SizedBox(width: 6),
              Text(
                callout.type.label.toUpperCase(),
                style: TextStyle(
                  color: style.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            callout.text,
            style: const TextStyle(fontSize: 14.5, height: 1.45, color: PSColors.ink),
          ),
        ],
      ),
    );
  }

  _CalloutStyle _styleFor(CalloutType t) {
    switch (t) {
      case CalloutType.sabias:
        return const _CalloutStyle(Icons.lightbulb_outline, PSColors.gold);
      case CalloutType.practica:
        return const _CalloutStyle(Icons.task_alt, PSColors.correct);
      case CalloutType.ojo:
        return const _CalloutStyle(Icons.warning_amber_rounded, PSColors.redBright);
      case CalloutType.recuerda:
        return const _CalloutStyle(Icons.push_pin_outlined, PSColors.redDark);
    }
  }
}

class _CalloutStyle {
  final IconData icon;
  final Color color;
  const _CalloutStyle(this.icon, this.color);
}
