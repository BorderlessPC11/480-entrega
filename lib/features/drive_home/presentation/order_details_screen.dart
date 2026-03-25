import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/order.dart';
import 'route_screen.dart';
import 'widgets/address_card.dart';
import 'widgets/info_row.dart';
import 'widgets/status_pill.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final distance = '${order.distanceKm.toStringAsFixed(1)} km';
    final eta = order.etaMinutes == 0 ? 'Agora' : '${order.etaMinutes} min';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = math.min(constraints.maxWidth, 560.0);
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _MapHeader(
                        distanceText: distance,
                        etaText: eta,
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: _TopSummary(order: order),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AddressCard(
                          title: 'ENDEREÇO RESIDENCIAL',
                          distanceText: distance,
                          line1: order.addressLine1,
                          line2: 'Ref: Portão à direita / Sala 304',
                          icon: Icons.home_rounded,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: AddressCard(
                          title: 'ENDEREÇO COMERCIAL',
                          distanceText: distance,
                          line1: 'Av. Paulista, 1578 — Sala 304',
                          line2: 'Bela Vista — São Paulo, SP',
                          icon: Icons.business_rounded,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Text(
                          'O endereço residencial deve ser visitado primeiro. Se a confirmação '
                          'for negativa, o sistema irá coletar confirmação para seguir ao endereço comercial.',
                          style: t.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.72),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InfoRow(
                                  icon: Icons.call_rounded,
                                  title: '(11) *****-4321',
                                  subtitle: 'Contato preferencial do cliente',
                                ),
                                const SizedBox(height: 12),
                                const InfoRow(
                                  icon: Icons.schedule_rounded,
                                  title: 'Hoje, até 17:00',
                                  subtitle: 'Prazo estimado para conclusão',
                                ),
                                const SizedBox(height: 12),
                                const InfoRow(
                                  icon: Icons.assignment_turned_in_rounded,
                                  title:
                                      'Confirmar endereço residencial e comercial para cadastro de crédito',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 92)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remuneração',
                          style: t.textTheme.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.amountBRL,
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF38D996),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.payments_rounded,
                    color: cs.primary.withValues(alpha: 0.9),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RouteScreen(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.near_me_rounded),
                  label: const Text('Aceitar e Iniciar Rota'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.distanceText,
    required this.etaText,
    required this.onBack,
  });

  final String distanceText;
  final String etaText;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      height: 210,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.55)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.85),
            cs.surfaceContainer.withValues(alpha: 0.65),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: CustomPaint(painter: _GridPainter(color: cs.onSurface)),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: IconButton.filledTonal(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Voltar',
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Wrap(
              spacing: 8,
              children: [
                _SmallChip(text: distanceText),
                _SmallChip(text: etaText),
              ],
            ),
          ),
          Positioned(
            left: 14,
            bottom: 14,
            child: Text(
              'Prévia do mapa',
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _TopSummary extends StatelessWidget {
  const _TopSummary({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final (pillBg, pillFg, pillText, pillIcon) = _categoryPill(order);
    final (statusBg, statusFg, statusText, statusIcon) = _statusPill(order);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
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
                fontWeight: FontWeight.w800,
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
        const SizedBox(height: 10),
        Text(
          order.customerName,
          style: t.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '13:38 • ${DateTime.now().toString().substring(0, 10)}',
          style: t.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

(Color bg, Color fg, String text, IconData icon) _categoryPill(Order order) {
  final cs = const ColorScheme.dark();
  return switch (order.category) {
    OrderCategory.condominio => (
        const Color(0xFF243BFF).withValues(alpha: 0.16),
        const Color(0xFF6D7CFF),
        'Confirmação',
        Icons.verified_user_rounded,
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

(Color bg, Color fg, String text, IconData icon) _statusPill(Order order) {
  final cs = const ColorScheme.dark();
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

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    const step = 26.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

