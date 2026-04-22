import '../../domain/history_item.dart';

String sectionLabelForHistory(DateTime completed, DateTime now) {
  final cd = DateTime(completed.year, completed.month, completed.day);
  final nd = DateTime(now.year, now.month, now.day);
  final diff = nd.difference(cd).inDays;
  if (diff == 0) return 'Hoje';
  if (diff == 1) return 'Ontem';
  if (diff >= 2 && diff < 7) return 'Esta semana';
  if (diff >= 7 && diff < 14) return 'Semana passada';
  if (completed.year == now.year && completed.month == now.month) {
    return 'Este mês';
  }
  return 'Anteriores';
}

String formatHistoryCompletedAt(DateTime d) {
  const months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out',
    'nov', 'dez',
  ];
  return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]}. · '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}

/// Agrupa itens consecutivos com o mesmo [sectionLabelForHistory] (lista já
/// deve estar ordenada do mais recente para o mais antigo).
List<({String label, List<HistoryItem> items})> groupHistoryForSections(
  List<HistoryItem> items,
  DateTime now,
) {
  if (items.isEmpty) return [];
  final sorted = [...items]..sort(
        (a, b) => b.completedAt.compareTo(a.completedAt),
      );
  final out = <({String label, List<HistoryItem> items})>[];
  for (final item in sorted) {
    final label = sectionLabelForHistory(item.completedAt, now);
    if (out.isEmpty || out.last.label != label) {
      out.add((label: label, items: [item]));
    } else {
      final last = out.removeLast();
      out.add((label: last.label, items: [...last.items, item]));
    }
  }
  return out;
}
