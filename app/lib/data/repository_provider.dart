import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import 'contracts_repository.dart';
import 'supabase_contracts_repository.dart';

/// Liefert die passende Repository-Implementierung:
/// Supabase, wenn Backend konfiguriert und angemeldet — sonst Mock.
ContractsRepository contractsRepository() {
  if (AppConfig.hasBackend &&
      Supabase.instance.client.auth.currentUser != null) {
    return SupabaseContractsRepository(Supabase.instance.client);
  }
  return MockContractsRepository();
}
