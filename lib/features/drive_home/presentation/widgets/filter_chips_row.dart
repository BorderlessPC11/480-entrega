import 'package:borderless_app/app/app_theme.dart';
import 'package:flutter/material.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.selectedId,
    required this.onSelected,
  });

  final List<FilterChipItem> filters;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppTheme.spaceMd),
        itemBuilder: (context, index) {
          final item = filters[index];
          final isSelected = item.id == selectedId;
          final bg = isSelected ? cs.primaryContainer : cs.surfaceContainer;
          final fg = isSelected ? cs.onPrimaryContainer : cs.onSurface;
          return AnimatedScale(
            duration: const Duration(milliseconds: 140),
            scale: isSelected ? 1.0 : 0.98,
            child: ActionChip(
              label: Text(item.label),
              avatar: item.icon == null
                  ? null
                  : Icon(
                      item.icon,
                      size: 18,
                      color: fg.withValues(alpha: 0.9),
                    ),
              onPressed: () => onSelected(item.id),
              backgroundColor: bg,
              labelStyle: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: fg, fontWeight: FontWeight.w700),
              side: BorderSide(color: cs.outline.withValues(alpha: 0.6)),
            ),
          );
        },
      ),
    );
  }
}

class FilterChipItem {
  const FilterChipItem({
    required this.id,
    required this.label,
    this.icon,
  });

  final String id;
  final String label;
  final IconData? icon;
}

