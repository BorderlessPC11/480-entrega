import 'package:flutter/material.dart';

/// Expõe [ValueNotifier] do [ThemeMode] para telas abaixo de [MaterialApp].
class AppThemeModeScope extends InheritedWidget {
  const AppThemeModeScope({
    super.key,
    required this.themeMode,
    required super.child,
  });

  final ValueNotifier<ThemeMode> themeMode;

  static ValueNotifier<ThemeMode> of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppThemeModeScope>();
    assert(scope != null, 'AppThemeModeScope não encontrado na árvore.');
    return scope!.themeMode;
  }

  @override
  bool updateShouldNotify(covariant AppThemeModeScope oldWidget) {
    return oldWidget.themeMode != themeMode;
  }
}
