import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../data/contracts_controller.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';
import 'auth_screen.dart';
import 'info_page_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    if (AppConfig.hasBackend) {
      await Supabase.instance.client.auth.signOut();
    }
    contractsController.reset();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = AppConfig.hasBackend
        ? Supabase.instance.client.auth.currentUser?.email
        : null;
    return ValueListenableBuilder<String>(
      valueListenable: appLocale,
      builder: (context, _, _) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Kicker(t('Konto', 'Account')),
              const SizedBox(height: Sp.sm),
              Text(t('Profil', 'Profile'),
                  style: serif(size: 30, color: context.inkColor)),
              const SizedBox(height: Sp.xl),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: context.accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_outline, color: context.accentColor),
                  ),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email ?? t('Demo-Modus', 'Demo mode'),
                            style: serif(
                                size: 16, color: context.inkColor, spacing: 0)),
                        const SizedBox(height: 2),
                        Text(
                          t('Daten verschlüsselt in der EU',
                              'Data encrypted in the EU'),
                          style: TextStyle(
                              fontSize: 12, color: context.mutedColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.xxl),
              _SectionLabel(t('Sprache', 'Language')),
              const SizedBox(height: Sp.sm),
              const Hairline(),
              RadioGroup<String>(
                groupValue: appLocale.value,
                onChanged: (v) {
                  if (v != null) setLocale(v);
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'de',
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Deutsch'),
                    ),
                    const Hairline(),
                    RadioListTile<String>(
                      value: 'en',
                      contentPadding: EdgeInsets.zero,
                      title: const Text('English'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sp.xl),
              _SectionLabel(t('Rechtliches', 'Legal')),
              const SizedBox(height: Sp.sm),
              const Hairline(),
              _LinkRow(
                label: t('Datenschutz', 'Privacy'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InfoPageScreen(
                      title: t('Datenschutz', 'Privacy'),
                      sections: datenschutzSections,
                    ),
                  ),
                ),
              ),
              const Hairline(),
              _LinkRow(
                label: t('Impressum', 'Imprint'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InfoPageScreen(
                      title: t('Impressum', 'Imprint'),
                      sections: impressumSections,
                    ),
                  ),
                ),
              ),
              const Hairline(),
              const SizedBox(height: Sp.xxl),
              OutlinedButton(
                onPressed: () => _logout(context),
                child: Text(t('Abmelden', 'Sign out')),
              ),
              const SizedBox(height: Sp.xl),
              Center(
                child: Text(
                  t('Wir messen. Wir empfehlen nicht.',
                      'We measure. We don\'t advise.'),
                  style: serif(
                      size: 13,
                      color: context.mutedColor,
                      spacing: 0,
                      style: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: context.mutedColor),
      );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: serif(size: 16, color: context.inkColor, spacing: 0)),
            ),
            Icon(Icons.chevron_right, size: 18, color: context.mutedColor),
          ],
        ),
      ),
    );
  }
}
