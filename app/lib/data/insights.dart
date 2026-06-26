import 'catalog_controller.dart';
import 'de_format.dart';
import 'extraction_result.dart';
import '../l10n.dart';

/// Faktische Beobachtungen — niemals Empfehlungen (Stage-1-Leitplanke).
enum InsightKind { duplicate, missing, comparison }

class Insight {
  const Insight({
    required this.kind,
    required this.title,
    required this.detail,
    required this.educationLink,
    required this.articleId,
    this.compareType,
  });

  final InsightKind kind;
  final String title;
  final String detail;
  final String educationLink;

  /// Verweist auf einen Artikel im Wissens-Hub (Katalog).
  final String articleId;

  /// Bei Dopplungen: Vertragsart, deren Verträge inhaltlich verglichen werden.
  final String? compareType;
}

/// Vermögens-/Konto-Arten, bei denen mehrere Verträge normal sind und
/// deshalb nicht als Dopplung gelten.
const _noDuplicateTypes = {
  'depot',
  'sparplan',
  'tagesgeld_festgeld',
  'liquiditaetsreserve',
};

/// Kennzahlen + Beobachtungen, deterministisch aus dem Vertragsbestand
/// abgeleitet. Eine Messung — keine Bewertung, keine Produktnennung.
class FinInsights {
  FinInsights._({
    required this.contractCount,
    required this.coveredAreas,
    required this.totalAreas,
    required this.monthlySpendEur,
    required this.estimatedMonthlyPensionEur,
    required this.insights,
  });

  final int contractCount;
  final int coveredAreas;
  final int totalAreas;
  final double monthlySpendEur;
  final double? estimatedMonthlyPensionEur;
  final List<Insight> insights;

  /// Abdeckungsgrad als Messwert 0–100 (Anteil erfasster Grundbedarf-Bereiche).
  int get score =>
      totalAreas == 0 ? 0 : ((coveredAreas / totalAreas) * 100).round();

  factory FinInsights.from(List<ExtractionResult> contracts) {
    final byType = <String, List<ExtractionResult>>{};
    for (final c in contracts) {
      final type = c.contractType;
      if (type != null) byType.putIfAbsent(type, () => []).add(c);
    }

    double spend = 0;
    for (final c in contracts) {
      spend += c.monthlyPremiumEur ?? 0;
    }

    double? pension;
    for (final c in byType['altersvorsorge'] ?? const <ExtractionResult>[]) {
      final expected =
          (c.contract['expectedMonthlyPension'] as Map?)?['amount'] as num?;
      if (expected != null) pension = (pension ?? 0) + expected.toDouble();
    }

    // Abdeckung gegen die Stufe-1-Kategorien (existenzieller Kern).
    final level1 = catalogController.categoriesByLevel[1]
            ?.map((c) => c.key)
            .toList() ??
        const [
          'privathaftpflicht',
          'berufsunfaehigkeit',
          'krankenversicherung',
          'pflegeversicherung',
          'risikolebensversicherung',
          'hausratversicherung',
        ];
    final covered = level1.where(byType.containsKey).length;

    final insights = <Insight>[
      // Dopplungen: mehrere Policen desselben Typs (außer Vermögen/Konten).
      for (final entry in byType.entries)
        if (!_noDuplicateTypes.contains(entry.key) && entry.value.length > 1)
          Insight(
            kind: InsightKind.duplicate,
            title: t(
              '${entry.value.length} ${catalogController.typeName(entry.key)}-Policen im Bestand',
              '${entry.value.length} ${catalogController.typeName(entry.key)} policies on file',
            ),
            detail: t(
              '${entry.value.map((c) => c.insurerName ?? 'Unbekannt').join(' und ')}, '
                  'zusammen ${formatEur(entry.value.fold<double>(0, (s, c) => s + (c.monthlyPremiumEur ?? 0)) * 12, decimals: 0)} pro Jahr.',
              '${entry.value.map((c) => c.insurerName ?? 'Unknown').join(' and ')}, '
                  'together ${formatEur(entry.value.fold<double>(0, (s, c) => s + (c.monthlyPremiumEur ?? 0)) * 12, decimals: 0)} per year.',
            ),
            educationLink:
                t('Was bedeutet eine Dopplung?', 'What does a duplicate mean?'),
            articleId: 'duplicate',
            compareType: entry.key,
          ),
      // Lücken: nicht im Bestand erfasste Kernbereiche.
      if (!byType.containsKey('berufsunfaehigkeit'))
        Insight(
          kind: InsightKind.missing,
          title: t('Keine Berufsunfähigkeitsversicherung erfasst',
              'No disability insurance on file'),
          detail: t('In deinen Unterlagen ist keine BU-Police vorhanden.',
              'There is no disability policy in your records.'),
          educationLink:
              t('Wie funktioniert eine BU?', 'How does disability cover work?'),
          articleId: 'bu',
        ),
      if (!byType.containsKey('privathaftpflicht'))
        Insight(
          kind: InsightKind.missing,
          title: t('Keine Privathaftpflicht erfasst',
              'No personal liability on file'),
          detail: t(
              'In deinen Unterlagen ist keine Haftpflicht-Police vorhanden.',
              'There is no liability policy in your records.'),
          educationLink: t('Was deckt eine Privathaftpflicht ab?',
              'What does personal liability cover?'),
          articleId: 'haftpflicht',
        ),
      // Zahlen im Vergleich: laufende Fondskosten.
      for (final depot in byType['depot'] ?? const <ExtractionResult>[])
        for (final pos in (depot.contract['positions'] as List? ?? const []))
          if (pos is Map && pos['ter'] is num && (pos['ter'] as num) >= 1.0)
            Insight(
              kind: InsightKind.comparison,
              title: t(
                'Laufende Kosten ${(pos['ter'] as num).toString().replaceAll('.', ',')} % p.a.',
                'Ongoing cost ${(pos['ter'] as num)} % p.a.',
              ),
              detail: t(
                '${pos['name'] ?? 'Fondsposition'} — breite Index-ETFs liegen im Schnitt bei etwa 0,2 % p.a.',
                '${pos['name'] ?? 'Fund position'} — broad index ETFs average around 0.2 % p.a.',
              ),
              educationLink: t('Was sind laufende Fondskosten (TER)?',
                  'What are ongoing fund costs (TER)?'),
              articleId: 'ter',
            ),
    ];

    return FinInsights._(
      contractCount: contracts.length,
      coveredAreas: covered,
      totalAreas: level1.length,
      monthlySpendEur: spend,
      estimatedMonthlyPensionEur: pension,
      insights: insights,
    );
  }
}
