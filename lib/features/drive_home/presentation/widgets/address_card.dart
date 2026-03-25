import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.title,
    required this.distanceText,
    required this.line1,
    required this.line2,
    required this.icon,
  });

  final String title;
  final String distanceText;
  final String line1;
  final String line2;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(icon, size: 18, color: cs.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: cs.onSurface.withValues(alpha: 0.82),
                    ),
                  ),
                ),
                Text(
                  distanceText,
                  style: t.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              line1,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              line2,
              style: t.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.76),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

