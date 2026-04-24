import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:borderless_app/app/app_theme.dart';
import 'package:borderless_app/core/user/user_role.dart';
import 'package:borderless_app/features/drive_home/domain/order.dart';
import 'package:borderless_app/features/drive_home/presentation/order_details_screen.dart';
import 'package:borderless_app/features/drive_home/presentation/widgets/filter_chips_row.dart';
import 'package:borderless_app/features/drive_home/presentation/widgets/order_card.dart';
import 'package:borderless_app/features/orders/data/orders_repository.dart';
import 'package:borderless_app/features/profile/presentation/profile_screen.dart';

import 'admin_users_tab.dart';
import 'create_order_screen.dart';

/// Shell: criar rotas, acompanhar, utilizadores, perfil (conta com `role: admin` no Firestore).
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;
  String _filterId = 'all';
  final _search = TextEditingController();
  final _repo = OrdersRepository();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _repo.ensureSeededFromMocks();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Não autenticado.'));
    }
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: [
            const CreateOrderTab(),
            _MyRequestsTab(
              key: const ValueKey('admin_mine'),
              userId: uid,
              searchController: _search,
              filterId: _filterId,
              onFilter: (id) => setState(() => _filterId = id),
              repo: _repo,
            ),
            const AdminUsersTab(),
            const ProfileScreen(role: UserRole.admin),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_location_alt_rounded),
              label: 'Nova rota',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox_rounded),
              label: 'Minhas OS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Utilizadores',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

List<Order> _applyFilterChip(List<Order> list, String id) {
  if (id == 'all') return list;
  return list.where((o) {
    return switch (id) {
      'confirmacao' => o.status == OrderStatus.disponivel,
      'cobranca' => o.category == OrderCategory.cobranca,
      'recebimento' => o.category == OrderCategory.recebimento,
      'coleta' => o.category == OrderCategory.coleta,
      'entrega' => o.category == OrderCategory.entrega,
      _ => true,
    };
  }).toList();
}

class _MyRequestsTab extends StatelessWidget {
  const _MyRequestsTab({
    super.key,
    required this.userId,
    required this.searchController,
    required this.filterId,
    required this.onFilter,
    required this.repo,
  });

  final String userId;
  final TextEditingController searchController;
  final String filterId;
  final ValueChanged<String> onFilter;
  final OrdersRepository repo;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: repo.watchOrders(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var mine = repo.filterForAdmin(snap.data!, userId);
        final q = searchController.text.trim().toLowerCase();
        if (q.isNotEmpty) {
          mine = mine.where((o) {
            return o.customerName.toLowerCase().contains(q) ||
                o.addressLine1.toLowerCase().contains(q) ||
                o.id.toLowerCase().contains(q);
          }).toList();
        }
        mine = _applyFilterChip(mine, filterId);
        return _MyRequestsList(
          orders: mine,
          searchController: searchController,
          filterId: filterId,
          onFilter: onFilter,
        );
      },
    );
  }
}

class _MyRequestsList extends StatelessWidget {
  const _MyRequestsList({
    required this.orders,
    required this.searchController,
    required this.filterId,
    required this.onFilter,
  });

  final List<Order> orders;
  final TextEditingController searchController;
  final String filterId;
  final ValueChanged<String> onFilter;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final filters = <FilterChipItem>[
      const FilterChipItem(id: 'all', label: 'Todos'),
      const FilterChipItem(id: 'confirmacao', label: 'Confirmação'),
      const FilterChipItem(id: 'cobranca', label: 'Cobrança'),
      const FilterChipItem(id: 'recebimento', label: 'Recebimento'),
      const FilterChipItem(id: 'coleta', label: 'Coleta'),
      const FilterChipItem(id: 'entrega', label: 'Entrega'),
    ];
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
                      'Minhas solicitações',
                      style: t.textTheme.headlineSmall?.copyWith(
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
                      controller: searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Buscar…',
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppTheme.space2xs,
                      bottom: AppTheme.spaceSm,
                    ),
                    child: FilterChipsRow(
                      filters: filters,
                      selectedId: filterId,
                      onSelected: onFilter,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceLg,
                    0,
                    AppTheme.spaceLg,
                    AppTheme.listBottomWithNav,
                  ),
                  sliver: SliverList.separated(
                    itemCount: orders.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: AppTheme.spaceMd,
                    ),
                    itemBuilder: (c, i) {
                      final o = orders[i];
                      return OrderCard(
                        order: o,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(
                                order: o,
                                vistaAdmin: true,
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
  }
}
