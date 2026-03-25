import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:borderless_app/app/app_theme.dart';

void main() {
  testWidgets('App theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(child: Text('Test')),
        ),
      ),
    );
    expect(find.text('Test'), findsOneWidget);
  });
}
