import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../drive_home/presentation/drive_home_screen.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
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
      return const DriveHomeScreen();
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
