import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import 'catalog.dart';
import 'catalog_repository.dart';

/// Globaler Zustand für den Vertragskatalog. Muster wie contractsController:
/// einmal laden, alle Screens lauschen via ListenableBuilder.
class CatalogController extends ChangeNotifier {
  Catalog? _catalog;
  bool _loading = false;

  Catalog? get catalog => _catalog;
  bool get isLoaded => _catalog != null;

  /// Lädt aus der DB; bei Fehler oder im Mock-Modus aus dem gebündelten Asset.
  Future<void> load({bool force = false}) async {
    if (_loading || (_catalog != null && !force)) return;
    _loading = true;
    try {
      if (AppConfig.hasBackend) {
        try {
          _catalog =
              await SupabaseCatalogRepository(Supabase.instance.client).load();
        } catch (e) {
          debugPrint('Katalog aus DB fehlgeschlagen, nutze Asset-Fallback: $e');
          _catalog = await const AssetCatalogRepository().load();
        }
      } else {
        _catalog = await const AssetCatalogRepository().load();
      }
    } catch (e) {
      debugPrint('Katalog konnte nicht geladen werden: $e');
      _catalog = Catalog(categories: const [], articles: const []);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void reset() {
    _catalog = null;
    notifyListeners();
  }

  // ---- Komfort-Lookups (mit sinnvollen Fallbacks, falls noch nicht geladen) --

  List<ContractCategory> get categories => _catalog?.categories ?? const [];
  List<KnowledgeArticle> get articles => _catalog?.articles ?? const [];
  Map<int, List<ContractCategory>> get categoriesByLevel =>
      _catalog?.byLevel ?? const {};

  ContractCategory? category(String? key) => _catalog?.byKey(key);
  List<ContractFieldSpec> fieldsFor(String key) =>
      _catalog?.fieldsFor(key) ?? const [];
  List<ContractCriterion> criteriaFor(String key) =>
      _catalog?.criteriaFor(key) ?? const [];
  KnowledgeArticle? article(String? slug) => _catalog?.articleBySlug(slug);

  /// Lokalisierter Name einer Vertragsart; Fallback: aufgehübschter Schlüssel.
  String typeName(String? key) {
    final c = category(key);
    if (c != null) return c.name;
    return key ?? '';
  }

  IconData typeIcon(String? key) =>
      category(key)?.iconData ?? Icons.description_outlined;

  /// Label eines Enum-Werts; mit Kategorie-Kontext genauer, sonst global.
  String enumLabel(String value, {String? categoryKey, String? fieldKey}) {
    final c = category(categoryKey);
    if (c != null) {
      for (final f in c.fields) {
        if (fieldKey != null && f.fieldKey != fieldKey) continue;
        final l = f.choiceLabel(value);
        if (l != null) return l;
      }
    }
    return _catalog?.enumLabelGlobal(value) ?? value;
  }

  /// Label eines Feldes (z.B. für die Anzeige im Prüfen-Screen).
  String fieldLabel(String categoryKey, String fieldKey) {
    for (final f in fieldsFor(categoryKey)) {
      if (f.fieldKey == fieldKey) return f.label;
    }
    return fieldKey;
  }
}

final catalogController = CatalogController();
