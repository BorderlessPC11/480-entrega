import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/user/user_display.dart';
import '../data/mock_orders.dart';
import '../domain/order.dart';
import 'order_details_screen.dart';
import '../../history/presentation/history_tab.dart';
import '../../map/presentation/ride_map_tab.dart';
import '../../profile/presentation/profile_screen.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/order_card.dart';

class DriveHomeScreen extends StatefulWidget {
  const DriveHomeScreen({super.key});

  @override
  State<DriveHomeScreen> createState() => _DriveHomeScreenState();
}

class _DriveHomeScreenState extends State<DriveHomeScreen> {
  final _searchController = TextEditingController();
  late final List<Order> _allOrders;

  String _selectedFilterId = 'all';
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _allOrders = mockOrders();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _navIndex,
          children: [
            _DriveHomeTab(
              allOrders: _allOrders,
              searchController: _searchController,
              selectedFilterId: _selectedFilterId,
              onSelectedFilter: (id) => setState(() => _selectedFilterId = id),
            ),
            const RideMapTab(),
            const HistoryTab(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'OS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Histórico',
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

class _DriveHomeTab extends StatelessWidget {
  const _DriveHomeTab({
    required this.allOrders,
    required this.searchController,
    required this.selectedFilterId,
    required this.onSelectedFilter,
  });

  final List<Order> allOrders;
  final TextEditingController searchController;
  final String selectedFilterId;
  final ValueChanged<String> onSelectedFilter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final query = searchController.text.trim().toLowerCase();
    final filtered = allOrders.where((o) {
      final matchesQuery = query.isEmpty ||
          o.customerName.toLowerCase().contains(query) ||
          o.addressLine1.toLowerCase().contains(query) ||
          o.addressLine2.toLowerCase().contains(query) ||
          o.id.toLowerCase().contains(query);

      final matchesFilter = switch (selectedFilterId) {
        'all' => true,
        'confirmacao' => o.status == OrderStatus.disponivel,
        'cobranca' => o.category == OrderCategory.cobranca,
        'recebimento' => o.category == OrderCategory.recebimento,
        'coleta' => o.category == OrderCategory.coleta,
        'entrega' => o.category == OrderCategory.entrega,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();

    final chips = <FilterChipItem>[
      const FilterChipItem(id: 'all', label: 'Todos'),
      const FilterChipItem(id: 'confirmacao', label: 'Confirmação'),
      const FilterChipItem(id: 'cobranca', label: 'Cobrança'),
      const FilterChipItem(id: 'recebimento', label: 'Recebimento'),
      const FilterChipItem(id: 'coleta', label: 'Coleta'),
      const FilterChipItem(id: 'entrega', label: 'Entrega'),
    ];

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
                    child: StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.userChanges(),
                      initialData: FirebaseAuth.instance.currentUser,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        return _Header(
                          title: 'OS Disponíveis',
                          subtitle:
                              '${filtered.length} ordens disponíveis',
                          user: user,
                          onNotificationTap: () {
                            final account = user?.email ?? user?.uid ?? '—';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sem notificações. Conta: $account'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: TextField(
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () => searchController.clear(),
                                icon: const Icon(Icons.close_rounded),
                                tooltip: 'Limpar',
                              ),
                        hintText: 'Buscar por nome, endereço ou OS…',
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: FilterChipsRow(
                      filters: chips,
                      selectedId: selectedFilterId,
                      onSelected: onSelectedFilter,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return _StaggeredIn(
                        index: index,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: OrderCard(
                            order: order,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsScreen(
                                    order: order,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 1,
                    color: cs.outline.withValues(alpha: 0.25),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.user,
    required this.onNotificationTap,
  });

  final String title;
  final String subtitle;
  final User? user;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final label = userDisplayLabel(user);
    final accountHint = user?.email ?? user?.displayName ?? user?.uid;
    final notificationTooltip = accountHint != null
        ? 'Notificações ($accountHint)'
        : 'Notificações';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.labelLarge?.copyWith(
                    color: cs.primary.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  subtitle,
                  key: ValueKey(subtitle),
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: onNotificationTap,
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: notificationTooltip,
        ),
        const SizedBox(width: 8),
        _Avatar(user: user),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = userInitials(user);
    final photo = user?.photoURL;
    final label = userDisplayLabel(user) ?? user?.email ?? user?.uid ?? 'Conta';
    return Tooltip(
      message: label,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.85),
              cs.tertiary.withValues(alpha: 0.75),
            ],
          ),
          border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: photo != null && photo.isNotEmpty
            ? Image.network(
                photo,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
      ),
    );
  }
}

class _StaggeredIn extends StatelessWidget {
  const _StaggeredIn({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delayMs = (index * 55).clamp(0, 380);
    final duration = Duration(milliseconds: 260 + delayMs);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final y = (1 - t) * 10;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, y),
            child: child,
          ),
        );
      },
    );
  }
}

