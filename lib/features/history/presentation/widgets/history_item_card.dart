import 'package:flutter/material.dart';

import '../../../drive_home/domain/order.dart';
import '../../domain/history_item.dart';
import 'history_formatters.dart';

class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final HistoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final cat = _categoryPill(item.category, cs);
    final out = _outcomePill(item.outcome, cs);

    return Card(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MiniPill(
                            label: cat.$3,
                            icon: cat.$4,
                            backgroundColor: cat.$1,
                            foregroundColor: cat.$2,
                          ),
                          Text(
                            item.id,
                            style: t.textTheme.labelLarge?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _MiniPill(
                            label: out.$3,
                            icon: out.$4,
                            backgroundColor: out.$1,
                            foregroundColor: out.$2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _AddressLine(
                        icon: Icons.location_on_outlined,
                        text: item.addressLine1,
                      ),
                      const SizedBox(height: 4),
                      _AddressLine(
                        icon: Icons.place_outlined,
                        text: item.addressLine2,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _Meta(
                            icon: Icons.event_available_rounded,
                            text: formatHistoryCompletedAt(item.completedAt),
                          ),
                          if (item.outcome == HistoryOutcome.concluida)
                            _Meta(
                              icon: Icons.timer_outlined,
                              text: '${item.durationMinutes} min',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.amountCents > 0)
                      Text(
                        item.amountBRL,
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF38D996),
                        ),
                      )
                    else
                      Text(
                        '—',
                        style: t.textTheme.titleSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: t.textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  const _AddressLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.86),
            ),
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: cs.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          text,
          style: t.textTheme.labelLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

(Color, Color, String, IconData) _categoryPill(
  OrderCategory c,
  ColorScheme cs,
) {
  return switch (c) {
    OrderCategory.condominio => (
        const Color(0xFF243BFF).withValues(alpha: 0.16),
        const Color(0xFF6D7CFF),
        'Condomínio',
        Icons.apartment_rounded,
      ),
    OrderCategory.cobranca => (
        const Color(0xFFFFB020).withValues(alpha: 0.16),
        const Color(0xFFFFC866),
        'Cobrança',
        Icons.request_quote_rounded,
      ),
    OrderCategory.recebimento => (
        const Color(0xFF30D7A9).withValues(alpha: 0.16),
        const Color(0xFF6EE8C6),
        'Recebimento',
        Icons.savings_rounded,
      ),
    OrderCategory.coleta => (
        const Color(0xFFFF6B6B).withValues(alpha: 0.14),
        const Color(0xFFFF8A8A),
        'Coleta',
        Icons.inventory_2_rounded,
      ),
    OrderCategory.entrega => (
        cs.primary.withValues(alpha: 0.16),
        cs.primary,
        'Entrega',
        Icons.local_shipping_rounded,
      ),
  };
}

(Color, Color, String, IconData) _outcomePill(
  HistoryOutcome o,
  ColorScheme cs,
) {
  return switch (o) {
    HistoryOutcome.concluida => (
        const Color(0xFF38D996).withValues(alpha: 0.16),
        const Color(0xFF57E0AD),
        'Concluída',
        Icons.check_rounded,
      ),
    HistoryOutcome.cancelada => (
        const Color(0xFFFF6B6B).withValues(alpha: 0.16),
        const Color(0xFFFF8A8A),
        'Cancelada',
        Icons.block_rounded,
      ),
    HistoryOutcome.reagendada => (
        const Color(0xFFFFA726).withValues(alpha: 0.16),
        const Color(0xFFFFB74D),
        'Reagendada',
        Icons.update_rounded,
      ),
  };
}
