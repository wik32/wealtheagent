import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../data/catalog_controller.dart';
import '../l10n.dart';
import '../theme.dart';
import 'knowledge_screen.dart';

/// Erklärungsblock zu einer Vertragsart (anerkannte Bedarfssystematik): wofür gedacht,
/// wie die Norm sie einordnet, worauf zu achten ist. Neutral, faktisch — keine
/// Empfehlung (Stage-1-Leitplanke).
class CategoryInfoScreen extends StatelessWidget {
  const CategoryInfoScreen({super.key, required this.categoryKey});
  final String categoryKey;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: catalogController,
      builder: (context, _) {
        final cat = catalogController.category(categoryKey);
        return Scaffold(
          appBar: AppBar(
            title: Text(cat?.name ?? ''),
          ),
          body: cat == null
              ? const Center(child: CircularProgressIndicator())
              : _body(context, cat),
        );
      },
    );
  }

  Widget _body(BuildContext context, ContractCategory cat) {
    final article = catalogController.articles
        .where((a) => a.contractKey == cat.key)
        .firstOrNull;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(cat.iconData, color: context.accentColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  _DefinoBadge(level: cat.definoLevel, field: cat.definoField),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (cat.purpose != null)
          _Section(
            icon: Icons.lightbulb_outline,
            title: t('Wofür ist das gut?', 'What is it for?'),
            body: cat.purpose!,
          ),
        if (cat.relevance != null)
          _Section(
            icon: Icons.account_tree_outlined,
            title: t('Einordnung nach Bedarfssystematik',
                'Classification by needs hierarchy'),
            body: cat.relevance!,
          ),
        if (cat.watch != null)
          _Section(
            icon: Icons.search_outlined,
            title: t('Worauf achten?', 'What to look out for?'),
            body: cat.watch!,
          ),
        if (article != null) ...[
          const SizedBox(height: 4),
          OutlinedButton.icon(
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(t('Mehr im Wissens-Hub', 'More in the learn hub')),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => KnowledgeArticleScreen(article: article)),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            t(
              'Allgemeine Information, keine individuelle Empfehlung. Wir messen — '
                  'ob ein Vertrag für dich sinnvoll ist, hängt von deiner Situation ab.',
              'General information, not individual advice. We measure — whether a '
                  'contract makes sense for you depends on your situation.',
            ),
            style: TextStyle(
                fontSize: 12.5, height: 1.5, color: context.mutedColor),
          ),
        ),
      ],
    );
  }
}

class _DefinoBadge extends StatelessWidget {
  const _DefinoBadge({required this.level, required this.field});
  final int level;
  final String? field;

  @override
  Widget build(BuildContext context) {
    final label = field == null
        ? '${t('Stufe', 'Level')} $level · ${definoLevelName(level)}'
        : '${t('Stufe', 'Level')} $level · ${definoLevelName(level)} · $field';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: context.accentColor)),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: context.accentColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: TextStyle(
                  fontSize: 14, height: 1.6, color: context.inkColor)),
        ],
      ),
    );
  }
}
