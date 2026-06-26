import 'package:flutter/material.dart';
import '../data/catalog_controller.dart';
import '../data/contracts_controller.dart';
import '../data/de_format.dart';
import '../data/insights.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';
import 'add_contract_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable:
              Listenable.merge([contractsController, catalogController]),
          builder: (context, _) {
            if (contractsController.loading && !contractsController.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final insights = contractsController.insights;
            return RefreshIndicator(
              onRefresh: contractsController.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Kicker(t('Übersicht', 'Overview')),
                      Text(t('Hallo', 'Hello'),
                          style: TextStyle(
                              color: context.mutedColor, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: Sp.md),
                  Container(height: 2, color: context.accentColor),
                  const SizedBox(height: Sp.xxl),
                  if (insights.contractCount == 0)
                    const _EmptyState()
                  else
                    _Overview(insights: insights),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.insights});
  final FinInsights insights;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score als Statement
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${insights.score}',
                style: serif(size: 76, color: context.inkColor, height: .9)),
            const SizedBox(width: Sp.md),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('von 100', 'of 100'),
                      style: serif(
                          size: 15, color: context.mutedColor, spacing: 0)),
                  const SizedBox(height: 2),
                  Text(t('Dein Finanzbild', 'Your financial picture'),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.terracotta)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Sp.lg),
        // feine Fortschrittslinie
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: insights.score / 100,
            minHeight: 5,
            backgroundColor: context.borderColor,
            valueColor: AlwaysStoppedAnimation(context.accentColor),
          ),
        ),
        const SizedBox(height: Sp.lg),
        Text(
          t('${insights.contractCount} Verträge erfasst. Eine Messung – keine Bewertung.',
              '${insights.contractCount} contracts on file. A measurement – not a rating.'),
          style:
              TextStyle(color: context.mutedColor, fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: Sp.xl),
        const Hairline(),
        StatRow(
          label: t('Grundabsicherung', 'Basic protection'),
          value: '${insights.coveredAreas} / ${insights.totalAreas}',
        ),
        const Hairline(),
        StatRow(
          label: t('Ausgaben / Monat', 'Spending / month'),
          value: formatEur(insights.monthlySpendEur, decimals: 0),
          valueColor: context.terracotta,
        ),
        const Hairline(),
        StatRow(
          label: t('Rente · Prognose', 'Pension · estimate'),
          value: insights.estimatedMonthlyPensionEur != null
              ? formatEur(insights.estimatedMonthlyPensionEur!, decimals: 0)
              : '—',
        ),
        const Hairline(),
        const SizedBox(height: Sp.xl),
        if (insights.insights.isNotEmpty)
          PullQuote(
            kicker: t('${insights.insights.length} Beobachtungen',
                '${insights.insights.length} observations'),
            text: t('Fakten warten in deinem Bericht.',
                'Facts are waiting in your report.'),
          ),
        const SizedBox(height: Sp.xl),
        Text(
          t('Wir messen. Wir empfehlen nicht.', 'We measure. We don\'t advise.'),
          style: serif(
              size: 13,
              color: context.mutedColor,
              spacing: 0,
              style: FontStyle.italic),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('Noch keine Verträge erfasst', 'No contracts yet'),
            style: serif(size: 24, color: context.inkColor)),
        const SizedBox(height: Sp.md),
        Text(
          t('Füge deinen ersten Vertrag hinzu — per Foto oder von Hand.',
              'Add your first contract — by photo or by hand.'),
          style:
              TextStyle(fontSize: 14, color: context.mutedColor, height: 1.55),
        ),
        const SizedBox(height: Sp.xl),
        FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddContractScreen()),
          ),
          child: Text(t('Vertrag hinzufügen', 'Add contract')),
        ),
      ],
    );
  }
}
