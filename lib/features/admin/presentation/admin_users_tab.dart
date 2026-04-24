import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:borderless_app/app/app_theme.dart';
import 'package:borderless_app/core/user/user_role.dart';
import 'package:borderless_app/features/orders/data/orders_repository.dart';
import 'package:borderless_app/features/orders/domain/entregador_order_stats.dart';

import '../data/user_directory_entry.dart';
import '../data/user_directory_repository.dart';
import 'admin_user_detail_screen.dart';

String _brlFromCents(int cents) {
  final reais = cents / 100.0;
  final s = reais.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $s';
}

/// Lista de utilizadores em cards (substitui o antigo "Histórico" no painel admin).
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _search = TextEditingController();
  final _userDir = UserDirectoryRepository();
  final _orders = OrdersRepository();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserDirectoryEntry>>(
      stream: _userDir.watchAllUsers(),
      builder: (context, userSnap) {
        if (userSnap.hasError) {
          return Center(
            child: Text(
              '${userSnap.error}',
              textAlign: TextAlign.center,
            ),
          );
        }
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder(
          stream: _orders.watchOrders(),
          builder: (context, ordSnap) {
            if (ordSnap.hasError) {
              return Center(
                child: Text(
                  '${ordSnap.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (!ordSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final orders = ordSnap.data!;
            var list = userSnap.data!;
            final q = _search.text.trim().toLowerCase();
            if (q.isNotEmpty) {
              list = list.where((e) {
                return e.nameOrFallback.toLowerCase().contains(q) ||
                    e.email.toLowerCase().contains(q) ||
                    e.uid.toLowerCase().contains(q);
              }).toList();
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxW = math.min(
                  constraints.maxWidth,
                  AppTheme.maxListContentWidth,
                );
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: AppTheme.homeHeaderPadding,
                            child: Text(
                              'Utilizadores',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceLg,
                              vertical: AppTheme.spaceSm,
                            ),
                            child: TextField(
                              controller: _search,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search_rounded),
                                hintText: 'Buscar por nome, email ou UID',
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.spaceLg,
                            AppTheme.spaceSm,
                            AppTheme.spaceLg,
                            AppTheme.listBottomWithNav,
                          ),
                          sliver: SliverList.separated(
                            itemCount: list.length,
                            separatorBuilder: (context, index) => const SizedBox(
                              height: AppTheme.spaceMd,
                            ),
                            itemBuilder: (context, i) {
                              final e = list[i];
                              final st = EntregadorOrderStats.forUid(
                                orders,
                                e.uid,
                              );
                              return _UserCard(
                                entry: e,
                                stats: st,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => AdminUserDetailScreen(
                                        entry: e,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.entry,
    required this.stats,
    required this.onTap,
  });

  final UserDirectoryEntry entry;
  final EntregadorOrderStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                child: Text(
                  entry.initials,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.nameOrFallback,
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.email,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MiniChip(
                          label: entry.role == UserRole.admin
                              ? 'Admin'
                              : 'Entregador',
                          prominent: entry.role == UserRole.admin,
                        ),
                        _MiniChip(
                          label: '${stats.corridasConcluidas} corridas',
                        ),
                        _MiniChip(
                          label: _brlFromCents(stats.totalPlataformaCents),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    this.prominent = false,
  });

  final String label;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Material(
      color: prominent
          ? cs.secondaryContainer
          : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: t.textTheme.labelSmall?.copyWith(
            color: prominent ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
