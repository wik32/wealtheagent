import 'package:flutter/foundation.dart';
import 'extraction_result.dart';
import 'insights.dart';
import 'repository_provider.dart';

/// Zentrale, geteilte Vertragsdaten. Alle Tabs lauschen hierauf, damit
/// eine Änderung (neuer Vertrag, Bestätigung, Upload) sofort überall
/// sichtbar wird — der IndexedStack hält die Screens sonst statisch.
class ContractsController extends ChangeNotifier {
  List<ExtractionResult> _contracts = const [];
  bool _loading = false;
  bool _loaded = false;
  Object? _error;

  List<ExtractionResult> get contracts => _contracts;
  bool get loading => _loading;
  bool get loaded => _loaded;
  Object? get error => _error;

  FinInsights get insights => FinInsights.from(_contracts);

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _contracts = await contractsRepository().listContracts();
      _loaded = true;
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);

  /// Nach Login/Logout: Zustand verwerfen, damit kein fremder Bestand bleibt.
  void reset() {
    _contracts = const [];
    _loaded = false;
    _error = null;
    notifyListeners();
  }
}

/// App-weite Instanz (pragmatisch ohne DI-Framework).
final contractsController = ContractsController();
