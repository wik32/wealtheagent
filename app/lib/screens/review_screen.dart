import 'package:flutter/material.dart';
import '../data/catalog_controller.dart';
import '../data/contracts_controller.dart';
import '../data/de_format.dart';
import '../data/extraction_result.dart';
import '../data/repository_provider.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';

/// Confirm-and-correct: extrahierte Felder prüfen, korrigieren, bestätigen.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.result});

  final ExtractionResult result;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late Map<String, dynamic> _data;
  bool _editMode = false;
  bool _edited = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.result.contract);
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      await contractsRepository().confirmContract(
        widget.result,
        correctedData: _edited ? _data : null,
      );
      await contractsController.refresh();
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Vertrag löschen?', 'Delete contract?')),
        content: Text(t(
            'Dieser Vertrag wird dauerhaft aus deinem Bestand entfernt.',
            'This contract will be permanently removed from your records.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('Abbrechen', 'Cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB23A2E)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('Löschen', 'Delete')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    try {
      await contractsRepository().deleteContract(widget.result);
      await contractsController.refresh();
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _editField(String key) async {
    final current = _data[key];
    if (current is bool) {
      setState(() {
        _data[key] = !current;
        _edited = true;
      });
      return;
    }
    final controller = TextEditingController(
      text: switch (current) {
        null => '',
        final Map m when m.containsKey('interval') =>
          (((m['amount'] as Map?)?['amount']) ?? '').toString(),
        final Map m => (m['amount'] ?? '').toString(),
        _ => current.toString(),
      },
    );
    final label =
        catalogController.fieldLabel(widget.result.contractType ?? '', key);
    final isMoney = current is Map;
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label, style: serif(size: 17, spacing: 0)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: isMoney || current is num
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: isMoney
                ? t('Betrag in Euro', 'Amount in euros')
                : key.endsWith('Date')
                    ? 'JJJJ-MM-TT'
                    : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('Abbrechen', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(t('Übernehmen', 'Apply')),
          ),
        ],
      ),
    );
    if (newValue == null) return;
    setState(() {
      _edited = true;
      if (newValue.isEmpty) {
        _data[key] = null;
      } else if (current is Map) {
        final amount = double.tryParse(newValue.replaceAll(',', '.'));
        if (amount == null) return;
        final updated = Map<String, dynamic>.from(current);
        if (updated.containsKey('interval')) {
          updated['amount'] = {'amount': amount, 'currency': 'EUR'};
        } else {
          updated['amount'] = amount;
        }
        _data[key] = updated;
      } else if (current is num) {
        _data[key] = num.tryParse(newValue.replaceAll(',', '.')) ?? current;
      } else {
        _data[key] = newValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final typeLabel = catalogController.typeName(result.contractType);
    final entries = _data.entries
        .where((e) => e.key != 'contractType' && e.key != 'criteria')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Kurz prüfen', 'Quick check')),
        actions: [
          IconButton(
            tooltip: t('Löschen', 'Delete'),
            onPressed: _saving ? null : _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Kicker(typeLabel),
          const SizedBox(height: Sp.sm),
          Text((_data['provider'] as String?) ?? '—',
              style: serif(size: 28, color: context.inkColor, height: 1.1)),
          const SizedBox(height: Sp.md),
          Text(
            _editMode
                ? t('Tippe ein Feld an, um es zu korrigieren.',
                    'Tap a field to correct it.')
                : t('Das haben wir gelesen. Stimmt alles?',
                    'This is what we read. Everything correct?'),
            style: TextStyle(color: context.mutedColor, fontSize: 14),
          ),
          const SizedBox(height: Sp.xl),
          const Hairline(),
          for (final entry in entries) ...[
            _FieldRow(
              label: catalogController.fieldLabel(
                  result.contractType ?? '', entry.key),
              value: formatFieldValue(entry.value),
              needsReview:
                  (result.fields[entry.key]?.needsReview ?? false) && !_edited,
              editable: _editMode,
              onTap: _editMode ? () => _editField(entry.key) : null,
            ),
            const Hairline(),
          ],
          const SizedBox(height: Sp.xxl),
          FilledButton(
            onPressed: _saving ? null : _confirm,
            child: Text(_edited
                ? t('Korrigiert bestätigen ✓', 'Confirm corrections ✓')
                : t('Passt so ✓', 'Looks good ✓')),
          ),
          const SizedBox(height: Sp.md),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _editMode = !_editMode),
              child: Text(_editMode
                  ? t('Fertig mit Korrigieren', 'Done correcting')
                  : t('Etwas korrigieren', 'Correct something')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    required this.needsReview,
    this.editable = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool needsReview;
  final bool editable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = needsReview ? context.terracotta : context.inkColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: needsReview
                          ? context.terracotta
                          : context.mutedColor)),
            ),
            const SizedBox(width: Sp.md),
            Flexible(
              child: Text(
                needsReview
                    ? '$value · ${t('bitte prüfen', 'please check')}'
                    : value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: serif(size: 15, color: accent, spacing: 0),
              ),
            ),
            if (editable) ...[
              const SizedBox(width: Sp.sm),
              Icon(Icons.edit_outlined, size: 15, color: context.accentColor),
            ],
          ],
        ),
      ),
    );
  }
}
