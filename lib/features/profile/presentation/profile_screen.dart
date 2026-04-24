import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/theme_mode_scope.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/user/user_display.dart';
import '../../../core/user/user_role.dart';
import '../data/user_profile_repository.dart';
import 'edit_profile_screen.dart';
import 'widgets/info_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/stat_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.role = UserRole.entregador});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final def = _mockDriver();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        if (user == null) {
          return const Center(
            child: Text('Não autenticado.'),
          );
        }
        return StreamBuilder<Map<String, dynamic>>(
          stream: UserProfileRepository().watchUserProfile(user.uid),
          builder: (context, profSnapshot) {
            final p = profSnapshot.data ?? {};
        return StreamBuilder<String?>(
          stream: UserProfileRepository().watchPhone(user.uid),
          builder: (context, phoneSnapshot) {
            final storedPhone = phoneSnapshot.data;
            final name = userDisplayLabel(user) ?? 'Motorista';
            final initials = userInitials(user);
            final accountEmail = user.email ?? def.email;
            final tripCount = (p['totalTrips'] as num?)?.toInt() ?? def.totalTrips;
            final completedC =
                (p['completedOrders'] as num?)?.toInt() ?? def.completedOrders;
            final expM =
                (p['experienceMonths'] as num?)?.toInt() ?? def.experienceMonths;
            final rating =
                (p['rating'] as num?)?.toDouble() ?? def.rating;
            final reviews =
                (p['reviewCount'] as num?)?.toInt() ?? def.reviewCount;
            final vModel = (p['vehicleModel'] as String?) ?? def.vehicleModel;
            final vPlate = (p['vehiclePlate'] as String?) ?? def.vehiclePlate;
            final vStatus = (p['vehicleStatus'] as String?) ?? def.vehicleStatus;
            final displayNameRaw = user.displayName?.trim() ?? '';
            final String phoneValue;
            if (phoneSnapshot.hasError) {
              phoneValue = 'Não foi possível carregar';
            } else if (storedPhone != null && storedPhone.isNotEmpty) {
              phoneValue = storedPhone;
            } else {
              phoneValue = 'Não informado';
            }

            return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = math.min(constraints.maxWidth, 560.0);
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Text(
                          'Perfil',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ProfileHeader(
                      name: name,
                      initials: initials,
                      photoUrl: user.photoURL,
                      rating: rating,
                      reviewCount: reviews,
                      roleBadge: role == UserRole.admin
                          ? 'Administrador'
                          : 'Motorista parceiro',
                      onSettingsTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configurações (em breve).'),
                          ),
                        );
                      },
                      onEditTap: () async {
                        final ok = await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) => EditProfileScreen(
                              userId: user.uid,
                              initialDisplayName: displayNameRaw,
                              initialPhone: storedPhone,
                              initialPhotoUrl: user.photoURL,
                              avatarInitials: initials,
                            ),
                          ),
                        );
                        if (ok == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil atualizado.'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _StaggeredIn(
                      index: 0,
                      child: InfoCard(
                        title: 'Contato',
                        trailing: const Icon(Icons.contact_mail_rounded),
                        child: Column(
                          children: [
                            _InfoLine(
                              icon: Icons.email_rounded,
                              label: 'Email',
                              value: accountEmail,
                            ),
                            const SizedBox(height: 12),
                            _InfoLine(
                              icon: Icons.call_rounded,
                              label: 'Telefone',
                              value: phoneValue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _StaggeredIn(
                      index: 1,
                      child: InfoCard(
                        title: 'Aparência',
                        trailing: const Icon(Icons.palette_rounded),
                        child: ValueListenableBuilder<ThemeMode>(
                          valueListenable: AppThemeModeScope.of(context),
                          builder: (context, mode, _) {
                            final isDark = mode == ThemeMode.dark;
                            return SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                isDark ? 'Tema escuro' : 'Tema claro',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              subtitle: Text(
                                isDark
                                    ? 'Reduz o brilho em ambientes com pouca luz'
                                    : 'Mais claro para uso diurno',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.65),
                                ),
                              ),
                              secondary: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                              ),
                              value: isDark,
                              onChanged: (v) {
                                AppThemeModeScope.of(context).value =
                                    v ? ThemeMode.dark : ThemeMode.light;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (role == UserRole.entregador)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _StaggeredIn(
                        index: 2,
                        child: InfoCard(
                          title: 'Estatísticas',
                          trailing: const Icon(Icons.auto_graph_rounded),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: StatTile(
                                      label: 'Viagens',
                                      value: tripCount.toString(),
                                      icon: Icons.route_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: StatTile(
                                      label: 'OS concluídas',
                                      value: completedC.toString(),
                                      icon: Icons.verified_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              StatTile(
                                label: 'Experiência',
                                value: '$expM meses',
                                icon: Icons.badge_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (role == UserRole.entregador)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: _StaggeredIn(
                        index: 3,
                        child: InfoCard(
                          title: 'Veículo',
                          trailing: const Icon(Icons.directions_car_rounded),
                          child: Column(
                            children: [
                              _InfoLine(
                                icon: Icons.commute_rounded,
                                label: 'Modelo',
                                value: vModel,
                              ),
                              const SizedBox(height: 12),
                              _InfoLine(
                                icon: Icons.confirmation_number_rounded,
                                label: 'Placa',
                                value: vPlate,
                              ),
                              const SizedBox(height: 12),
                              _InfoLine(
                                icon: Icons.circle_rounded,
                                label: 'Status',
                                value: vStatus,
                                valueColor: _statusColor(
                                  Theme.of(context).colorScheme,
                                  vStatus,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.logout_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Sair',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        subtitle: const Text('Encerrar sessão neste dispositivo'),
                        onTap: () async {
                          await AuthService().signOut();
                        },
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
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
      },
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: t.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: t.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _StaggeredIn extends StatelessWidget {
  const _StaggeredIn({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delayMs = (index * 65).clamp(0, 320);
    final duration = Duration(milliseconds: 260 + delayMs);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final y = (1 - t) * 10;
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, y), child: child),
        );
      },
    );
  }
}

Color _statusColor(ColorScheme cs, String status) {
  return switch (status.toLowerCase()) {
    'ativo' => const Color(0xFF38D996),
    'pendente' => const Color(0xFFFFC866),
    _ => cs.onSurface.withValues(alpha: 0.8),
  };
}

_DriverProfile _mockDriver() {
  return const _DriverProfile(
    name: 'Henrique Costa',
    initials: 'HC',
    rating: 4.8,
    reviewCount: 128,
    email: 'henrique.costa@drivehome.com',
    phone: '(11) 9****-1234',
    totalTrips: 842,
    completedOrders: 806,
    experienceMonths: 14,
    vehicleModel: 'Fiat Strada • Prata',
    vehiclePlate: 'ABC1D23',
    vehicleStatus: 'Ativo',
  );
}

class _DriverProfile {
  const _DriverProfile({
    required this.name,
    required this.initials,
    required this.rating,
    required this.reviewCount,
    required this.email,
    required this.phone,
    required this.totalTrips,
    required this.completedOrders,
    required this.experienceMonths,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.vehicleStatus,
  });

  final String name;
  final String initials;
  final double rating;
  final int reviewCount;
  final String email;
  final String phone;
  final int totalTrips;
  final int completedOrders;
  final int experienceMonths;
  final String vehicleModel;
  final String vehiclePlate;
  final String vehicleStatus;
}

