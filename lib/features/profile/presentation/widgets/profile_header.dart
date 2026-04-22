import 'package:flutter/material.dart';

import 'rating_row.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.initials,
    this.photoUrl,
    required this.rating,
    required this.reviewCount,
    required this.onSettingsTap,
    required this.onEditTap,
  });

  final String name;
  final String initials;
  /// Foto de perfil (ex.: Google); se nula, mostra iniciais.
  final String? photoUrl;
  final double rating;
  final int reviewCount;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.98 + (value * 0.02),
            child: child,
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.9),
                      cs.tertiary.withValues(alpha: 0.8),
                    ],
                  ),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
                ),
                clipBehavior: Clip.antiAlias,
                child: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? Image.network(
                        photoUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            initials,
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initials,
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          onPressed: onSettingsTap,
                          icon: const Icon(Icons.settings_rounded),
                          tooltip: 'Configurações',
                        ),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                          onPressed: onEditTap,
                          icon: const Icon(Icons.edit_rounded),
                          tooltip: 'Editar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RatingRow(rating: rating, reviewCount: reviewCount),
                    const SizedBox(height: 10),
                    Text(
                      'Motorista parceiro',
                      style: t.textTheme.labelLarge?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

