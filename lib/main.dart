import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BorderlessApp());
}

class BorderlessApp extends StatelessWidget {
  const BorderlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drive Home',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AuthGate(),
    );
  }
}
