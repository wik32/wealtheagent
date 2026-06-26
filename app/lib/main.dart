import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'l10n.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'security/app_lock.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.hasBackend) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseKey,
    );
    try {
      // Kein Inhalt in Screenshots/App-Switcher — Finanzdaten bleiben privat.
      await ScreenProtector.preventScreenshotOn();
    } catch (_) {}
  }
  try {
    await loadSavedLocale();
  } catch (_) {}
  runApp(const FinanzApp());
}

class FinanzApp extends StatelessWidget {
  const FinanzApp({super.key});

  bool get _needsAuth =>
      AppConfig.hasBackend &&
      Supabase.instance.client.auth.currentSession == null;

  Widget get _home {
    // Ohne Backend (Tests): direkt ins Onboarding (Mock-Daten).
    if (!AppConfig.hasBackend) return const OnboardingScreen();
    // Mit Backend, nicht angemeldet: Registrierungspflicht.
    if (_needsAuth) return const AuthScreen();
    // Angemeldet (zurückkehrend): Biometrie-Sperre, dann direkt in die App.
    return const LockGate(child: HomeShell());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLocale,
      builder: (context, locale, _) => MaterialApp(
        title: 'FinanzApp',
        debugShowCheckedModeBanner: false,
        theme: finTheme(Brightness.light),
        darkTheme: finTheme(Brightness.dark),
        home: _home,
      ),
    );
  }
}
