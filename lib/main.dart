import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app_theme.dart';
import 'app/theme_mode_scope.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }
  runApp(const BorderlessApp());
}

class BorderlessApp extends StatefulWidget {
  const BorderlessApp({super.key});

  @override
  State<BorderlessApp> createState() => _BorderlessAppState();
}

class _BorderlessAppState extends State<BorderlessApp> {
  final ValueNotifier<ThemeMode> _themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeMode,
      builder: (context, _) {
        return AppThemeModeScope(
          themeMode: _themeMode,
          child: MaterialApp(
            title: 'Drive Home',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _themeMode.value,
            home: const AuthGate(),
          ),
        );
      },
    );
  }
}
