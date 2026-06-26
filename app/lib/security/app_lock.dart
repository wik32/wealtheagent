import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../l10n.dart';
import '../theme.dart';

/// Biometrie-Gate (Face ID / Touch ID / Geräte-Code) vor den Finanzdaten.
/// Geräte ohne Biometrie werden durchgelassen (Code-Sperre macht das OS).
class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  final _auth = LocalAuthentication();
  bool _unlocked = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _tryUnlock();
  }

  Future<void> _tryUnlock() async {
    setState(() => _checking = true);
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        setState(() {
          _unlocked = true;
          _checking = false;
        });
        return;
      }
      final ok = await _auth.authenticate(
        localizedReason: t(
          'FinanzApp entsperren, um deine Verträge zu sehen.',
          'Unlock FinanzApp to see your contracts.',
        ),
      );
      setState(() {
        _unlocked = ok;
        _checking = false;
      });
    } catch (_) {
      // Plugin/Plattform nicht verfügbar (z.B. Tests) → nicht aussperren.
      setState(() {
        _unlocked = true;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 40, color: context.accentColor),
            const SizedBox(height: 16),
            Text(
              t('FinanzApp ist gesperrt', 'FinanzApp is locked'),
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            if (_checking)
              const CircularProgressIndicator()
            else
              FilledButton(
                onPressed: _tryUnlock,
                child: Text(t('Entsperren', 'Unlock')),
              ),
          ],
        ),
      ),
    );
  }
}
