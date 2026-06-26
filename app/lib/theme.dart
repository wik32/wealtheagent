import 'package:flutter/material.dart';

/// FinanzApp Designsystem — „Editorial".
/// Papier-Hintergrund, große Serifen (Display), Terrakotta-Akzent auf Tiefgrün,
/// Haarlinien statt schwerer Karten. Ruhig, premium, sehr lesbar.

abstract class FinColors {
  // Light — Papier & Tinte
  static const cream = Color(0xFFF4F1E9); // Papier-Hintergrund
  static const card = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE3DDCC); // Haarlinie
  static const green = Color(0xFF1F3D34); // Primär
  static const greenDark = Color(0xFF16302A);
  static const greenSoft = Color(0xFFEFE7D7); // ruhige Akzentfläche
  static const ink = Color(0xFF1E2A24);
  static const muted = Color(0xFF8A857A);
  static const faint = Color(0xFFAAA293);
  static const gold = Color(0xFFB5502F); // Akzent = Terrakotta (Name beibehalten)
  static const amberSoft = Color(0xFFF0E7D6);
  static const amberText = Color(0xFFB5502F);

  // Dark — tiefes Grün-Schwarz
  static const darkBg = Color(0xFF14201B);
  static const darkCard = Color(0xFF1B2A24);
  static const darkBorder = Color(0xFF2C3A33);
  static const darkInk = Color(0xFFEDE7D9);
  static const darkMuted = Color(0xFF9AA39A);
}

/// Abstands-Skala (4er-Raster). Konsequent für ruhige, gut lesbare Layouts.
abstract class Sp {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 44.0;

  /// Standard-Screenrand (Editorial: großzügig).
  static const screen = EdgeInsets.fromLTRB(24, 8, 24, 28);
}

/// Serifen-Display (Apple „New York" auf iOS, sonst System-Serife).
const _serifFallback = ['New York', 'Georgia', 'Times New Roman', 'serif'];

TextStyle serif({
  double size = 28,
  FontWeight weight = FontWeight.w500,
  Color? color,
  double height = 1.08,
  double spacing = -0.4,
  FontStyle? style,
}) =>
    TextStyle(
      fontFamily: 'New York',
      fontFamilyFallback: _serifFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
      fontStyle: style,
    );

ThemeData finTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final bg = dark ? FinColors.darkBg : FinColors.cream;
  final ink = dark ? FinColors.darkInk : FinColors.ink;
  final muted = dark ? FinColors.darkMuted : FinColors.muted;
  final card = dark ? FinColors.darkCard : FinColors.card;
  final border = dark ? FinColors.darkBorder : FinColors.cardBorder;
  final accent = dark ? const Color(0xFF7FB39E) : FinColors.green;

  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: FinColors.green,
      brightness: brightness,
      surface: bg,
      primary: accent,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: serif(size: 19, weight: FontWeight.w600, color: ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: dark ? FinColors.darkBg : const Color(0xFFF6F2E8),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: serif(size: 16, weight: FontWeight.w600, spacing: 0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: serif(size: 15, weight: FontWeight.w600, spacing: 0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    dividerColor: border,
    listTileTheme: ListTileThemeData(iconColor: muted),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: border)),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.4)),
      labelStyle: TextStyle(color: muted),
      hintStyle: TextStyle(color: muted),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: accent,
      unselectedItemColor: muted,
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

extension FinContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get inkColor => isDark ? FinColors.darkInk : FinColors.ink;
  Color get mutedColor => isDark ? FinColors.darkMuted : FinColors.muted;
  Color get accentColor =>
      isDark ? const Color(0xFF7FB39E) : FinColors.green;
  Color get terracotta =>
      isDark ? const Color(0xFFD2734E) : FinColors.gold;
  Color get borderColor =>
      isDark ? FinColors.darkBorder : FinColors.cardBorder;
  Color get paperColor => isDark ? FinColors.darkBg : FinColors.cream;
  Color get cardColor => isDark ? FinColors.darkCard : FinColors.card;
}
