import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../data/catalog_controller.dart';
import '../data/contracts_controller.dart';
import '../data/de_format.dart';
import '../data/extraction_result.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';

/// Inhaltlicher Vergleich gleichartiger Verträge — Kriterium für Kriterium.
/// Reine Fakten: zeigt, was enthalten ist, plus „X von N". Kein Sieger,
/// keine Empfehlung (Stage-1-Leitplanke).
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key, required this.contractType});
  final String contractType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListenableBuilder(
        listenable: Listenable.merge([contractsController, catalogController]),
        builder: (context, _) {
          final contracts = contractsController.contracts
              .where((c) => c.contractType == contractType)
              .toList();
          final criteria = catalogController.criteriaFor(contractType);
          final compareFields = catalogController
              .fieldsFor(contractType)
              .where((f) =>
                  f.kind == FieldKind.money ||
                  f.kind == FieldKind.choice ||
                  f.kind == FieldKind.intNum)
              .toList();
          final typeName = catalogController.typeName(contractType);

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Kicker(typeName),
              const SizedBox(height: Sp.sm),
              Text(t('Inhalt vergleichen', 'Compare content'),
                  style: serif(size: 28, color: context.inkColor)),
              const SizedBox(height: Sp.md),
              Text(
                t('Nicht nur der Preis zählt — auch was drinsteht. Reine Fakten, du entscheidest.',
                    'Price isn\'t everything — content matters too. Just facts, you decide.'),
                style: TextStyle(
                    color: context.mutedColor, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: Sp.xl),
              // Kopf: Anbieter je Spalte
              _Row(
                label: '',
                cells: [
                  for (final c in contracts)
                    Text(c.insurerName ?? '—',
                        textAlign: TextAlign.center,
                        style: serif(
                            size: 14, color: context.inkColor, spacing: 0)),
                ],
              ),
              const Hairline(),
              // Vollständigkeit (Messung, keine Wertung)
              _Row(
                label: t('Enthalten', 'Included'),
                emphasize: true,
                cells: [
                  for (final c in contracts)
                    Text(
                      criteria.isEmpty
                          ? '—'
                          : '${_countIncluded(c, criteria)}/${criteria.length}',
                      textAlign: TextAlign.center,
                      style: serif(
                          size: 18, color: context.accentColor, spacing: 0),
                    ),
                ],
              ),
              const Hairline(),
              const SizedBox(height: Sp.lg),
              if (compareFields.isNotEmpty) ...[
                Kicker(t('Eckdaten', 'Key figures')),
                const SizedBox(height: Sp.sm),
                const Hairline(),
                _Row(
                  label: t('Beitrag / Monat', 'Premium / month'),
                  cells: [
                    for (final c in contracts)
                      _valueCell(
                          context,
                          c.monthlyPremiumEur != null
                              ? formatEur(c.monthlyPremiumEur!)
                              : '—'),
                  ],
                ),
                const Hairline(),
                for (final f in compareFields) ...[
                  _Row(
                    label: f.label,
                    cells: [
                      for (final c in contracts)
                        _valueCell(context,
                            formatFieldValue(c.contract[f.fieldKey])),
                    ],
                  ),
                  const Hairline(),
                ],
                const SizedBox(height: Sp.lg),
              ],
              if (criteria.isNotEmpty) ...[
                Kicker(t('Leistungsmerkmale', 'Coverage features')),
                const SizedBox(height: Sp.sm),
                const Hairline(),
                for (final cr in criteria) ...[
                  _Row(
                    label: cr.label,
                    cells: [
                      for (final c in contracts) _critCell(context, c, cr.key),
                    ],
                  ),
                  const Hairline(),
                ],
              ] else ...[
                Text(
                  t('Für diese Vertragsart sind noch keine Leistungsmerkmale hinterlegt.',
                      'No coverage features are recorded for this contract type yet.'),
                  style: TextStyle(color: context.mutedColor, fontSize: 13),
                ),
              ],
              const SizedBox(height: Sp.xl),
              Text(
                t('Vergleich anhand fester Merkmale. Keine Empfehlung — was zu dir passt, hängt von deiner Situation ab.',
                    'Comparison against fixed features. Not a recommendation — what fits you depends on your situation.'),
                style: serif(
                    size: 12.5,
                    color: context.mutedColor,
                    spacing: 0,
                    height: 1.5,
                    style: FontStyle.italic),
              ),
            ],
          );
        },
      ),
    );
  }

  int _countIncluded(ExtractionResult c, List<ContractCriterion> criteria) {
    final map = (c.contract['criteria'] as Map?) ?? const {};
    return criteria.where((cr) => map[cr.key] == true).length;
  }

  Widget _valueCell(BuildContext context, String value) => Text(
        value,
        textAlign: TextAlign.center,
        style: serif(size: 14, color: context.inkColor, spacing: 0),
      );

  Widget _critCell(BuildContext context, ExtractionResult c, String key) {
    final map = (c.contract['criteria'] as Map?);
    final v = map?[key];
    if (v == true) {
      return Icon(Icons.check, size: 18, color: context.accentColor);
    }
    if (v == false) {
      return Icon(Icons.remove, size: 18, color: context.mutedColor);
    }
    return Text('?',
        textAlign: TextAlign.center,
        style: TextStyle(color: context.mutedColor, fontSize: 14));
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.cells, this.emphasize = false});
  final String label;
  final List<Widget> cells;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: TextStyle(
                fontSize: emphasize ? 13 : 12.5,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                color: emphasize ? context.inkColor : context.mutedColor,
                height: 1.3,
              ),
            ),
          ),
          for (final cell in cells)
            Expanded(child: Center(child: cell)),
        ],
      ),
    );
  }
}
