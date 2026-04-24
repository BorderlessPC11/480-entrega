import '../../drive_home/domain/order.dart';

/// Estatísticas de um entregador com base em ordens concluídas e atribuídas a [uid].
class EntregadorOrderStats {
  const EntregadorOrderStats({
    required this.corridasConcluidas,
    required this.totalPlataformaCents,
  });

  final int corridasConcluidas;
  final int totalPlataformaCents;

  static EntregadorOrderStats forUid(List<Order> all, String uid) {
    var corridas = 0;
    var cents = 0;
    for (final o in all) {
      if (o.status != OrderStatus.concluido) continue;
      if (o.assignedTo != uid) continue;
      corridas += 1;
      cents += o.amountCents;
    }
    return EntregadorOrderStats(
      corridasConcluidas: corridas,
      totalPlataformaCents: cents,
    );
  }
}
