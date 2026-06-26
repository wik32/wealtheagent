import 'package:flutter/material.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';
import 'type_onboarding_screen.dart';
import 'voice_onboarding_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  const Kicker('Nº 01'),
                ],
              ),
              const SizedBox(height: Sp.md),
              Container(height: 2, color: context.accentColor),
              const Spacer(),
              Kicker(t('Willkommen', 'Welcome')),
              const SizedBox(height: Sp.md),
              Text(
                t('Schön, dass du da bist.', 'Glad you\'re here.'),
                style: serif(size: 36, color: context.inkColor, height: 1.04),
              ),
              const SizedBox(height: Sp.lg),
              Text(
                t('Drei kurze Fragen zu dir – damit deine Übersicht zu deinem Leben passt.',
                    'Three short questions about you – so your overview fits your life.'),
                style: TextStyle(
                    color: context.mutedColor, fontSize: 15, height: 1.6),
              ),
              const Spacer(),
              _ChoiceCard(
                primary: true,
                icon: Icons.mic_none,
                title: t('Erzähl es uns einfach', 'Just tell us'),
                subtitle:
                    t('Kurzes Gespräch, ca. 2 Minuten', 'A short chat, ~2 minutes'),
                onTap: () => _open(context, const VoiceOnboardingScreen()),
              ),
              const SizedBox(height: Sp.md),
              _ChoiceCard(
                primary: false,
                icon: Icons.edit_outlined,
                title: t('Lieber tippen', 'Prefer typing'),
                subtitle: t('3 kurze Schritte zum Durchklicken',
                    'Three quick steps to click through'),
                onTap: () => _open(context, const TypeOnboardingScreen()),
              ),
              const SizedBox(height: Sp.xl),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: context.mutedColor),
                    const SizedBox(width: Sp.sm),
                    Text(
                      t('Deine Daten bleiben in der EU. Immer.',
                          'Your data stays in the EU. Always.'),
                      style:
                          TextStyle(color: context.mutedColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.primary,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool primary;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final fg = primary
        ? (context.isDark ? context.paperColor : const Color(0xFFF6F2E8))
        : context.inkColor;
    final sub = primary ? fg.withValues(alpha: 0.7) : context.mutedColor;
    return Material(
      color: primary ? accent : context.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border:
                primary ? null : Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: primary ? fg : accent, size: 24),
              const SizedBox(width: Sp.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: serif(size: 18, color: fg, spacing: 0)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(color: sub, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward,
                  size: 18, color: primary ? fg : context.mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}
