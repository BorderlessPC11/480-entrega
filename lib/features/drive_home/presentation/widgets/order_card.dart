import 'package:flutter/material.dart';

import '../../domain/order.dart';
import 'status_pill.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final (pillBg, pillFg, pillText, pillIcon) = _categoryPill(order, cs);
    final (statusBg, statusFg, statusText, statusIcon) = _statusPill(order, cs);

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
                          StatusPill(
                            label: pillText,
                            backgroundColor: pillBg,
                            foregroundColor: pillFg,
                            icon: pillIcon,
                          ),
                          Text(
                            order.id,
                            style: t.textTheme.labelLarge?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          StatusPill(
                            label: statusText,
                            backgroundColor: statusBg,
                            foregroundColor: statusFg,
                            icon: statusIcon,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.primaryLabel,
                        style: t.textTheme.labelMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AddressLine(
                        icon: Icons.location_on_outlined,
                        text: order.addressLine1,
                      ),
                      const SizedBox(height: 6),
                      _AddressLine(
                        icon: Icons.place_outlined,
                        text: order.addressLine2,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _Meta(
                            icon: Icons.schedule,
                            text: order.etaMinutes == 0
                                ? 'Agora'
                                : '${order.etaMinutes} min',
                          ),
                          _Meta(
                            icon: Icons.route_outlined,
                            text:
                                '${order.distanceKm.toStringAsFixed(1)} km',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.amountBRL,
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _amountColor(order, cs),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.onSurface.withValues(alpha: 0.6),
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

  Color _amountColor(Order order, ColorScheme cs) {
    return switch (order.status) {
      OrderStatus.atrasado => const Color(0xFFFF6B6B),
      OrderStatus.concluido => const Color(0xFF38D996),
      _ => cs.onSurface,
    };
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
              color: cs.onSurface.withValues(alpha: 0.88),
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

(Color bg, Color fg, String text, IconData icon) _categoryPill(
  Order order,
  ColorScheme cs,
) {
  return switch (order.category) {
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

(Color bg, Color fg, String text, IconData icon) _statusPill(
  Order order,
  ColorScheme cs,
) {
  return switch (order.status) {
    OrderStatus.disponivel => (
        cs.surfaceContainerHighest.withValues(alpha: 0.85),
        cs.onSurface.withValues(alpha: 0.8),
        'Disponível',
        Icons.circle_outlined,
      ),
    OrderStatus.emRota => (
        const Color(0xFF2F8CFF).withValues(alpha: 0.18),
        const Color(0xFF5AA7FF),
        'Em rota',
        Icons.navigation_rounded,
      ),
    OrderStatus.atrasado => (
        const Color(0xFFFF6B6B).withValues(alpha: 0.16),
        const Color(0xFFFF8A8A),
        'Atrasado',
        Icons.error_outline_rounded,
      ),
    OrderStatus.concluido => (
        const Color(0xFF38D996).withValues(alpha: 0.16),
        const Color(0xFF57E0AD),
        'Concluído',
        Icons.check_circle_outline_rounded,
      ),
  };
}

