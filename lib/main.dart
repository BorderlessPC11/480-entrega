import 'package:flutter/material.dart';

import 'app/app_theme.dart';
import 'features/drive_home/presentation/drive_home_screen.dart';

void main() {
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
      home: const DriveHomeScreen(),
    );
  }
}
