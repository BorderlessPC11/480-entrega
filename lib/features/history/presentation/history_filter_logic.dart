import 'package:flutter/material.dart' show DateTimeRange;

import '../domain/history_item.dart';
import '../../drive_home/domain/order.dart';

/// Aplica regras de filtro do histórico.
List<HistoryItem> applyHistoryFilters({
  required List<HistoryItem> items,
  required bool onlyConcluidas,
  required Set<OrderCategory> selectedCategories,
  required DateTimeRange? dateRange,
}) {
  return items.where((e) {
    if (onlyConcluidas && e.outcome != HistoryOutcome.concluida) {
      return false;
    }
    if (selectedCategories.isNotEmpty && !selectedCategories.contains(e.category)) {
      return false;
    }
    if (dateRange != null && !_completedOnInRange(e.completedAt, dateRange)) {
      return false;
    }
    return true;
  }).toList();
}

int _dateKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

bool _completedOnInRange(DateTime completed, DateTimeRange range) {
  final c = _dateKey(completed);
  final a = _dateKey(
    DateTime(range.start.year, range.start.month, range.start.day),
  );
  final b = _dateKey(
    DateTime(range.end.year, range.end.month, range.end.day),
  );
  return c >= a && c <= b;
}

String formatDateRangeLabel(DateTimeRange range) {
  String p(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  return '${p(range.start)} – ${p(range.end)}';
}
