import 'package:flutter/foundation.dart';

import '../../drive_home/domain/order.dart';

/// Resultado de uma OS já encerrada (histórico).
enum HistoryOutcome {
  concluida,
  cancelada,
  reagendada,
}

@immutable
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.category,
    required this.customerName,
    required this.addressLine1,
    required this.addressLine2,
    required this.amountCents,
    required this.completedAt,
    this.durationMinutes = 22,
    this.outcome = HistoryOutcome.concluida,
  });

  factory HistoryItem.fromOrder(Order o) {
    final oc = o.outcome ?? 'concluida';
    HistoryOutcome? parsed;
    for (final e in HistoryOutcome.values) {
      if (e.name == oc) {
        parsed = e;
        break;
      }
    }
    final outcome = parsed ?? HistoryOutcome.concluida;
    return HistoryItem(
      id: o.id,
      category: o.category,
      customerName: o.customerName,
      addressLine1: o.addressLine1,
      addressLine2: o.addressLine2,
      amountCents: o.amountCents,
      completedAt: o.completedAt ?? o.createdAt,
      durationMinutes: o.durationMinutes,
      outcome: outcome,
    );
  }

  final String id;
  final OrderCategory category;
  final String customerName;
  final String addressLine1;
  final String addressLine2;
  final int amountCents;
  final DateTime completedAt;
  final int durationMinutes;
  final HistoryOutcome outcome;

  String get amountBRL {
    final reais = amountCents / 100.0;
    final s = reais.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }
}
