import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'extraction_result.dart';
import 'contracts_repository.dart';

/// Echte Backend-Anbindung: Dokumente in den Storage-Bucket "documents",
/// extrahierte Verträge aus der Tabelle "contracts" (RLS: nur eigene Zeilen).
/// Die Extraktion selbst (Pipeline-Aufruf) folgt als Edge Function — bis
/// dahin bleiben hochgeladene Dokumente im Status "uploaded".
class SupabaseContractsRepository implements ContractsRepository {
  SupabaseContractsRepository(this._client);

  final SupabaseClient _client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Nicht angemeldet — Repository erfordert Auth.');
    }
    return user.id;
  }

  @override
  Future<List<ExtractionResult>> listContracts() async {
    final rows = await _client
        .from('contracts')
        .select()
        .order('created_at', ascending: false);
    return rows.map((row) {
      final base = ExtractionResult.fromJson({
        'status': row['status'] == 'confirmed' ? 'ok' : row['status'],
        'provider': 'supabase',
        'schemaVersion': row['schema_version'],
        'contractType': row['contract_type'],
        'contract': row['data'],
        'fields': row['fields'] ?? <String, dynamic>{},
      });
      return ExtractionResult(
        id: row['id'] as String?,
        status: base.status,
        provider: base.provider,
        schemaVersion: base.schemaVersion,
        contractType: base.contractType,
        contract: base.contract,
        fields: base.fields,
      );
    }).toList();
  }

  @override
  Future<void> confirmContract(ExtractionResult result,
      {Map<String, dynamic>? correctedData}) async {
    if (result.id == null) return;
    await _client.from('contracts').update({
      'data': ?correctedData,
      'status': 'confirmed',
      'user_confirmed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', result.id!);
  }

  @override
  Future<ExtractionResult> addManualContract(
      String contractType, Map<String, dynamic> data) async {
    final fields = confidentFields(data);
    final row = await _client
        .from('contracts')
        .insert({
          'user_id': _userId,
          'schema_version': '0.1.0',
          'contract_type': contractType,
          'status': 'confirmed',
          'data': {...data, 'contractType': contractType},
          'fields': {
            for (final e in fields.entries)
              e.key: {
                'confidence': e.value.confidence,
                'needsReview': e.value.needsReview,
              },
          },
          'user_confirmed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select('id')
        .single();
    return ExtractionResult(
      id: row['id'] as String?,
      status: ExtractionStatus.ok,
      provider: 'supabase',
      schemaVersion: '0.1.0',
      contractType: contractType,
      contract: {...data, 'contractType': contractType},
      fields: fields,
    );
  }

  @override
  Future<void> deleteContract(ExtractionResult result) async {
    if (result.id == null) return;
    await _client.from('contracts').delete().eq('id', result.id!);
  }

  @override
  Future<void> saveProfile(Map<String, dynamic> profile) async {
    await _client.from('profiles').upsert({'id': _userId, ...profile});
  }

  @override
  Future<ExtractionResult> submitDocument(String filePath) async {
    final file = File(filePath);
    final ext = filePath.split('.').last.toLowerCase();
    final docId = DateTime.now().millisecondsSinceEpoch.toString();
    final storagePath = '$_userId/$docId.$ext';

    await _client.storage.from('documents').upload(storagePath, file);
    final doc = await _client
        .from('documents')
        .insert({
          'user_id': _userId,
          'storage_path': storagePath,
          'original_filename': filePath.split(Platform.pathSeparator).last,
          'status': 'uploaded',
        })
        .select('id')
        .single();

    try {
      final response = await _client.functions.invoke(
        'extract-document',
        body: {'document_id': doc['id']},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['status'] is String) {
        if (data['status'] == 'rejected') {
          throw ExtractionUnavailable(
            (data['reason'] as String?) ??
                'Dokument konnte nicht als Vertrag erkannt werden.',
          );
        }
        return ExtractionResult.fromJson(data);
      }
      throw const ExtractionUnavailable(
        'Das automatische Auslesen ist gerade nicht verfügbar.',
      );
    } on ExtractionUnavailable {
      rethrow;
    } catch (_) {
      // Edge Function nicht erreichbar oder AI-Limit (z.B. Bedrock-Quota).
      throw const ExtractionUnavailable(
        'Das automatische Auslesen ist gerade nicht verfügbar. '
        'Du kannst den Vertrag stattdessen manuell eintragen.',
      );
    }
  }
}
