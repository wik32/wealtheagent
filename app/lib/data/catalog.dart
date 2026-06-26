import 'package:flutter/material.dart';
import '../l10n.dart';

/// Vertragskatalog (DIN 77230 / Defino) — Kategorien, Formularfelder und
/// Wissensartikel. Wird zentral aus der DB bzw. dem gebündelten Fallback
/// geladen (catalog_repository.dart) und über catalogController bereitgestellt.

/// Defino-Stufen (Bedarfspyramide).
String definoLevelName(int level) => switch (level) {
      1 => t('Grundabsicherung', 'Basic protection'),
      2 => t('Lebensstandard', 'Standard of living'),
      3 => t('Vermögensaufbau', 'Wealth building'),
      _ => '',
    };

/// Feldtypen für den generischen Erfassungs-Dialog.
enum FieldKind { text, date, money, premium, intNum, boolean, choice }

FieldKind _kindFrom(String raw) => switch (raw) {
      'text' => FieldKind.text,
      'date' => FieldKind.date,
      'money' => FieldKind.money,
      'premium' => FieldKind.premium,
      'int' => FieldKind.intNum,
      'bool' => FieldKind.boolean,
      'choice' => FieldKind.choice,
      _ => FieldKind.text,
    };

class ContractFieldChoice {
  const ContractFieldChoice(this.value, this.labelDe, this.labelEn);
  final String value;
  final String labelDe;
  final String labelEn;

  String get label => isEnglish ? labelEn : labelDe;

  factory ContractFieldChoice.fromJson(Map<String, dynamic> j) =>
      ContractFieldChoice(
        j['value'] as String,
        (j['label_de'] ?? j['value']) as String,
        (j['label_en'] ?? j['label_de'] ?? j['value']) as String,
      );
}

class ContractFieldSpec {
  const ContractFieldSpec({
    required this.fieldKey,
    required this.kind,
    required this.labelDe,
    required this.labelEn,
    required this.sortOrder,
    required this.required,
    required this.choices,
  });

  final String fieldKey;
  final FieldKind kind;
  final String labelDe;
  final String labelEn;
  final int sortOrder;
  final bool required;
  final List<ContractFieldChoice> choices;

  String get label => isEnglish ? labelEn : labelDe;

  String? choiceLabel(String? value) {
    if (value == null) return null;
    for (final c in choices) {
      if (c.value == value) return c.label;
    }
    return null;
  }

  factory ContractFieldSpec.fromJson(Map<String, dynamic> j) =>
      ContractFieldSpec(
        fieldKey: j['field_key'] as String,
        kind: _kindFrom(j['kind'] as String),
        labelDe: j['label_de'] as String,
        labelEn: (j['label_en'] ?? j['label_de']) as String,
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
        required: j['required'] as bool? ?? false,
        choices: ((j['choices'] as List?) ?? const [])
            .map((c) =>
                ContractFieldChoice.fromJson((c as Map).cast<String, dynamic>()))
            .toList(),
      );
}

/// Leistungskriterium (Bedingungs-/Leistungsanalyse) — getrennt von den
/// Erfassungsfeldern. Sagt, WELCHES inhaltliche Merkmal verglichen werden kann.
class ContractCriterion {
  const ContractCriterion(this.key, this.labelDe, this.labelEn, this.sortOrder);
  final String key;
  final String labelDe;
  final String labelEn;
  final int sortOrder;

  String get label => isEnglish ? labelEn : labelDe;

  factory ContractCriterion.fromJson(Map<String, dynamic> j) =>
      ContractCriterion(
        j['criterion_key'] as String? ?? j['key'] as String,
        j['label_de'] as String,
        (j['label_en'] ?? j['label_de']) as String,
        (j['sort_order'] as num?)?.toInt() ?? 0,
      );
}

class ContractCategory {
  const ContractCategory({
    required this.key,
    required this.definoLevel,
    required this.definoField,
    required this.nameDe,
    required this.nameEn,
    required this.icon,
    required this.sortOrder,
    required this.purposeDe,
    required this.purposeEn,
    required this.relevanceDe,
    required this.relevanceEn,
    required this.watchDe,
    required this.watchEn,
    required this.fields,
    required this.criteria,
  });

  final String key;
  final int definoLevel;
  final String? definoField;
  final String nameDe;
  final String nameEn;
  final String icon;
  final int sortOrder;
  final String? purposeDe;
  final String? purposeEn;
  final String? relevanceDe;
  final String? relevanceEn;
  final String? watchDe;
  final String? watchEn;
  final List<ContractFieldSpec> fields;
  final List<ContractCriterion> criteria;

  String get name => isEnglish ? nameEn : nameDe;
  String? get purpose => isEnglish ? purposeEn : purposeDe;
  String? get relevance => isEnglish ? relevanceEn : relevanceDe;
  String? get watch => isEnglish ? watchEn : watchDe;
  IconData get iconData => catalogIcons[icon] ?? Icons.description_outlined;

  factory ContractCategory.fromJson(Map<String, dynamic> j) {
    final fields = ((j['fields'] as List?) ?? const [])
        .map((f) =>
            ContractFieldSpec.fromJson((f as Map).cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final criteria = ((j['criteria'] as List?) ?? const [])
        .map((c) =>
            ContractCriterion.fromJson((c as Map).cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return ContractCategory(
      key: j['key'] as String,
      definoLevel: (j['defino_level'] as num?)?.toInt() ?? 1,
      definoField: j['defino_field'] as String?,
      nameDe: j['name_de'] as String,
      nameEn: (j['name_en'] ?? j['name_de']) as String,
      icon: j['icon'] as String? ?? 'shield',
      sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
      purposeDe: j['purpose_de'] as String?,
      purposeEn: j['purpose_en'] as String?,
      relevanceDe: j['relevance_de'] as String?,
      relevanceEn: j['relevance_en'] as String?,
      watchDe: j['watch_de'] as String?,
      watchEn: j['watch_en'] as String?,
      fields: fields,
      criteria: criteria,
    );
  }
}

class KnowledgeArticle {
  const KnowledgeArticle({
    required this.slug,
    required this.categoryDe,
    required this.categoryEn,
    required this.titleDe,
    required this.titleEn,
    required this.bodyDe,
    required this.bodyEn,
    required this.contractKey,
    required this.sortOrder,
  });

  final String slug;
  final String categoryDe;
  final String categoryEn;
  final String titleDe;
  final String titleEn;
  final List<String> bodyDe;
  final List<String> bodyEn;
  final String? contractKey;
  final int sortOrder;

  String get category => isEnglish ? categoryEn : categoryDe;
  String get title => isEnglish ? titleEn : titleDe;
  List<String> get body => isEnglish ? bodyEn : bodyDe;

  factory KnowledgeArticle.fromJson(Map<String, dynamic> j) {
    List<String> body(dynamic v) =>
        ((v as List?) ?? const []).map((e) => e.toString()).toList();
    return KnowledgeArticle(
      slug: j['slug'] as String,
      categoryDe: j['category_de'] as String,
      categoryEn: (j['category_en'] ?? j['category_de']) as String,
      titleDe: j['title_de'] as String,
      titleEn: (j['title_en'] ?? j['title_de']) as String,
      bodyDe: body(j['body_de']),
      bodyEn: j['body_en'] != null ? body(j['body_en']) : body(j['body_de']),
      contractKey: j['contract_key'] as String?,
      sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Geladener Katalog (Kategorien + Artikel) mit Komfort-Lookups.
class Catalog {
  Catalog({required this.categories, required this.articles});

  final List<ContractCategory> categories;
  final List<KnowledgeArticle> articles;

  late final Map<String, ContractCategory> _byKey = {
    for (final c in categories) c.key: c,
  };

  ContractCategory? byKey(String? key) => key == null ? null : _byKey[key];

  List<ContractFieldSpec> fieldsFor(String key) => _byKey[key]?.fields ?? const [];
  List<ContractCriterion> criteriaFor(String key) =>
      _byKey[key]?.criteria ?? const [];

  /// Kategorien nach Defino-Stufe (1→3), innerhalb der Stufe nach sort_order.
  Map<int, List<ContractCategory>> get byLevel {
    final out = <int, List<ContractCategory>>{};
    for (final c in categories) {
      out.putIfAbsent(c.definoLevel, () => []).add(c);
    }
    for (final list in out.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    return out;
  }

  KnowledgeArticle? articleBySlug(String? slug) {
    if (slug == null) return null;
    for (final a in articles) {
      if (a.slug == slug) return a;
    }
    return null;
  }

  /// Lesbares Label für einen Enum-Wert über alle Felder hinweg (für die
  /// generische Anzeige, wenn der Kontext nicht bekannt ist).
  String? enumLabelGlobal(String value) {
    for (final c in categories) {
      for (final f in c.fields) {
        final l = f.choiceLabel(value);
        if (l != null) return l;
      }
    }
    return null;
  }

  factory Catalog.fromJson(Map<String, dynamic> j) {
    final cats = ((j['categories'] as List?) ?? const [])
        .map((c) => ContractCategory.fromJson((c as Map).cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final arts = ((j['articles'] as List?) ?? const [])
        .map((a) => KnowledgeArticle.fromJson((a as Map).cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Catalog(categories: cats, articles: arts);
  }
}

/// DB-Icon-Schlüssel → Material-Icon. (IconData kann nicht direkt aus der DB
/// kommen — Tree-Shaking. Neue Schlüssel hier ergänzen; Fallback ist gesetzt.)
const catalogIcons = <String, IconData>{
  'shield': Icons.shield_outlined,
  'paw': Icons.pets,
  'briefcase': Icons.work_outline,
  'health': Icons.favorite_outline,
  'income': Icons.payments_outlined,
  'elderly': Icons.elderly,
  'umbrella': Icons.umbrella_outlined,
  'healing': Icons.healing,
  'sofa': Icons.chair_outlined,
  'house': Icons.house_outlined,
  'gavel': Icons.gavel,
  'car': Icons.directions_car_outlined,
  'wallet': Icons.account_balance_wallet_outlined,
  'savings': Icons.savings_outlined,
  'family': Icons.family_restroom,
  'apartment': Icons.apartment,
  'foundation': Icons.foundation,
  'chart': Icons.show_chart,
  'trending': Icons.trending_up,
  'bank': Icons.account_balance,
  'candle': Icons.local_florist,
  'flight': Icons.flight_takeoff,
};
