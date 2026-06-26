import 'package:flutter/material.dart';
import '../data/catalog_controller.dart';
import '../data/contracts_controller.dart';
import '../data/insights.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';
import 'compare_screen.dart';
import 'knowledge_screen.dart';

class ObservationsScreen extends StatelessWidget {
  const ObservationsScreen({super.key});

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
            final insights = contractsController.insights.insights;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Kicker(t('Anmerkungen', 'Notes')),
                const SizedBox(height: Sp.sm),
                Text(t('Beobachtungen', 'Observations'),
                    style: serif(size: 30, color: context.inkColor)),
                const SizedBox(height: Sp.md),
                Text(
                  t('Fakten aus deinen Unterlagen. Keine Empfehlungen.',
                      'Facts from your documents. No recommendations.'),
                  style: TextStyle(color: context.mutedColor, fontSize: 14),
                ),
                const SizedBox(height: Sp.xl),
                if (insights.isEmpty)
                  Text(
                    t('Aktuell keine Beobachtungen. Füge weitere Verträge hinzu, um dein Bild zu vervollständigen.',
                        'No observations yet. Add more contracts to complete your picture.'),
                    style: TextStyle(fontSize: 14, color: context.mutedColor),
                  ),
                for (var i = 0; i < insights.length; i++) ...[
                  if (i == 0) const Hairline(),
                  _InsightRow(insight: insights[i], index: i + 1),
                  const Hairline(),
                ],
                const SizedBox(height: Sp.xl),
                Text(
                  t('Wir messen. Wir empfehlen nicht.',
                      'We measure. We don\'t advise.'),
                  style: serif(
                      size: 13,
                      color: context.mutedColor,
                      spacing: 0,
                      style: FontStyle.italic),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight, required this.index});
  final Insight insight;
  final int index;

  @override
  Widget build(BuildContext context) {
    final (badge, color) = switch (insight.kind) {
      InsightKind.duplicate => (t('Dopplung', 'Duplicate'), context.terracotta),
      InsightKind.missing => (t('Nicht im Bestand', 'Not on file'), context.mutedColor),
      InsightKind.comparison => (t('Zahl im Vergleich', 'Figure in context'), context.accentColor),
    };
    final article = catalogController.article(insight.articleId);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('0$index'.substring(0, 2),
                style: serif(
                    size: 20, color: color, spacing: 0)),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 7),
                          decoration:
                              BoxDecoration(color: color, shape: BoxShape.circle)),
                      Text(badge,
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: color)),
                    ],
                  ),
                  const SizedBox(height: Sp.sm),
                  Text(insight.title,
                      style: serif(
                          size: 16, color: context.inkColor, spacing: 0)),
                  const SizedBox(height: 3),
                  Text(insight.detail,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: context.mutedColor,
                          height: 1.45)),
                  if (insight.compareType != null) ...[
                    const SizedBox(height: Sp.sm),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => CompareScreen(
                                contractType: insight.compareType!)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.compare_arrows,
                              size: 16, color: context.terracotta),
                          const SizedBox(width: 6),
                          Text(t('Inhalt vergleichen', 'Compare content'),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.terracotta)),
                        ],
                      ),
                    ),
                  ],
                  if (article != null) ...[
                    const SizedBox(height: Sp.sm),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                KnowledgeArticleScreen(article: article)),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(insight.educationLink,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: context.accentColor)),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 13, color: context.accentColor),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    );
  }
}
