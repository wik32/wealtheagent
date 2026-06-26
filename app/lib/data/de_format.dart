import 'catalog_controller.dart';
import '../l10n.dart';

/// Formatierung von Vertragswerten für die Anzeige. Labels/Icons/Enum-Texte
/// kommen aus dem Katalog (catalogController); hier bleibt nur die Darstellung.

String _intervalLabel(String interval) => switch (interval) {
      'monatlich' => t('Monat', 'month'),
      'vierteljaehrlich' => t('Quartal', 'quarter'),
      'halbjaehrlich' => t('Halbjahr', 'half-year'),
      'jaehrlich' => t('Jahr', 'year'),
      'einmalig' => t('einmalig', 'one-time'),
      _ => interval,
    };

String formatEur(num value, {int decimals = 2}) {
  final fixed = value.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final intPart = parts[0]
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  final decPart = decimals > 0 ? ',${parts[1]}' : '';
  return '$intPart$decPart €';
}

String formatFieldValue(dynamic value) {
  if (value == null) return '—';
  if (value is bool) return value ? t('Ja', 'Yes') : t('Nein', 'No');
  if (value is String) {
    final date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (date != null) {
      return '${date.group(3)}.${date.group(2)}.${date.group(1)}';
    }
    return catalogController.catalog?.enumLabelGlobal(value) ?? value;
  }
  if (value is num) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString().replaceAll('.', ',');
  }
  if (value is List) {
    return '${value.length} ${t('Positionen', 'positions')}';
  }
  if (value is Map) {
    // Beitrag: {amount: {amount, currency}, interval}
    if (value.containsKey('interval')) {
      final amount = (value['amount'] as Map?)?['amount'] as num?;
      final interval = _intervalLabel(value['interval'] as String? ?? '');
      if (amount != null) return '${formatEur(amount)} / $interval';
    }
    // Geldbetrag: {amount, currency}
    final amount = value['amount'];
    if (amount is num) {
      return formatEur(amount, decimals: amount >= 1000 ? 0 : 2);
    }
  }
  return value.toString();
}
