import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_history.dart';
import 'widgets/history_formatters.dart';
import 'widgets/history_item_card.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final items = mockHistoryItems();
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
                          '${items.length} OS encerradas (demonstração)',
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
