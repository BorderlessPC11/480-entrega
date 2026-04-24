import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../domain/order.dart';
import '../../map/presentation/widgets/route_map_panel.dart';
import '../../map/services/geocoding_service.dart';
import 'route_screen.dart';
import 'widgets/address_card.dart';
import 'widgets/info_row.dart';
import 'widgets/status_pill.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    super.key,
    required this.order,
    /// Se preenchido, é acionado antes de abrir a rota (ex.: vincular entregador no Firestore).
    this.onBeforeStartRoute,
    this.vistaAdmin = false,
  });

  final Order order;
  final Future<void> Function()? onBeforeStartRoute;
  /// Quando a OS é aberta a partir do fluxo de admin (criação / acompanhamento).
  final bool vistaAdmin;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _geocoding = GeocodingService();

  LatLng? _destination;
  bool _geocodingLoading = true;
  String? _geocodingError;

  @override
  void initState() {
    super.initState();
    _resolveDestination();
  }

  Future<void> _resolveDestination() async {
    final o = widget.order;
    if (o.destLat != null && o.destLng != null) {
      if (!mounted) return;
      setState(() {
        _destination = LatLng(o.destLat!, o.destLng!);
        _geocodingLoading = false;
        _geocodingError = null;
      });
      return;
    }
    setState(() {
      _geocodingLoading = true;
      _geocodingError = null;
    });

    final address = '${o.addressLine1}, ${o.addressLine2}, São Paulo, SP';
    try {
      final res = await _geocoding.geocodeAddress(address);
      if (!mounted) return;
      setState(() {
        _destination = res.latLng;
        _geocodingError = res.error;
        _geocodingLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _destination = null;
        _geocodingError = 'Falha ao geocodificar endereço.';
        _geocodingLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final order = widget.order;
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
                child: Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: _TopSummary(order: order),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
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
                        // Space for the collapsed map sheet.
                        const SliverToBoxAdapter(child: SizedBox(height: 340)),
                      ],
                    ),
                    Positioned(
                      left: 16,
                      top: 16,
                      child: IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: 'Voltar',
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 18,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _SmallChip(text: distance),
                          _SmallChip(text: eta),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _OrderMapBottomSheet(
                        destination: _destination,
                        title: order.customerName,
                        loading: _geocodingLoading,
                        error: _geocodingError,
                        onRetry: _resolveDestination,
                      ),
                    ),
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
                  onPressed: () async {
                    if (widget.onBeforeStartRoute != null) {
                      try {
                        await widget.onBeforeStartRoute!();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro: $e')),
                          );
                        }
                        return;
                      }
                    }
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RouteScreen(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.near_me_rounded),
                  label: Text(
                    widget.vistaAdmin
                        ? 'Abrir percurso'
                        : 'Aceitar e Iniciar Rota',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderMapBottomSheet extends StatelessWidget {
  const _OrderMapBottomSheet({
    required this.destination,
    required this.title,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final LatLng? destination;
  final String title;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (destination != null) {
      return RouteMapPanel(destination: destination!, title: title);
    }

    // Placeholder sheet while geocoding.
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.38,
      maxChildSize: 0.96,
      snap: true,
      snapSizes: const [0.38, 0.96],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Mapa',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (loading) ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                        Text(
                          'Buscando localização do destino…',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.78),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ] else if (error != null && error!.isNotEmpty) ...[
                        Text(
                          error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.error,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: onRetry,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

