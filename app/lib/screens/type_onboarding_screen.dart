import 'package:flutter/material.dart';
import '../data/repository_provider.dart';
import '../l10n.dart';
import '../theme.dart';
import 'home_shell.dart';

/// Tipp-Onboarding: drei kurze Fragen, keine Bewertung — nur Erfassung.
class TypeOnboardingScreen extends StatefulWidget {
  const TypeOnboardingScreen({super.key});

  @override
  State<TypeOnboardingScreen> createState() => _TypeOnboardingScreenState();
}

class _TypeOnboardingScreenState extends State<TypeOnboardingScreen> {
  final _birthYear = TextEditingController();
  final _profession = TextEditingController();
  String? _familyStatus;
  int _children = 0;
  bool _saving = false;

  @override
  void dispose() {
    _birthYear.dispose();
    _profession.dispose();
    super.dispose();
  }

  Future<void> _finish({bool skip = false}) async {
    if (_saving) return;
    setState(() => _saving = true);
    if (!skip) {
      final profile = <String, dynamic>{
        if (int.tryParse(_birthYear.text) != null)
          'birth_year': int.parse(_birthYear.text),
        if (_familyStatus != null) 'family_status': _familyStatus,
        if (_profession.text.trim().isNotEmpty)
          'profession': _profession.text.trim(),
        'children': _children,
      };
      try {
        await contractsRepository().saveProfile(profile);
      } catch (_) {
        // Profil ist optional — App-Nutzung nicht blockieren.
      }
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('Kurz zu dir', 'About you'),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => _finish(skip: true),
            child: Text(t('Überspringen', 'Skip'),
                style: TextStyle(color: context.mutedColor)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            t('Drei kurze Fragen – nur Erfassung, keine Bewertung.',
                'Three quick questions – just facts, no judgement.'),
            style: TextStyle(color: context.mutedColor, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Text(t('Geburtsjahr', 'Year of birth'),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _birthYear,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t('z.B. 1990', 'e.g. 1990'),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14))),
            ),
          ),
          const SizedBox(height: 24),
          Text(t('Lebenssituation', 'Family status'),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final (value, label) in [
                ('single', t('Alleinstehend', 'Single')),
                ('paar', t('Paar', 'Couple')),
                ('familie', t('Familie', 'Family')),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _familyStatus == value,
                  onSelected: (_) => setState(() => _familyStatus = value),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(t('Beruf', 'Profession'),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _profession,
            decoration: InputDecoration(
              hintText: t('z.B. Softwareentwicklerin', 'e.g. software engineer'),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14))),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t('Kinder', 'Children'),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  IconButton(
                    onPressed: _children > 0
                        ? () => setState(() => _children--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_children',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(
                    onPressed: () => setState(() => _children++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _finish,
            child: Text(t('Los geht\'s', 'Let\'s go')),
          ),
        ],
      ),
    );
  }
}
