import 'package:flutter/material.dart';
import '../l10n.dart';
import '../theme.dart';

/// Einfache Inhaltsseite für Rechtstexte (Datenschutz, Impressum).
class InfoPageScreen extends StatelessWidget {
  const InfoPageScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;

  /// Liste aus (Überschrift?, Absatz). Überschrift null = reiner Absatz.
  final List<(String?, String)> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          for (final (heading, body) in sections) ...[
            if (heading != null) ...[
              Text(heading,
                  style: serif(size: 17, color: context.inkColor, spacing: 0)),
              const SizedBox(height: 8),
            ],
            Text(body,
                style: TextStyle(
                    fontSize: 14.5, height: 1.7, color: context.inkColor)),
            const SizedBox(height: 22),
          ],
        ],
      ),
    );
  }
}

List<(String?, String)> get datenschutzSections => [
      (
        null,
        t(
          'FinanzApp hilft dir, deine bestehenden Finanz- und Versicherungsverträge '
              'an einem Ort zu erfassen und faktische Beobachtungen daraus abzuleiten. '
              'Der Schutz deiner Daten hat dabei oberste Priorität.',
          'FinanzApp helps you record your existing finance and insurance contracts '
              'in one place and derive factual observations from them. Protecting your '
              'data is the top priority.',
        )
      ),
      (
        t('Wo deine Daten liegen', 'Where your data is stored'),
        t(
          'Konto, hochgeladene Dokumente und erfasste Vertragsdaten werden '
              'ausschließlich in Rechenzentren innerhalb der Europäischen Union '
              'gespeichert (Supabase, Region Irland). Die automatische Texterkennung '
              'läuft über Claude auf AWS-Infrastruktur in EU-Regionen.',
          'Your account, uploaded documents and recorded contract data are stored '
              'exclusively in data centres within the European Union (Supabase, '
              'Ireland region). Automatic text recognition runs via Claude on AWS '
              'infrastructure in EU regions.',
        )
      ),
      (
        t('Wer Zugriff hat', 'Who has access'),
        t(
          'Durch Row-Level-Security auf Datenbankebene kann jedes Konto '
              'ausschließlich auf die eigenen Daten zugreifen. Dokumente liegen in '
              'einem privaten Speicher, der pro Nutzerkonto getrennt ist.',
          'Row-level security at the database layer means each account can access '
              'only its own data. Documents live in private storage that is separated '
              'per user account.',
        )
      ),
      (
        t('Deine Rechte', 'Your rights'),
        t(
          'Du kannst deine Verträge jederzeit löschen und dein Konto auf Anfrage '
              'vollständig entfernen lassen. Es werden nur die Daten erhoben, die für '
              'die Funktion der App erforderlich sind.',
          'You can delete your contracts at any time and have your account fully '
              'removed on request. Only the data required for the app to function is '
              'collected.',
        )
      ),
      (
        t('Hinweis', 'Note'),
        t(
          'Dies ist eine vorläufige Fassung. Die rechtsverbindliche '
              'Datenschutzerklärung wird vor Veröffentlichung der App finalisiert.',
          'This is a preliminary version. The legally binding privacy policy will be '
              'finalised before the app is published.',
        )
      ),
    ];

List<(String?, String)> get impressumSections => [
      (
        t('Angaben gemäß § 5 DDG', 'Information according to § 5 DDG'),
        'FinanzApp (Projektname)\nFabian Benusch'
      ),
      (
        t('Hinweis', 'Note'),
        t(
          'Vorläufiges Impressum. Die vollständigen Anbieterangaben werden vor '
              'Veröffentlichung ergänzt.',
          'Preliminary imprint. Full provider details will be added before '
              'publication.',
        )
      ),
      (
        t('Keine Anlage- oder Versicherungsberatung',
            'No investment or insurance advice'),
        t(
          'FinanzApp erfasst und misst deine bestehenden Verträge und zeigt '
              'faktische Beobachtungen. Die App gibt keine Empfehlungen ab und ersetzt '
              'keine individuelle Beratung durch zugelassene Berater.',
          'FinanzApp records and measures your existing contracts and shows factual '
              'observations. The app gives no recommendations and does not replace '
              'individual advice from licensed advisers.',
        )
      ),
    ];
