import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'catalog.dart';

/// Lädt den Vertragskatalog. Quelle ist die DB (öffentlich lesbar); fällt der
/// Abruf aus oder läuft die App im Mock-Modus, greift das gebündelte
/// Offline-Fallback (assets/catalog.json).
abstract interface class CatalogRepository {
  Future<Catalog> load();
}

/// Liest die drei Katalog-Tabellen und setzt sie zur verschachtelten Struktur
/// zusammen, die Catalog.fromJson erwartet (Kategorien mit eingebetteten Feldern).
class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<Catalog> load() async {
    final cats = await _client
        .from('contract_categories')
        .select()
        .eq('active', true)
        .order('sort_order');
    final fields = await _client
        .from('contract_fields')
        .select()
        .eq('active', true)
        .order('sort_order');
    final articles = await _client
        .from('knowledge_articles')
        .select()
        .eq('active', true)
        .order('sort_order');
    // contract_criteria existiert evtl. noch nicht (Migration 0004) — tolerant.
    List<dynamic> criteria = const [];
    try {
      criteria = await _client
          .from('contract_criteria')
          .select()
          .eq('active', true)
          .order('sort_order');
    } catch (_) {}

    final fieldsByCat = <String, List<Map<String, dynamic>>>{};
    for (final f in fields) {
      final m = (f as Map).cast<String, dynamic>();
      fieldsByCat.putIfAbsent(m['category_key'] as String, () => []).add(m);
    }
    final critByCat = <String, List<Map<String, dynamic>>>{};
    for (final c in criteria) {
      final m = (c as Map).cast<String, dynamic>();
      critByCat.putIfAbsent(m['category_key'] as String, () => []).add(m);
    }

    final categories = [
      for (final c in cats)
        {
          ...(c as Map).cast<String, dynamic>(),
          'fields': fieldsByCat[c['key']] ?? const [],
          'criteria': critByCat[c['key']] ?? const [],
        }
    ];

    return Catalog.fromJson({
      'categories': categories,
      'articles': articles,
    });
  }
}

/// Gebündelter Offline-Katalog. Quelle bleibt mit dem DB-Seed synchron
/// (supabase/seed/generate_seed.mjs erzeugt beides aus assets/catalog.json).
class AssetCatalogRepository implements CatalogRepository {
  const AssetCatalogRepository();

  @override
  Future<Catalog> load() async {
    final raw = await rootBundle.loadString('assets/catalog.json');
    return Catalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
