import 'dart:convert';

/// Spiegelt das JSON der Extraktions-Pipeline (`pipeline/src/extract.ts`).
/// Vertrag: `schemas/extracted-contract.schema.json` (schemaVersion 0.1.0).
enum ExtractionStatus { ok, needsReview, rejected }

ExtractionStatus _statusFrom(String raw) => switch (raw) {
      'ok' => ExtractionStatus.ok,
      'needs_review' => ExtractionStatus.needsReview,
      'rejected' => ExtractionStatus.rejected,
      _ => throw FormatException('Unbekannter Status: $raw'),
    };

class FieldAssessment {
  const FieldAssessment({required this.confidence, required this.needsReview});

  final double confidence;
  final bool needsReview;

  factory FieldAssessment.fromJson(Map<String, dynamic> json) =>
      FieldAssessment(
        confidence: (json['confidence'] as num).toDouble(),
        needsReview: json['needsReview'] as bool,
      );
}

class ExtractionResult {
  const ExtractionResult({
    required this.status,
    required this.provider,
    this.id,
    this.schemaVersion,
    this.contractType,
    this.contract = const {},
    this.fields = const {},
    this.reason,
  });

  /// Zeilen-ID in der contracts-Tabelle (null im Mock-Modus).
  final String? id;
  final ExtractionStatus status;
  final String provider;
  final String? schemaVersion;
  final String? contractType;

  /// Vertragsdaten als Map — die Feldnamen entsprechen den Zod-Schemas
  /// der Pipeline (provider, premium, coverageSum, positions, …).
  final Map<String, dynamic> contract;
  final Map<String, FieldAssessment> fields;
  final String? reason;

  factory ExtractionResult.fromJson(Map<String, dynamic> json) {
    final status = _statusFrom(json['status'] as String);
    if (status == ExtractionStatus.rejected) {
      return ExtractionResult(
        status: status,
        provider: json['provider'] as String,
        reason: json['reason'] as String?,
      );
    }
    return ExtractionResult(
      status: status,
      provider: json['provider'] as String,
      schemaVersion: json['schemaVersion'] as String?,
      contractType: json['contractType'] as String?,
      contract: (json['contract'] as Map).cast<String, dynamic>(),
      fields: (json['fields'] as Map).map(
        (k, v) => MapEntry(
          k as String,
          FieldAssessment.fromJson((v as Map).cast<String, dynamic>()),
        ),
      ),
    );
  }

  static ExtractionResult fromJsonString(String raw) =>
      ExtractionResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  String? get insurerName => contract['provider'] as String?;

  /// Monatlicher Beitrag in EUR, abgeleitet aus premium.amount + interval.
  double? get monthlyPremiumEur {
    final premium = contract['premium'];
    if (premium is! Map) return null;
    final amount = ((premium['amount'] as Map?)?['amount'] as num?)?.toDouble();
    if (amount == null) return null;
    final factor = switch (premium['interval'] as String?) {
      'monatlich' => 1.0,
      'vierteljaehrlich' => 1 / 3,
      'halbjaehrlich' => 1 / 6,
      'jaehrlich' => 1 / 12,
      _ => 0.0,
    };
    return amount * factor;
  }

  Iterable<String> get fieldsNeedingReview =>
      fields.entries.where((e) => e.value.needsReview).map((e) => e.key);
}
