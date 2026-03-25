import 'package:flutter/material.dart';

class RatingRow extends StatelessWidget {
  const RatingRow({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final starColor = const Color(0xFFFFC866);

    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              i < fullStars
                  ? Icons.star_rounded
                  : (i == fullStars && hasHalf)
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: 18,
              color: i < fullStars || (i == fullStars && hasHalf)
                  ? starColor
                  : cs.onSurface.withValues(alpha: 0.35),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: t.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($reviewCount)',
          style: t.textTheme.labelMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

