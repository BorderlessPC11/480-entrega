import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/user/user_role.dart';
import '../../admin/presentation/admin_home_screen.dart';
import '../../drive_home/presentation/drive_home_screen.dart';
import '../../profile/data/user_profile_repository.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  /// Recria o [StreamBuilder] para voltar a subscrever ao stream após erro.
  int _authStreamEpoch = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      key: ValueKey<int>(_authStreamEpoch),
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AuthStreamErrorScaffold(
            error: snapshot.error,
            onRetry: () => setState(() => _authStreamEpoch++),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        return _SignedInBranch(user: user);
      },
    );
  }
}

class _AuthStreamErrorScaffold extends StatelessWidget {
  const _AuthStreamErrorScaffold({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Não foi possível iniciar a autenticação.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignedInBranch extends StatefulWidget {
  const _SignedInBranch({required this.user});

  final User user;

  @override
  State<_SignedInBranch> createState() => _SignedInBranchState();
}

class _SignedInBranchState extends State<_SignedInBranch> {
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await widget.user.reload();
    if (mounted) setState(() => _booting = false);
  }

  Future<void> _recheck() async {
    await FirebaseAuth.instance.currentUser?.reload();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return const _LoadingScaffold();
    }
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      return const LoginScreen();
    }
    if (u.emailVerified) {
      return _RoleRoot(user: u);
    }
    return EmailVerificationScreen(onRecheck: _recheck);
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _RoleRoot extends StatelessWidget {
  const _RoleRoot({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole>(
      stream: UserProfileRepository().watchRole(user.uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('${snap.error}'));
        }
        if (!snap.hasData) {
          return const _LoadingScaffold();
        }
        if (snap.data == UserRole.admin) {
          return const AdminHomeScreen();
        }
        return const DriveHomeScreen();
      },
    );
  }
}
