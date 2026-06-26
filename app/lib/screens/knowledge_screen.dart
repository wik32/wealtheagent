import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../data/catalog_controller.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: catalogController,
          builder: (context, _) {
            final articles = catalogController.articles;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Kicker(t('Wissen', 'Learn')),
                const SizedBox(height: Sp.sm),
                Text(t('Hintergrund', 'Background'),
                    style: serif(size: 30, color: context.inkColor)),
                const SizedBox(height: Sp.md),
                Text(
                  t('Neutral erklärt – ohne Produktwerbung.',
                      'Explained neutrally – no product promotion.'),
                  style: TextStyle(color: context.mutedColor, fontSize: 14),
                ),
                const SizedBox(height: Sp.xl),
                if (!catalogController.isLoaded)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator())),
                for (final article in articles) ...[
                  const Hairline(),
                  _ArticleRow(article: article),
                ],
                if (articles.isNotEmpty) const Hairline(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article});
  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => KnowledgeArticleScreen(article: article)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(article.category),
                  const SizedBox(height: Sp.sm),
                  Text(article.title,
                      style: serif(
                          size: 17, color: context.inkColor, spacing: 0, height: 1.2)),
                ],
              ),
            ),
            const SizedBox(width: Sp.md),
            Icon(Icons.chevron_right, size: 18, color: context.mutedColor),
          ],
        ),
      ),
    );
  }
}

class KnowledgeArticleScreen extends StatelessWidget {
  const KnowledgeArticleScreen({super.key, required this.article});
  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Kicker(article.category),
          const SizedBox(height: Sp.md),
          Text(article.title,
              style: serif(size: 30, color: context.inkColor, height: 1.12)),
          const SizedBox(height: Sp.xl),
          for (final paragraph in article.body) ...[
            Text(paragraph,
                style: TextStyle(
                    fontSize: 15.5, height: 1.7, color: context.inkColor)),
            const SizedBox(height: Sp.lg),
          ],
          const SizedBox(height: Sp.sm),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF1E2A24)
                  : FinColors.greenSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: context.accentColor),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Text(
                    t('Allgemeine Information, keine Beratung im Einzelfall.',
                        'General information, not individual advice.'),
                    style:
                        TextStyle(fontSize: 12.5, color: context.inkColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
