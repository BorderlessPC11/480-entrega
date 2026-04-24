import 'package:flutter/material.dart';

import 'package:borderless_app/app/app_theme.dart';
import 'package:borderless_app/core/user/user_role.dart';
import 'package:borderless_app/features/orders/data/orders_repository.dart';
import 'package:borderless_app/features/orders/domain/entregador_order_stats.dart';
import 'package:borderless_app/features/profile/data/user_profile_repository.dart';

import '../data/user_directory_entry.dart';

String _brlFromCents(int cents) {
  final reais = cents / 100.0;
  final s = reais.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $s';
}

/// Detalhe de um utilizador: dados do documento + estatísticas das ordens.
class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key, required this.entry});

  final UserDirectoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final ordersRepo = OrdersRepository();
    final profileRepo = UserProfileRepository();

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<Map<String, dynamic>>(
          stream: profileRepo.watchUserProfile(entry.uid),
          builder: (context, s) {
            final p = s.data;
            if (p != null) {
              final d = p['displayName'];
              if (d is String && d.trim().isNotEmpty) {
                return Text(d.trim());
              }
            }
            return Text(entry.nameOrFallback);
          },
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: profileRepo.watchUserProfile(entry.uid),
          initialData: const <String, dynamic>{},
            builder: (context, profSnap) {
            final p = profSnap.data ?? <String, dynamic>{};
            String nomeLinha = entry.nameOrFallback;
            final dn = p['displayName'];
            if (dn is String && dn.trim().isNotEmpty) {
              nomeLinha = dn.trim();
            }
            return StreamBuilder(
              stream: ordersRepo.watchOrders(),
              builder: (context, ordSnap) {
                if (ordSnap.hasError) {
                  return Center(
                    child: Text(
                      '${ordSnap.error}',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: cs.error,
                      ),
                    ),
                  );
                }
                if (!ordSnap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final orders = ordSnap.data!;
                final stats = EntregadorOrderStats.forUid(orders, entry.uid);
                final dispOverride = p['disponivelSaqueCents'];
                int? saqueCents;
                if (dispOverride is num) {
                  saqueCents = dispOverride.toInt();
                }
                saqueCents ??= entry.disponivelSaqueCents;
                final saqueVisual =
                    saqueCents ?? stats.totalPlataformaCents;
                return Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceLg,
                      AppTheme.spaceLg,
                      AppTheme.spaceLg,
                      AppTheme.listBottomWithNav,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: cs.primaryContainer,
                            foregroundColor: cs.onPrimaryContainer,
                            child: Text(
                              entry.initials,
                              style: t.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceLg),
                          Text(
                            'Dados',
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceSm),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spaceLg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _rowLabel(t, 'Nome', nomeLinha),
                                  const Divider(height: 20),
                                  _rowLabel(t, 'Email', entry.email),
                                  const Divider(height: 20),
                                  _rowLabel(
                                    t,
                                    'Telefone',
                                    () {
                                      final ph = p['phone'];
                                      if (ph is String) {
                                        final x = ph.trim();
                                        if (x.isNotEmpty) {
                                          return x;
                                        }
                                      }
                                      return 'Não informado';
                                    }(),
                                  ),
                                  const Divider(height: 20),
                                  _rowLabel(
                                    t,
                                    'Papel',
                                    entry.role.displayLabel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceXl),
                          Text(
                            'Atividade (ordens concluídas atribuídas a este UID)',
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceSm),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spaceLg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _rowLabel(
                                    t,
                                    'Corridas concluídas',
                                    '${stats.corridasConcluidas}',
                                  ),
                                  const Divider(height: 20),
                                  _rowLabel(
                                    t,
                                    'Valor total na plataforma',
                                    _brlFromCents(stats.totalPlataformaCents),
                                  ),
                                  const Divider(height: 20),
                                  _rowLabel(
                                    t,
                                    'Disponível para saque',
                                    _brlFromCents(saqueVisual),
                                  ),
                                  if (saqueCents == null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Sem `disponivelSaqueCents` no Firestore: a mostrar o mesmo que o total acumulado. Ajuste o campo no documento se já houver saques ou retenções.',
                                      style: t.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (entry.role == UserRole.admin) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Conta de administrador: estatísticas de corridas refletem só OS em que o UID vem em "Entregador atribuído" (atribuição a si próprio, se for o caso).',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static Widget _rowLabel(ThemeData t, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: t.textTheme.labelLarge?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: t.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
