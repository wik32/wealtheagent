import 'extraction_result.dart';

/// Datenzugriff der App. Die Supabase-Implementierung liest aus der
/// contracts-Tabelle; die Screens hängen nur an dieser Schnittstelle.
abstract interface class ContractsRepository {
  Future<List<ExtractionResult>> listContracts();
  Future<ExtractionResult> submitDocument(String filePath);

  /// Nutzer hat die Daten geprüft (ggf. korrigiert) und bestätigt.
  Future<void> confirmContract(ExtractionResult result,
      {Map<String, dynamic>? correctedData});

  /// Vertrag von Hand angelegt (unabhängig von der Foto-Extraktion).
  Future<ExtractionResult> addManualContract(
      String contractType, Map<String, dynamic> data);

  /// Vertrag löschen.
  Future<void> deleteContract(ExtractionResult result);

  /// Onboarding-Antworten (progressive Profilanreicherung).
  Future<void> saveProfile(Map<String, dynamic> profile);
}

/// Baut eine Felder-Map (alle sicher, kein Review) aus manuell erfassten Daten.
Map<String, FieldAssessment> confidentFields(Map<String, dynamic> data) => {
      for (final key in data.keys)
        key: const FieldAssessment(confidence: 1, needsReview: false),
    };

/// Automatisches Auslesen war nicht möglich (Edge Function/AI nicht verfügbar).
/// Die App bietet dem Nutzer dann die manuelle Erfassung an.
class ExtractionUnavailable implements Exception {
  const ExtractionUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

Map<String, dynamic> _eur(num amount) => {'amount': amount, 'currency': 'EUR'};

Map<String, dynamic> _premium(num amount, String interval) =>
    {'amount': _eur(amount), 'interval': interval};

ExtractionResult _contract(
  String type,
  Map<String, dynamic> data, {
  Map<String, double> confidence = const {},
}) {
  final fields = <String, FieldAssessment>{
    for (final key in data.keys)
      key: FieldAssessment(
        confidence: confidence[key] ?? 0.99,
        needsReview: (confidence[key] ?? 0.99) < 0.8,
      ),
  };
  final anyReview = fields.values.any((f) => f.needsReview);
  return ExtractionResult(
    status: anyReview ? ExtractionStatus.needsReview : ExtractionStatus.ok,
    provider: 'mock',
    schemaVersion: '0.1.0',
    contractType: type,
    contract: {...data, 'contractType': type},
    fields: fields,
  );
}

/// Mock-Bestand für Demo & Tests — gleiche Struktur wie Pipeline-Output.
/// Enthält bewusst eine Dopplung (2x Haftpflicht), eine Lücke (keine BU)
/// und einen teuren Fonds, damit alle Beobachtungs-Arten sichtbar sind.
class MockContractsRepository implements ContractsRepository {
  static final _contracts = [
    _contract('privathaftpflicht', {
      'provider': 'HUK-COBURG',
      'contractNumber': 'PH-4471-882',
      'startDate': '2019-03-01',
      'endDate': null,
      'premium': _premium(58.9, 'jaehrlich'),
      'coverageSum': _eur(10000000),
      'deductible': null,
      'insuredPersons': 'single',
      'criteria': {
        'forderungsausfall': true,
        'schluesselverlust': true,
        'deliktunfaehige': true,
        'gefaelligkeitsschaeden': true,
        'mietsachschaeden': true,
        'auslandsdeckung': true,
        'allmaehlichkeitsschaeden': false,
        'bestleistungsgarantie': true,
      },
    }, confidence: {
      'startDate': 0.62,
    }),
    _contract('privathaftpflicht', {
      'provider': 'AXA',
      'contractNumber': 'HV-2020-5512',
      'startDate': '2020-08-01',
      'endDate': null,
      'premium': _premium(59.1, 'jaehrlich'),
      'coverageSum': _eur(5000000),
      'deductible': _eur(150),
      'insuredPersons': 'single',
      'criteria': {
        'forderungsausfall': false,
        'schluesselverlust': true,
        'deliktunfaehige': false,
        'gefaelligkeitsschaeden': true,
        'mietsachschaeden': true,
        'auslandsdeckung': false,
        'allmaehlichkeitsschaeden': false,
        'bestleistungsgarantie': false,
      },
    }),
    _contract('krankenversicherung', {
      'provider': 'ERGO',
      'contractNumber': 'ZZ-88-291004',
      'startDate': '2022-01-01',
      'endDate': null,
      'premium': _premium(24.9, 'monatlich'),
      'kind': 'zusatz_zahn',
      'tariff': 'ZahnPremium ZEZ80',
      'reimbursementPercent': 80,
      'annualLimit': _eur(2500),
    }),
    _contract('lebensversicherung', {
      'provider': 'Hannoversche',
      'contractNumber': 'RL-555-09812',
      'startDate': '2020-10-01',
      'endDate': '2045-09-30',
      'premium': _premium(214.8, 'jaehrlich'),
      'kind': 'risikoleben',
      'sumInsured': _eur(300000),
      'beneficiary': 'Erika Mustermann',
      'surrenderValue': null,
    }),
    _contract('depot', {
      'provider': 'DWS',
      'contractNumber': '7720451-001',
      'startDate': null,
      'endDate': null,
      'premium': null,
      'custodian': 'DWS',
      'totalValue': _eur(24651.25),
      'asOfDate': '2026-05-31',
      'positions': [
        {
          'name': 'Xtrackers MSCI World UCITS ETF',
          'isin': 'IE00BJ0KDQ92',
          'units': 120.5,
          'marketValue': _eur(13250.75),
          'ter': 0.19,
        },
        {
          'name': 'DWS Top Dividende LD',
          'isin': 'DE0009848119',
          'units': 45,
          'marketValue': _eur(6480),
          'ter': 1.45,
        },
      ],
    }),
    _contract('altersvorsorge', {
      'provider': 'Allianz',
      'contractNumber': 'PR-90-441872',
      'startDate': '2018-12-01',
      'endDate': null,
      'premium': _premium(150, 'monatlich'),
      'kind': 'privat',
      'expectedMonthlyPension': _eur(485),
      'guaranteedMonthlyPension': _eur(312),
      'retirementAge': 67,
      'currentBalance': _eur(18420.33),
    }),
    _contract('hausratversicherung', {
      'provider': 'Allianz',
      'contractNumber': 'HR-2021-7781',
      'startDate': '2021-04-01',
      'premium': _premium(7.5, 'monatlich'),
      'insuredSum': _eur(65000),
      'livingSpaceSqm': 72,
    }),
    _contract('unfallversicherung', {
      'provider': 'DEVK',
      'contractNumber': 'UV-55-200931',
      'startDate': '2020-02-01',
      'premium': _premium(98, 'jaehrlich'),
      'invaliditySum': _eur(150000),
      'progression': 225,
    }),
    _contract('rechtsschutzversicherung', {
      'provider': 'ARAG',
      'contractNumber': 'RS-11-664820',
      'startDate': '2019-09-01',
      'premium': _premium(210, 'jaehrlich'),
      'scope': 'kombi',
      'deductible': _eur(150),
    }),
    _contract('pflegeversicherung', {
      'provider': 'Barmenia',
      'contractNumber': 'PF-77-301288',
      'startDate': '2023-01-01',
      'premium': _premium(28, 'monatlich'),
      'kind': 'pflegetagegeld',
      'monthlyBenefit': _eur(1500),
    }),
    _contract('liquiditaetsreserve', {
      'provider': 'DKB',
      'accountType': 'tagesgeld',
      'balance': _eur(8500),
      'asOfDate': '2026-05-31',
    }),
  ];

  @override
  Future<List<ExtractionResult>> listContracts() async => _contracts;

  @override
  Future<ExtractionResult> submitDocument(String filePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _contracts.first;
  }

  @override
  Future<ExtractionResult> addManualContract(
      String contractType, Map<String, dynamic> data) async {
    final result = ExtractionResult(
      id: 'mock-${DateTime.now().microsecondsSinceEpoch}',
      status: ExtractionStatus.ok,
      provider: 'mock',
      schemaVersion: '0.1.0',
      contractType: contractType,
      contract: {...data, 'contractType': contractType},
      fields: confidentFields(data),
    );
    _contracts.insert(0, result);
    return result;
  }

  @override
  Future<void> deleteContract(ExtractionResult result) async {
    _contracts.removeWhere((c) => c.id == result.id);
  }

  @override
  Future<void> confirmContract(ExtractionResult result,
      {Map<String, dynamic>? correctedData}) async {
    if (correctedData == null || result.id == null) return;
    final i = _contracts.indexWhere((c) => c.id == result.id);
    if (i < 0) return;
    _contracts[i] = ExtractionResult(
      id: result.id,
      status: ExtractionStatus.ok,
      provider: result.provider,
      schemaVersion: result.schemaVersion,
      contractType: result.contractType,
      contract: {...correctedData, 'contractType': result.contractType},
      fields: confidentFields(correctedData),
    );
  }

  @override
  Future<void> saveProfile(Map<String, dynamic> profile) async {}
}
