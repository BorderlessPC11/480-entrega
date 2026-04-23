import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/user/user_role.dart';
import '../../drive_home/domain/order.dart';
import '../domain/history_item.dart';
import '../../orders/data/orders_repository.dart';
import 'history_filter_logic.dart';
import 'widgets/history_formatters.dart';
import 'widgets/history_item_card.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({
    super.key,
    required this.allOrders,
    required this.userId,
    required this.userRole,
  });

  final List<Order> allOrders;
  final String userId;
  final UserRole userRole;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  bool _onlyConcluidas = false;
  final Set<OrderCategory> _categoryChips = {};
  DateTimeRange? _dateRange;

  bool get _hasActiveFilters =>
      _onlyConcluidas || _categoryChips.isNotEmpty || _dateRange != null;

  void _clearFilters() {
    setState(() {
      _onlyConcluidas = false;
      _categoryChips.clear();
      _dateRange = null;
    });
  }

  void _pickDateRange() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1, 1, 1);
    final last = DateTime(now.year, now.month, now.day);
    final initial = _dateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: last,
        );
    final next = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange: initial,
      currentDate: now,
    );
    if (next != null && mounted) {
      setState(() => _dateRange = next);
    }
  }

  void _toggleCategory(OrderCategory c) {
    setState(() {
      if (_categoryChips.contains(c)) {
        _categoryChips.remove(c);
      } else {
        _categoryChips.add(c);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final forHistory = OrdersRepository().filterHistoryForUser(
      widget.allOrders,
      widget.userId,
      widget.userRole,
    );
    final allItems =
        forHistory.map<HistoryItem>((o) => HistoryItem.fromOrder(o)).toList();
    final items = applyHistoryFilters(
      items: allItems,
      onlyConcluidas: _onlyConcluidas,
      selectedCategories: _categoryChips,
      dateRange: _dateRange,
    );
    final now = DateTime.now();
    final grouped = groupHistoryForSections(items, now);
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = math.min(constraints.maxWidth, 520.0);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico',
                          style: t.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _hasActiveFilters
                              ? '${items.length} de ${allItems.length} OS encerradas'
                              : '${allItems.length} OS encerradas (demonstração)',
                          style: t.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.78),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Filtros',
                              style: t.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface.withValues(alpha: 0.7),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _HistoryFilterChip(
                                    label: 'Concluídas',
                                    icon: Icons.check_circle_outline_rounded,
                                    selected: _onlyConcluidas,
                                    onSelected: (v) =>
                                        setState(() => _onlyConcluidas = v),
                                    colorScheme: cs,
                                    primaryIconColor: null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _HistoryFilterChip(
                                    label: 'Entregas',
                                    icon: Icons.local_shipping_rounded,
                                    selected: _categoryChips
                                        .contains(OrderCategory.entrega),
                                    onSelected: (_) => _toggleCategory(
                                      OrderCategory.entrega,
                                    ),
                                    colorScheme: cs,
                                    primaryIconColor: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _HistoryFilterChip(
                                    label: 'Cobrança',
                                    icon: Icons.request_quote_rounded,
                                    selected: _categoryChips
                                        .contains(OrderCategory.cobranca),
                                    onSelected: (_) => _toggleCategory(
                                      OrderCategory.cobranca,
                                    ),
                                    colorScheme: cs,
                                    primaryIconColor: null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _HistoryFilterChip(
                                    label: 'Coleta',
                                    icon: Icons.inventory_2_rounded,
                                    selected: _categoryChips
                                        .contains(OrderCategory.coleta),
                                    onSelected: (_) => _toggleCategory(
                                      OrderCategory.coleta,
                                    ),
                                    colorScheme: cs,
                                    primaryIconColor: null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Data',
                              style: t.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface.withValues(alpha: 0.7),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickDateRange,
                                    icon: const Icon(
                                      Icons.date_range_rounded,
                                      size: 20,
                                    ),
                                    label: Text(
                                      _dateRange == null
                                          ? 'Filtrar por data'
                                          : formatDateRangeLabel(_dateRange!),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      alignment: Alignment.centerLeft,
                                    ),
                                  ),
                                ),
                                if (_dateRange != null) ...[
                                  const SizedBox(width: 4),
                                  IconButton(
                                    tooltip: 'Remover data',
                                    onPressed: () =>
                                        setState(() => _dateRange = null),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _hasActiveFilters
                                    ? _clearFilters
                                    : null,
                                child: const Text('Limpar filtros'),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Nenhum tipo marcado: todas as categorias (incl. recebimento, condomínio).',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.5),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_alt_off_rounded,
                              size: 48,
                              color: cs.onSurface.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma OS com esses filtros',
                              textAlign: TextAlign.center,
                              style: t.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajuste os filtros ou limpe para ver tudo de novo.',
                              textAlign: TextAlign.center,
                              style: t.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonal(
                              onPressed: _clearFilters,
                              child: const Text('Limpar filtros'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var gi = 0; gi < grouped.length; gi++) ...[
                            _SectionTitle(
                              title: grouped[gi].label,
                              topPadding: gi == 0 ? 0 : 16,
                            ),
                            const SizedBox(height: 10),
                            for (final item in grouped[gi].items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HistoryItemCard(
                                  item: item,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'OS ${item.id} — detalhes em breve',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
    required this.colorScheme,
    this.primaryIconColor,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final ColorScheme colorScheme;
  final Color? primaryIconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        showCheckmark: false,
        avatar: Icon(
          icon,
          size: 18,
          color: primaryIconColor ?? colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.topPadding = 16,
  });

  final String title;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              color: cs.primary.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
