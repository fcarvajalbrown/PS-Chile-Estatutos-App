import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

/// A compact "DATOS CLAVE" table. Research shows numbers are grasped better in
/// tabular form than in prose, so quórums and sizes are surfaced this way.
class FactBoxWidget extends StatelessWidget {
  final FactBox box;
  const FactBoxWidget({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 2),
      decoration: BoxDecoration(
        color: PSColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PSColors.red.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: PSColors.red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'DATOS CLAVE · ${box.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < box.rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: i.isOdd ? PSColors.paper : PSColors.surface,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      box.rows[i].$1,
                      style: const TextStyle(fontSize: 14, color: PSColors.ink),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    box.rows[i].$2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: PSColors.redDark,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
