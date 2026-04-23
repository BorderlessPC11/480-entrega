import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF7C4DFF);

  // —— Design tokens: espaçamento (escala fixa; cores vêm de [ColorScheme].) ——

  static const double space2xs = 3;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double space2xl = 24;

  /// Largura máxima para conteúdo centralizado (ex.: mapa, formulário largo).
  static const double maxContentWidth = 560;

  /// Largura para listas de cartões (entregador / solicitante).
  static const double maxListContentWidth = 520;

  /// Padding padrão de página (SafeArea + colunas).
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    spaceLg,
    14,
    spaceLg,
    spaceLg,
  );

  /// Área informativa acima do mapa (só horizontal + topo; o fundo preenche o [Expanded] do mapa).
  static const EdgeInsets mapInfoScrollPadding = EdgeInsets.fromLTRB(
    spaceLg,
    spaceSm,
    spaceLg,
    spaceMd,
  );

  /// Sublinhado de títulos: topo confortável abaixo do entalhe, base junto ao próximo bloco.
  static const EdgeInsets homeHeaderPadding = EdgeInsets.fromLTRB(
    spaceLg,
    14,
    spaceLg,
    spaceSm,
  );

  /// Espaço extra no fim de listas acima da bottom bar (evita corte com o rótulo do FAB/nav).
  static const double listBottomWithNav = 28;

  /// ListView de formulário com barra inferior de navegação.
  static const double bottomFormScrollPadding = 100;

  /// Sombra do painel / sheet (tema: usa a cor de sombra do esquema).
  static List<BoxShadow> sheetBoxShadows(ColorScheme cs) {
    return [
      BoxShadow(
        color: cs.shadow.withValues(alpha: 0.28),
        blurRadius: 20,
        offset: const Offset(0, -4),
      ),
    ];
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ).copyWith(
        surface: const Color(0xFF0D0F12),
        surfaceContainerHighest: const Color(0xFF151A20),
        surfaceContainerHigh: const Color(0xFF12161C),
        surfaceContainer: const Color(0xFF101419),
        outline: const Color(0xFF2A313B),
      ),
    );

    final cs = base.colorScheme;

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0B0D10),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0B0D10),
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outline.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainer,
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary.withValues(alpha: 0.9)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withValues(alpha: 0.65),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outline.withValues(alpha: 0.6),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: cs.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.light,
      ).copyWith(
        surface: const Color(0xFFF5F6F8),
        surfaceContainerHighest: const Color(0xFFE8EBF0),
        surfaceContainerHigh: const Color(0xFFF0F2F6),
        surfaceContainer: const Color(0xFFFAFAFC),
        outline: const Color(0xFFC9CFD8),
      ),
    );

    final cs = base.colorScheme;

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF2F3F6),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF2F3F6),
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainer,
        hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary.withValues(alpha: 0.9)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withValues(alpha: 0.55),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: cs.outline.withValues(alpha: 0.45),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

