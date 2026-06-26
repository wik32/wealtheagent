import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';
import 'home_shell.dart';
import 'onboarding_screen.dart';

/// Pflicht-Registrierung vor App-Nutzung (E-Mail + Passwort).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registerMode = true;
  bool _busy = false;
  String? _message;
  bool _messageIsError = false;
  bool _expectOAuth = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn && mounted && _expectOAuth) {
        _go(const HomeShell());
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _go(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _oauth(OAuthProvider provider) async {
    setState(() => _busy = true);
    _expectOAuth = true;
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.finanzapp://login-callback',
      );
    } on AuthException catch (e) {
      _expectOAuth = false;
      _show(
        t(
          'Login über ${provider.name} ist noch nicht freigeschaltet '
              '(${e.message}). Bitte nutze E-Mail & Passwort.',
          'Login via ${provider.name} is not enabled yet '
              '(${e.message}). Please use email & password.',
        ),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      _show(t('Bitte gib eine gültige E-Mail-Adresse ein.',
          'Please enter a valid email address.'), error: true);
      return;
    }
    if (password.length < 8) {
      _show(t('Das Passwort braucht mindestens 8 Zeichen.',
          'The password needs at least 8 characters.'), error: true);
      return;
    }
    setState(() => _busy = true);
    final auth = Supabase.instance.client.auth;
    try {
      if (_registerMode) {
        final res = await auth.signUp(email: email, password: password);
        if (res.session == null) {
          _show(
            t(
              'Fast geschafft! Wir haben dir eine E-Mail geschickt — '
                  'bitte bestätige deine Adresse und melde dich dann an.',
              'Almost done! We sent you an email — please confirm your '
                  'address and then sign in.',
            ),
          );
          setState(() => _registerMode = false);
          return;
        }
        if (mounted) _go(const OnboardingScreen());
      } else {
        await auth.signInWithPassword(email: email, password: password);
        if (mounted) _go(const HomeShell());
      }
    } on AuthException catch (e) {
      _show(_authError(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _authError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return t('E-Mail oder Passwort ist nicht korrekt.',
          'Email or password is incorrect.');
    }
    if (msg.contains('already registered')) {
      return t('Diese E-Mail ist bereits registriert — bitte anmelden.',
          'This email is already registered — please sign in.');
    }
    if (msg.contains('email not confirmed')) {
      return t('Bitte bestätige zuerst deine E-Mail-Adresse.',
          'Please confirm your email address first.');
    }
    return t('Das hat nicht geklappt: ${e.message}',
        'That didn\'t work: ${e.message}');
  }

  void _show(String text, {bool error = false}) {
    setState(() {
      _message = text;
      _messageIsError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('FINANZAPP',
                    style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2.4,
                        fontWeight: FontWeight.w700,
                        color: context.accentColor)),
                Kicker(_registerMode ? t('Zutritt', 'Access') : t('Login', 'Login')),
              ],
            ),
            const SizedBox(height: Sp.md),
            Container(height: 2, color: context.accentColor),
            const SizedBox(height: Sp.xxxl),
            Text(
              _registerMode
                  ? t('Konto erstellen', 'Create account')
                  : t('Willkommen zurück', 'Welcome back'),
              style: serif(size: 34, color: context.inkColor),
            ),
            const SizedBox(height: Sp.md),
            Text(
              _registerMode
                  ? t('Dein Konto schützt deine Daten — verschlüsselt, in der EU.',
                      'Your account protects your data — encrypted, in the EU.')
                  : t('Melde dich mit deinem Konto an.',
                      'Sign in with your account.'),
              style: TextStyle(
                  color: context.mutedColor, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: Sp.xxl),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(labelText: t('E-Mail', 'Email')),
            ),
            const SizedBox(height: Sp.lg),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: t('Passwort (mind. 8 Zeichen)',
                      'Password (min. 8 chars)')),
            ),
            if (_message != null) ...[
              const SizedBox(height: Sp.lg),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _messageIsError
                      ? const Color(0x22B5502F)
                      : FinColors.greenSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: _messageIsError
                        ? context.terracotta
                        : context.inkColor,
                  ),
                ),
              ),
            ],
            const SizedBox(height: Sp.xl),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_registerMode
                      ? t('Konto erstellen', 'Create account')
                      : t('Anmelden', 'Sign in')),
            ),
            const SizedBox(height: Sp.lg),
            Row(
              children: [
                Expanded(child: Divider(color: context.borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(t('oder', 'or'),
                      style:
                          TextStyle(fontSize: 12, color: context.mutedColor)),
                ),
                Expanded(child: Divider(color: context.borderColor)),
              ],
            ),
            const SizedBox(height: Sp.lg),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _oauth(OAuthProvider.apple),
              icon: const Icon(Icons.apple, size: 22),
              label: Text(t('Mit Apple fortfahren', 'Continue with Apple')),
            ),
            const SizedBox(height: Sp.md),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _oauth(OAuthProvider.google),
              icon: const Icon(Icons.g_mobiledata, size: 24),
              label: Text(t('Mit Google fortfahren', 'Continue with Google')),
            ),
            const SizedBox(height: Sp.lg),
            Center(
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                          _registerMode = !_registerMode;
                          _message = null;
                        }),
                child: Text(
                  _registerMode
                      ? t('Du hast schon ein Konto? Anmelden',
                          'Already have an account? Sign in')
                      : t('Neu hier? Konto erstellen',
                          'New here? Create account'),
                ),
              ),
            ),
            const SizedBox(height: Sp.md),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: context.mutedColor),
                  const SizedBox(width: Sp.sm),
                  Text(
                    t('Deine Daten bleiben in der EU. Immer.',
                        'Your data stays in the EU. Always.'),
                    style: TextStyle(color: context.mutedColor, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
