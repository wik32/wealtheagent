import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Leichte Lokalisierung: Deutsch ist Standard, Englisch zuschaltbar.
/// Globaler Notifier — MaterialApp lauscht und baut bei Wechsel neu.
final ValueNotifier<String> appLocale = ValueNotifier('de');

Future<void> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  appLocale.value = prefs.getString('locale') ?? 'de';
}

Future<void> setLocale(String code) async {
  appLocale.value = code;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
  } catch (_) {
    // Persistenz optional (z.B. in Tests nicht verfügbar).
  }
}

bool get isEnglish => appLocale.value == 'en';

/// Übersetzungs-Lookup: t('de Text', 'en text').
String t(String de, String en) => isEnglish ? en : de;
